provider "google" {
  project = var.project_id
  region  = var.region
}

# default SA for creating OIDC tokens
data "google_compute_default_service_account" "default" {
}

locals {
  topic = var.pubsub_target != null ? "projects/${var.project_id}/topics/${var.pubsub_target.topic_name}" : null

  # attempt deadline defaults, based on https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job#attempt_deadline
  default_deadline = {
    pub-sub = "3.5s",
    app-eng = "15s",
    http    = "15s"
  }

  service_account_email = var.service_account_email == null ? data.google_compute_default_service_account.default.email : var.service_account_email
}