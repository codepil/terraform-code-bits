/*
* This example module creates an Attestor, using CFF module https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/v16.1.0/modules/binary-authorization
* * Create a key ring, if 'key_ring_name' not found on the project
* * Creating an asymmetric key in KMS
* * Register with container analysis API with an authorisation note
* * Enables project for Binary Authorisation APIs, namely "binaryauthorization.googleapis.com", "containerregistry.googleapis.com", "artifactregistry.googleapis.com".
*
* ## Next steps
* After building an Attestor, Attestations can be created using KMS key, in the respective image built CI/CD pipeline.
* Create/update authorisation policies to use Attestor created, to complete the GKE/binary authorisation.
*/


# Create a Key Ring
module "key-ring"{
  source = "../gcp-kms-keyring"

  project_id = "pid-gcp-tlz-gke01-d0cc"
  key_ring_name = "attestor-key-ring"
  location = "global"
}

// Create KMS key and Attestor
module "quality-attestor" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/binary-authorization"

  project_id = "pid-gcp-tlz-gke01-d0cc"
  attestor-name =  "<bu>-common-attestor"
  keyring-id    = module.key-ring.self_link
}


