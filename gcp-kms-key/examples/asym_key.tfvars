project_id = "<project_id>"
key_ring   = "projects/<project_id>/locations/us/keyRings/<key_ring_name>"

########### Key details ################
key_name = "asym-key"
iam_role_members = {
  "roles/cloudkms.cryptoKeyEncrypter" = ["serviceAccount:<sa_email_id>"]
}
purpose = "ASYMMETRIC_DECRYPT"

# optional
labels = {
  "component" = "project1-crypto-keys"
}
