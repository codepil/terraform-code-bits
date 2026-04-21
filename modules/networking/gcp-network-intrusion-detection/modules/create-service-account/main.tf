module "suricata_instance_service_account" {
  source       = "github.com/terraform-google-modules/cloud-foundation-fabric.git//modules/iam-service-account?ref=v18.0.0"
  name         = "${var.prefix}-ids"
  display_name = "Suricata Service Account"
  project_id   = var.project
  project_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/storage.objectViewer",
  ]
}