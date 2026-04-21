// Note: silent install is not supported, commenting related code
//data "template_file" "init" {
//  template = file("${path.module}/templates/install_lm_collector_windows.tpl")
//  vars = {
//    download_url = var.download_url
//  }
//}

# Get the service account/workload identity of the process deploying this
# and possibly use it as member into the IAP
data "google_client_openid_userinfo" "provider_identity" {
}

data "google_compute_subnetwork" "lm-subnetwork" {
  name    = var.subnet_name
  region  = var.region
  project = var.project_id
}

locals {
  vpc_network    = "projects/pid-gcp-tlz-gke01-d0cc/global/networks/${var.vpc_name}"
  subnetwork     = "projects/${var.project_id}/regions/${var.region}/subnetworks/${var.subnet_name}"
  instance_count = var.collectors_per_zone * length(var.zones)

  // Note: silent install is not supported, commenting related code
  // For Windows binary
  //metadata = {
  //  windows-startup-script-url = data.template_file.init.rendered
  //}
  // For Linux binary
  //metadata                        = { startup-script = file("${path.module}/scripts/install_logicmonitor_collector.sh") }

  instance_zone_list = flatten([for zone in var.zones : [for i in range(0, var.collectors_per_zone) : zone]])

  lm_collector_udp_ports = [
    "162",  # snmap traps
    "2055", # netflow
    "6343"  # sflow
  ]
  lm_collector_network_tags = ["lm-collector"]

  // Qualify email type to construct IAP member accordingly, required for local environment
  is_sa_email    = contains(split(".", data.google_client_openid_userinfo.provider_identity.email), "gserviceaccount")
  userinfo_email = local.is_sa_email ? "serviceAccount:${data.google_client_openid_userinfo.provider_identity.email}" : "user:${data.google_client_openid_userinfo.provider_identity.email}"
}