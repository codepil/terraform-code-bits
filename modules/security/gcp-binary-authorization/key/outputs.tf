output "key-ring" {
  description = "Keyring self_link"
  value       = local.is_keyring_exits? data.google_kms_key_ring.attestor_key_ring.self_link: module.key-ring[0].self_link
}

output "key" {
  description = "Crypto key ID"
  value       = module.attestor-key
}