/**
* # gcp-cloud-nat
* 
* This module is a wrapper around a google provided Cloud NAT module,
* adding automatic IP reservation.
* 
*/

locals {
  router_name   = var.router_name != "" ? var.router_name : "${var.nat_name}-rtr"
  nat_addresses = length(var.existing_nat_addresses) > 0 ? var.existing_nat_addresses : try(google_compute_address.nat_address.*.self_link, null)
}

resource google_compute_address "nat_address" {
  count        = length(var.existing_nat_addresses) > 0 ? 0 : var.number_nat_addresses
  project      = var.project_id
  region       = var.region
  name         = "${var.nat_name}-addr-${count.index}"
  address_type = "EXTERNAL"
  # not supported in GA provider yet:
  # labels       = merge(var.labels, { tier = "gcp-address" })
}

module "nat" {
  source         = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-cloudnat?ref=v4.3.0"
  project_id     = var.project_id
  region         = var.region
  name           = var.nat_name
  router_name    = local.router_name
  router_network = var.network
  logging_filter = "ERRORS_ONLY"
  addresses      = local.nat_addresses # google_compute_address.nat_address.*.self_link
  # defaults:
  # config_source_subnets = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  # router_create = true
  # config_min_ports_per_vm = 64
  # config_timeouts = {
  #   icmp            = 30
  #   tcp_established = 1200
  #   tcp_transitory  = 30
  #   udp             = 30
  # }
}
/*
module "nat" {
  source         = "github.com/terraform-google-modules/terraform-google-cloud-nat?ref=v1.3.0"
  project_id     = var.project_id
  region         = var.region
  name           = var.nat_name
  router_name    = local.router_name
  router_network = var.network
  router_create  = true
  #router_name = "myrouter"
  logging_filter = "ERRORS_ONLY"
  addresses      = google_compute_address.nat_address.*.self_link
}
*/
