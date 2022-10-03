/**
* Wrapper around terraform-google-network, with some  specific mandatory add-ons:
* * default firewall rules
* * default prescribed subnet ranges
* * flow logging
*
* ## Pre-requisites
* 1) Enable below Project service APIs
* * dns.googleapis.com, if enable_private_access_routing is true
*/

###############################################################################
# Networking

module "generate_subnets" {
  source                 = "./modules/generate-subnets"
  region_cidrs           = local.region_cidrs
  region_secondary_cidrs = local.region_secondary_cidrs
  environment            = var.environment
  subnet_attributes      = merge(var.subnet_flow_logs, { subnet_private_access = "true" })
}

###############################################################################
#  VPC, subnets, and secondary ranges
module "vpc" {
  source = "github.com/terraform-google-modules/terraform-google-network"
  # Cludgy way to make project services predecessor to VPC creation even though they don't direct dependency (ie, no outputs to inputs)
  project_id              = var.project_id
  auto_create_subnetworks = false
  description             = "Terraform created."
  network_name            = var.name
  routes                  = local.routes
  routing_mode            = "GLOBAL"
  secondary_ranges        = module.generate_subnets.secondary_ranges
  shared_vpc_host         = false
  subnets                 = values(module.generate_subnets.subnets)
}

###############################################################################
# Firewall

resource "google_compute_firewall" "project_firewall_deny_ingress" {
  project     = var.project_id
  name        = "shared-d-n-all-any-all-any-ingress"
  description = "Managed by Terraform gcp-vpc module. Deny ingress to anywhere in VPC by default"
  network     = module.vpc.network_self_link
  priority    = "65535"
  direction   = "INGRESS"
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  deny {
    protocol = "all"
  }
}

resource "google_compute_firewall" "project_firewall_deny_egress" {
  project     = var.project_id
  name        = "shared-d-n-internal-any-all-any-egress"
  description = "Managed by Terraform gcp-vpc module. Deny egress from VPC by default"
  network     = module.vpc.network_self_link
  priority    = "65535"
  direction   = "EGRESS"
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  deny {
    protocol = "all"
  }
}

resource "google_compute_firewall" "project_firewall_internal_egress" {
  project            = var.project_id
  name               = "shared-a-n-internal-any-internal-any-egress"
  description        = "Managed by Terraform gcp-vpc module. Allow egress within VPC by default."
  network            = module.vpc.network_self_link
  priority           = "65534"
  direction          = "EGRESS"
  destination_ranges = local.internal_egress_cidrs
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "all"
  }

}

resource "google_compute_firewall" "allow_pga_api_all_egress" {
  count              = var.enable_private_access_routing ? 1 : 0
  project            = var.project_id
  name               = "allow-private-google-access-https-egress"
  description        = "Managed by Terraform gcp-vpc module. Allow PGA egress from VPC by default."
  network            = module.vpc.network_self_link
  priority           = "65532"
  direction          = "EGRESS"
  destination_ranges = local.private_apis_cidr
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "tcp"
    ports    = [443]
  }

}

###############################################################################
# Cloud NAT

module "nat" {
  source                 = "./modules/gcp-cloud-nat"
  for_each               = var.create_nat ? toset(local.subnet_regions) : []
  project_id             = var.project_id
  network                = module.vpc.network_self_link
  region                 = each.value
  nat_name               = "${module.vpc.network_name}-nat-${each.value}"
  router_name            = "${module.vpc.network_name}-rtr-${each.value}"
  number_nat_addresses   = var.number_nat_addresses
  existing_nat_addresses = var.existing_nat_addresses
}
