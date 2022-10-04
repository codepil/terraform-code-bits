/**
 * # gcp-network-intrusion-detection
 * This module deploys an instance group via an instance template, packet mirroring, and the required backend services and firewalls to allow for the targeting and mirroring of traffic to facilitate an IDS service.
 * Traffic can be targeted by either subnet, instance, or instance tag. The targeted traffic is reflected to the instance group and is visible to the network adapters of those instances.
 * Suricata is presently the IDS configured to be deployed in the instance group by this module. Suricata operates on lists of rules to evaluate traffic. Public sets of rules are commonly used; however, custom rules can be written and applied as well.
 * The [Suricata-Update](https://github.com/OISF/suricata-update) tool was created to assist with the update and management of rule sets.
 *
 * ## Pre-requisites
 * * The collector and mirrored sources must be in the same region.
 * * Below API project services are to be enabled on the '<project_id>'
 *   * compute.googleapis.com
 * * Compute instance Service Account is to be created, say suricata-ids@'<project_id>'.iam.gserviceaccount.com. And same is provisioned to be accessing '<gcs_bucket>'. Refer to module [ids-configuration-infrastructure](https://github.com/codepil/terraform-code-bits/ids-configuration-infrastructure/-/tree/main) for further details.
 * * Cloud service account (i.e., '<project_id>'@cloudservices.gserviceaccount.com ) is to be added to golden images project for accessing Golden images.
 *
 * ## Assumptions/Dependencies
 * * Golden image is been created using latest Suricata binary installed, and with fluentd configurations to parse suricata.log and fast.log files.
 * * IDS/Suricata configuration files should be present on '<gcs_bucket>/<config_dir>' location.
 *   * suricata.yaml
 *   * '<signature_file_name>' (ex: etpro.rules.tar.gz)
 *   * custom_log.conf, if any
 * ## Notes for module consumption
 * * Review your network deployment model for collector and packer mirroring policy, and accordingly model TF input. Refer to [doc](https://cloud.google.com/blog/products/networking/using-packet-mirroring-with-ids) for the details.
 * * Autoscaling defaults are not load tested, only indicative and adjusted based on POV in test environment.
 * * Set 'create_firewall_rules' to false, if your project would like to manage FW rules separately.
 * * Review the MIG instance update default policies and change them accordingly.
 * * Currently 'signature_file_name' is a single field. If there are multiple bundles, please combine and provide single source file name.
 * * TODO: [US255652] default tags used in log configurations are to be reviewed, while developing log sink for Splunk. Change shall go to golden image.
 * * Provisioning IAP is a separate module ([gcp-iap](https://github.com/codepil/terraform-code-bits/gcp-iap)), its only required for executing suricate-update CLI commands on the node, preferred to use either Bastion or Jump server for that purpose in production. Raise merge request on this module if the changes are useful for other BUs.
 */

data "google_project" "project" {
  project_id = var.project
}

locals {
  # Path to the configuration files are passed to the instance start up scripts
  suricata_config_path   = "gs://${var.gcs_bucket}/${var.config_dir}/suricata.yaml"
  custom_log_config_path = "gs://${var.gcs_bucket}/${var.config_dir}/custom_log.conf"
  source_signature_path  = "https://storage.cloud.google.com/${var.gcs_bucket}/${var.config_dir}/${var.signature_file_name}"

  policy_project = var.policy_project != null ? var.policy_project : var.project
  instance_tag = "ids"
}

## Instance template, service account, group manager, and health check
resource "google_compute_instance_template" "ids" {
  name_prefix  = "${var.prefix}-"
  machine_type = var.instance_type
  project      = var.project

  disk { # create a boot disk from image
    source_image = var.source_image_url
    disk_size_gb = var.boot_disk_size
    disk_type    = var.boot_disk_type
    auto_delete  = true
    boot         = true
  }

  tags = [local.instance_tag]

  metadata_startup_script = templatefile("${path.module}/templates/gold_${var.linux_os_type}_startup.sh", {
    log_config_path       = local.custom_log_config_path
    suricata_config_path  = local.suricata_config_path
    source_signature_path = local.source_signature_path
  })

  service_account {
    email  = var.ids_service_account_email
    scopes = ["cloud-platform", "storage-ro"]
  }

  network_interface {
    subnetwork = var.subnet
  }

  lifecycle {
    create_before_destroy = true
  }

  labels = merge(data.google_project.project.labels, var.labels)

  shielded_instance_config {
    enable_secure_boot = true
  }
}

# Creates Managed Instance Group
module "mig" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric.git//modules/compute-mig?ref=v7.0.0"
  project_id = var.project
  location   = var.region
  regional   = true
  name       = "${var.prefix}-igm"

  # Default version is always present
  default_version = {
    instance_template = google_compute_instance_template.ids.id
    name              = "default"
  }

  # Autoscaling
  autoscaler_config = var.autoscaler_config
  # Health check
  health_check_config = {
    type    = "tcp"
    check   = { port = 22 }
    config  = {}
    logging = true
  }
  # Use policy based on the health checks
  auto_healing_policies = {
    health_check      = module.mig.health_check.self_link
    initial_delay_sec = 30
  }
  # instance update policy
  update_policy = var.update_policy

  # Wait for all instances to be created/updated before returning, required for IAP
  wait_for_instances = true
}

## Mirroring, forwarding, and backend
resource "google_compute_packet_mirroring" "ids" {
  for_each    = var.mirroring_policies
  name        = each.key
  description = "Packet mirror for Suricata"
  region      = var.region
  project     = local.policy_project
  network {
    url = "projects/${each.value.project_id}/global/networks/${each.value.vpc_name}"
  }
  collector_ilb {
    url = google_compute_forwarding_rule.ids.id
  }
  mirrored_resources {
    tags = each.value.instance_tags
    dynamic "subnetworks" {
      for_each = each.value.subnets
      content {
        url = "projects/${each.value.project_id}/regions/${var.region}/subnetworks/${subnetworks.value}"
      }
    }
    dynamic "instances" {
      for_each = each.value.instances
      content {
        url = instances.value
      }
    }
  }
  filter {
    ip_protocols = var.filter.ip_protocols
    cidr_ranges  = var.filter.cidr_ranges
    direction    = var.filter.direction
  }
}


# ILB, required for packet mirroring
resource "google_compute_forwarding_rule" "ids" {
  name = "${var.prefix}-ilb"

  is_mirroring_collector = true
  ip_protocol            = "TCP"
  load_balancing_scheme  = "INTERNAL"
  backend_service        = google_compute_region_backend_service.ids.id
  all_ports              = true
  network                = var.network
  subnetwork             = var.subnet
  network_tier           = "PREMIUM"
  project                = var.project
  region                 = var.region
}

# This is the managed instance group that receives mirrored traffic from the ILB.
resource "google_compute_region_backend_service" "ids" {
  name    = "${var.prefix}-ids-svc"
  project = var.project
  region  = var.region

  health_checks = [module.mig.health_check.id]
  backend {
    group = module.mig.group_manager.instance_group
  }
}

# Health check FW to allow ILB
resource "google_compute_firewall" "mig-hc" {
  project  = var.project
  name     = "${var.prefix}-hc"
  network  = var.network
  priority = var.base_priority - 1
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges           = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags = [local.instance_tag]
}

# Allow all other traffic flows for detection
resource "google_compute_firewall" "ids" {
  count = var.create_firewall_rules ? 1 : 0

  name     = "allow-all-to-suricata"
  network  = var.network
  project  = var.project
  priority = var.base_priority
  allow {
    protocol = "all"
  }
  source_ranges           = var.traffic_source_ranges
  target_tags = [local.instance_tag]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}


