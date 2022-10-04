/*
* # gcp-binary-authorization/key
* Creates attestation key, and adds cryptoOperator IAM role to Deployer and Attestor project's SA responsible for Binary Authorisation.
*
* ## Pre-requisites
* * Keys project should have Cloud KMS APIs ("cloudkms.googleapis.com") enabled
* * Refer to [README](../README.md) for overall solution's requirements
*/

data "google_project" "key_project" {
  project_id = var.key_project_id
}

# check if keyring is present
data "google_kms_key_ring" "attestor_key_ring" {
  project = data.google_project.key_project.name
  name     = var.key_ring_name
  location = var.location
}

locals {
  is_keyring_exits = data.google_kms_key_ring.attestor_key_ring.self_link != null? true: false

  deployer_project_SAs = [
    for number in var.deployer_project_numbers: "serviceAccount:service-${number}@gcp-sa-binaryauthorization.iam.gserviceaccount.com"
  ]
}

# Create a Key Ring in a central (attestor) project.
module "key-ring"{
  source = "../gcp-kms-keyring"
  count = local.is_keyring_exits ? 0 : 1  # TODO: with this logic, TF (re)apply says key ring will be destroyed but actually not, misleading..
  project_id = data.google_project.key_project.name
  key_ring_name = var.key_ring_name
  location = var.location
}

module "attestor-key"{
  source = "../gcp-kms-key"
  project_id = data.google_project.key_project.name
  key_ring   = local.is_keyring_exits? data.google_kms_key_ring.attestor_key_ring.self_link: module.key-ring[0].self_link

  key_name = var.attestor_key_name
  purpose = "ASYMMETRIC_SIGN"
  // RSA is GP approved, not EC. Should be with key strength 2048 or higher.
  algorithm = "RSA_SIGN_PKCS1_4096_SHA512"
  rotation_period = "5184000s" # 60 days

  # optional, but required for Bin auth end to end provisioning
  use_iam_binding = false
  iam_role_members = {
    "roles/cloudkms.cryptoOperator"  = concat([
      "serviceAccount:service-${var.attestor_project_number}@gcp-sa-binaryauthorization.iam.gserviceaccount.com"
    ], local.deployer_project_SAs, var.key_users)
  }
  labels = {
    "component" = "testlz-keys-${var.attestor_key_name}"
  }
}
