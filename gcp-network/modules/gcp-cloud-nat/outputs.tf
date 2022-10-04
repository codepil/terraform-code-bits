output "addresses" {
  description = "Static IP addresses that were reserved.  Note, if no IPs were created, empty list is returned."
  value       = google_compute_address.nat_address.*.address
}

output "router_name" {
  description = "Name of the google_computer_router that was created."
  value       = module.nat.router_name
}

output "name" {
  description = "Name of the google_compute_router_nat that was created."
  value       = module.nat.name
}
