output "nat_ips" {
  description = "Selflinks to static IPs that were reserved.  Note, if no IPs were created, empty list is returned."
  value       = flatten(values(module.nat)[*].addresses)
}

output "nat_router_names" {
  description = "Names of the google_computer_routers that was created."
  value       = values(module.nat)[*].router_name
}

output "nat_names" {
  description = "Names of the google_compute_router_nats that was created."
  value       = values(module.nat)[*].name
}

output "network" {
  description = "Selflink of the vpc created."
  value       = module.vpc.network_self_link
}
output "network_name" {
  description = "Simple name of the vpc created."
  value       = module.vpc.network_name
}
output "route_names" {
  description = "List of the route names created."
  value       = module.vpc.route_names
}
# not really sure what subnet information should be returned or in what structure..
output "subnets" {
  description = "Map of all subnets created.  Keyed by subnet_region/subnet_name, values being outputs of google_copute_subnet resources that were created."
  value       = module.vpc.subnets
}
