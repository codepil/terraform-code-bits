output "external_ips" {
  description = "Instance main interface external IP addresses."
  value       = module.linuxvm.external_ips
}


output "internal_ips" {
  description = "Instance main interface internal IP addresses."
  value       = module.linuxvm.internal_ips
}

output "instance_names" {
  description = "Instance names."
  value       = module.linuxvm.names
}

output "self_links" {
  description = "Instance self links."
  value       = module.linuxvm.self_links
}

output "service_account_email" {
  description = "Service account email."
  value       = module.linuxvm.service_account_email
}

output "service_account_iam_email" {
  description = "Service account email."
  value       = module.linuxvm.service_account_iam_email
}
