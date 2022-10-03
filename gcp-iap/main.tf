/*
* # gcp-iap
*
* This module provisions IAP, and adds member identities to access given VM instances or MIG
*
* ## Pre-requisites
* * API project services are to be enabled
*   * iap.googleapis.com
* * Project should have Oauth consent done.
* ## Roles
* * 'roles/resourcemanager.projectIamAdmin' and 'roles/iap.admin' to create IAP policies and add members respectively
* ## Next steps
* * Users can use tools mentioned in https://cloud.google.com/iap/docs/using-tcp-forwarding document to Tunnel the connection.
*/

data "google_project" "project" {
  project_id = var.project_id
}

# Get the service account/workload identity of the process deploying this
# and possibly use it as member into the IAP
data "google_client_openid_userinfo" "provider_identity" {
}

data "google_compute_region_instance_group" "data_source" {
  count     = var.mig_access != null ? 1 : 0
  self_link = var.mig_access.mig_name
}

locals {
  // Qualify email type to construct IAP member accordingly, required for local environment
  is_sa_email    = contains(split(".", data.google_client_openid_userinfo.provider_identity.email), "gserviceaccount")
  userinfo_email = local.is_sa_email ? "serviceAccount:${data.google_client_openid_userinfo.provider_identity.email}" : "user:${data.google_client_openid_userinfo.provider_identity.email}"
}

resource "google_compute_firewall" "iap-tags" {
  count    = var.target_tags != null ? 1 : 0
  name     = "allow-iap-via-tags"
  network  = var.network
  project  = var.project_id
  priority = var.base_priority

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"] # SSH and RDP
  }

  source_ranges = ["35.235.240.0/20"]

  target_tags = var.target_tags

  direction = "INGRESS"
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "iap-sa" {
  count    = var.target_service_accounts != null ? 1 : 0
  name     = "allow-iap-via-sa"
  network  = var.network
  project  = var.project_id
  priority = var.base_priority

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"] # SSH and RDP
  }

  source_ranges = ["35.235.240.0/20"]

  target_service_accounts = var.target_service_accounts

  direction = "INGRESS"
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}


# Add principals to the access list
resource "google_iap_tunnel_instance_iam_binding" "vm" {
  for_each = var.vm_access != null ? var.vm_access : {}
  project  = var.project_id
  instance = each.key
  role     = "roles/iap.tunnelResourceAccessor"
  members  = distinct(concat([local.userinfo_email], each.value))
}

resource "google_iap_tunnel_instance_iam_binding" "mig" {
  count    = var.mig_access != null ? length(data.google_compute_region_instance_group.data_source[0].instances) : 0
  project  = var.project_id
  instance = data.google_compute_region_instance_group.data_source[0].instances[count.index].instance
  role     = "roles/iap.tunnelResourceAccessor"
  members  = distinct(concat([local.userinfo_email], var.mig_access.members))
}
