# See https://cloud.google.com/iap/docs/using-tcp-forwarding for detailed information

resource "google_compute_firewall" "iap" {
  name          = "iap-to-${var.collector_name_prefix}"
  network       = var.vpc_name
  project       = var.project_id
  source_ranges = ["35.235.240.0/20"]
  target_tags   = local.lm_collector_network_tags
  direction     = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["3389", "22"]
  }
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_iap_tunnel_instance_iam_binding" "enable_iap" {
  count    = local.instance_count
  project  = var.project_id
  zone     = local.instance_zone_list[count.index]
  instance = module.lm_collector_vms.names[count.index]
  role     = "roles/iap.tunnelResourceAccessor"
  members  = distinct(concat([local.userinfo_email], var.collector_login_users))
}

# then use https://cloud.google.com/iap/docs/using-tcp-forwarding#gcloud_3 to connect to VM.