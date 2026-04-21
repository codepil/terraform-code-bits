output "service_account_email" {
  description = "Service account email."
  value       = module.suricata_instance_service_account.email
}