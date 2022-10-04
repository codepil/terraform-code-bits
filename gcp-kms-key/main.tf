/*
* # gcp-kms-keyring
*
* This module creates a Cryptographic keys, and assigns
* IAM members to specified roles in using and managing the key.
*
*/

resource "google_kms_crypto_key" "crypto_key" {
  name     = var.key_name
  key_ring = var.key_ring

  purpose = local.purpose

  version_template {
    algorithm        = local.algorithm
    protection_level = var.protection_level
  }

  rotation_period = local.rotation_period

  # CryptoKeys cannot be deleted from Google Cloud Platform, however keeping it false for TF to manage deployments
  lifecycle {
    prevent_destroy = false
  }

  labels = local.labels
}

resource "google_kms_crypto_key_iam_member" "iam_member" {
  for_each      = var.use_iam_binding ? {} : local.iam_additive
  crypto_key_id = google_kms_crypto_key.crypto_key.self_link
  role          = each.value["role"]
  member        = each.value["member"]
}

resource "google_kms_crypto_key_iam_binding" "owners" {
  for_each      = var.use_iam_binding ? var.iam_role_members : {}
  crypto_key_id = google_kms_crypto_key.crypto_key.self_link
  role          = each.key
  members       = each.value
}
