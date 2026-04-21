provider "google" {
  project = var.project_id
}
// To get unique service account.
data "google_storage_project_service_account" "gcs_account" {
  project = var.project_id
}

locals {
  members = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
}