output "id" {
  description = "id of crypto key created"
  value       = google_kms_crypto_key.crypto_key.id
}
