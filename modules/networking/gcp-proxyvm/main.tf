/*
* # Proxy VM for private GKE cluster/Jenkins Agents access
*
* This building block is designed to create a proxy-VM aka a jump server with appropriate ingress controls,
* to enable access the resources like a private GKE cluster and a compute instance without external IP.
* User access by default is provisioned to LZ Jenkins' workload identity user.
*
* This module creates a linux VM, IAP and related Firewall rules to allow SSH inbound connection.
* It optionally provisions Cloud instance schedule component's IAM permissions which control the automated shutdown/startup of proxy-VM instances as needed by Jenkins pipeline. Users can enable this functionality by using enable_scheduler_permissions flag.
*
* Users can use steps mentioned in https://cloud.google.com/iap/docs/using-tcp-forwarding document to access proxy-VM.
*
* ## Pre-requisites
* 1) Firewall rules in a given VPC should be allowing internal VM to VM communication, inorder for Proxy VM to reach compute infrastructure.
* 2) Automation SA should be having equivalent of 'roles/iam.roleAdmin' to create custom IAM roles, if enable_scheduler_permissions is true.
* 3) Automation SA should be having equivalent of 'roles/resourcemanager.projectIamAdmin' and 'roles/iap.admin' to create IAP policies and add members
* 4) Project service APIs for compute.googleapis.com & iap.googleapis.com are enabled.
*
*/

locals {
  iap_vm_tag = "iap-${var.name}"
  # use var.zones or generate list of zones if not provided
  zones = length(var.zones) > 0 ? var.zones : (
    [for z in range(var.instance_count) : "${var.region}-b"]
  )
  // Qualify email type to construct IAP member accordingly, required for local environment
  is_sa_email    = contains(split(".", data.google_client_openid_userinfo.provider_identity.email), "gserviceaccount")
  userinfo_email = local.is_sa_email ? "serviceAccount:${data.google_client_openid_userinfo.provider_identity.email}" : "user:${data.google_client_openid_userinfo.provider_identity.email}"
}

# Get the service account/workload identity of the process deploying this
# and possibly use it as member into the IAP
data "google_client_openid_userinfo" "provider_identity" {
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "random_id" "random" {
  byte_length = 2
}

module "linuxvm" {
  source        = "github.com/terraform-google-modules/cloud-foundation-fabric.git//modules/compute-vm?ref=v4.4.2"
  project_id    = var.project_id
  region        = var.region
  zones         = local.zones
  name          = var.name
  tags          = concat(var.tags, [local.iap_vm_tag])
  instance_type = var.instance_type
  network_interfaces = [
    {
      nat        = false
      network    = var.network
      subnetwork = var.subnetwork
      addresses  = null
      alias_ips  = null
    }
  ]
  boot_disk = {
    image = var.boot_disk_image
    type  = "pd-standard"
    size  = var.boot_disk_size
  }

  service_account_create = true
  instance_count         = var.instance_count
  options = {
    allow_stopping_for_update = false
    deletion_protection       = false
    preemptible               = false
  }
}

# See https://cloud.google.com/iap/docs/using-tcp-forwarding for detailed information
resource "google_compute_firewall" "iap" {
  name          = "iap-to-${var.name}"
  network       = var.network
  project       = var.project_id
  source_ranges = ["35.235.240.0/20"]
  target_tags   = [local.iap_vm_tag]
  direction     = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_iap_tunnel_instance_iam_binding" "enable_iap" {
  count    = var.instance_count
  project  = var.project_id
  zone     = local.zones[count.index]
  instance = module.linuxvm.names[count.index]
  role     = "roles/iap.tunnelResourceAccessor"
  members  = distinct(concat([local.userinfo_email], var.members))
}

# Enable Google Managed Compute Engine System Service Account to start/stop VM instances
# GKE remote proxy pipeline would require "compute.instances.stop" permission. Adding "compute.instances.start" for future uses if any.
resource "google_project_iam_custom_role" "schedule" {
  count       = var.enable_scheduler_permissions ? 1 : 0
  project     = var.project_id
  role_id     = "instanceSchedulerRole_${random_id.random.id}"
  title       = "Compute Instance Scheduler Custom Role"
  description = "Starting and stopping compute instances (Terraform Managed)"
  permissions = ["compute.instances.start", "compute.instances.stop"]
}

resource "google_project_iam_member" "compute_sa" {
  count   = var.enable_scheduler_permissions ? 1 : 0
  project = var.project_id
  role    = google_project_iam_custom_role.schedule[0].name
  member  = "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com"
}


