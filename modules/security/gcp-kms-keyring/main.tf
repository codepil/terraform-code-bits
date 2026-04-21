/*
* # gcp-kms-keyring
*
* This module creates a Key ring in GCP, and assigns
* IAM members to specified roles as an optional entity for managing key ring.
*
*/


resource "google_kms_key_ring" "key_ring" {
  project      = var.project_id
  name         = var.key_ring_name
  location     = var.location
}

# Apply additive IAM grants
resource "google_kms_key_ring_iam_member" "iam_member" {
  count        = length(var.role_mappings)
  role         = var.role_mappings[count.index].role
  key_ring_id  = "${var.project_id}/${var.location}/${var.key_ring_name}"
  member       = "serviceAccount:${var.role_mappings[count.index].account}"
}
