
output "subnets" {
  description = "Map of subnets, with key being the subnet name and the value being a map of strings using keys subnet_ip, subnet_name, and subnet_region."
  value       = local.subnets
}

output "secondary_ranges" {
  description = "Map of subnet secondary ranges with key being the subnet name, each pointing to list of objects, those objects being a map of strings using keys range_name and ip_cidr_range."
  value       = local.secondary_ranges
}
