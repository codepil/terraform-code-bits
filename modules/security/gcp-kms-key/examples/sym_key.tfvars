project_id = "<project_id>"
key_ring   = "projects/<project_id>/locations/us/keyRings/<key_ring_name>"

########### Key details ################
key_name = "sym-key1"
iam_role_members = {
  "roles/owner"                       = ["serviceAccount:<sa_email_id1>", ]
  "roles/cloudkms.cryptoKeyEncrypter" = ["serviceAccount:<sa_email_id2>"]
}
purpose = "ENCRYPT_DECRYPT"

# optional
use_iam_binding = false
labels = {
  "component" = "project1-crypto-keys"
}
