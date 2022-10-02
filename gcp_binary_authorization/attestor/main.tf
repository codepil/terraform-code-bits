/*
* # gcp-binary-authorization/attestor
* Binary Authorization is a Google Cloud managed service that works closely with GKE to enforce deploy-time security controls
* to ensure that only trusted container images are deployed.
*
* This module creates an attestor to the Binary Authorisation, on a given project.
*
* Below resources/configurations are created by the module,
* * Attestor
* * Container analysis note
* * IAM binding
*
* A Container Analysis Note is used to represent a single attestor, and Occurrences are created and associated with each container that attestor has approved.
* The Binary Authorization API uses the concepts of "attestors" and "attestations", but these are implemented using corresponding Notes and Occurrences in the Container Analysis API.
*
* ![Analogy](https://codelabs.developers.google.com/codelabs/cloud-binauthz-intro/img/63a701bd0057ea17.png)
*
* ## Pre-requisites
* * Refer to [README](../README.md) for overall solution and attestor requirements
*/

data "google_project" "attestor" {
  project_id = var.attestor_project_id
}

# To fetch current version of key
data "google_kms_crypto_key_version" "version" {
  crypto_key = var.crypto_key_id
}

locals {
  deployer_project_SAs = [
    for number in var.deployer_project_numbers: "serviceAccount:service-${number}@gcp-sa-binaryauthorization.iam.gserviceaccount.com"
  ]
}

resource "google_binary_authorization_attestor" "attestor" {
  project = data.google_project.attestor.name
  name    = "${var.attestor_name_prefix}-attestor"
  attestation_authority_note {
    note_reference = google_container_analysis_note.build-note.name
    public_keys {
      id = data.google_kms_crypto_key_version.version.id
      pkix_public_key {
        public_key_pem      = data.google_kms_crypto_key_version.version.public_key[0].pem
        signature_algorithm = data.google_kms_crypto_key_version.version.public_key[0].algorithm
      }
    }
  }
}

resource "google_container_analysis_note" "build-note" {
  project = data.google_project.attestor.name
  name    = "${var.attestor_name_prefix}-attestor-note"
  attestation_authority {
    hint {
      human_readable_name = "${var.attestor_name_prefix} Attestor"
    }
  }
}

// Add an IAM role binding for the deployer project
resource "google_binary_authorization_attestor_iam_binding" "verifier_binding" {
  project = data.google_project.attestor.name
  attestor = google_binary_authorization_attestor.attestor.name
  role = "roles/binaryauthorization.attestorsVerifier"
  members = local.deployer_project_SAs
}