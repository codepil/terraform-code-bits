locals {
  subnet_regions = var.subnet_regions
  # prescribed multi-regional subnet CIDRs for each lifecycle
  dedicated_cidrs = {
    dev       = ["100.96.0.0/17", "100.96.128.0/17"]
    qa        = ["100.97.0.0/17", "100.97.128.0/17"]
    svcs      = ["100.102.0.0/17", "100.102.128.0/17", "100.107.0.0/17", "100.107.128.0/17"]
  }
  region_cidr_count = min(length(local.subnet_regions), length(lookup(local.dedicated_cidrs, var.environment)))
  region_cidrs      = zipmap(slice(local.subnet_regions, 0, local.region_cidr_count), slice(lookup(local.dedicated_cidrs, var.environment), 0, min(length(local.subnet_regions), length(lookup(local.dedicated_cidrs, var.environment)))))

  # private.googleapis.com range
  private_apis_cidr = ["199.36.153.8/30"]
  private_apis_ips  = ["199.36.153.8", "199.36.153.9", "199.36.153.10", "199.36.153.11"]

  # prescribed multi-regional secondary range CIDRs for each lifecycle
  dedicated_secondary_cidrs = {
    dev       = ["252.0.0.0/11", "252.32.0.0/11"]
    qa        = ["252.64.0.0/11", "252.96.0.0/11"]
  }
  region_secondary_cidr_count = min(length(local.subnet_regions), length(lookup(local.dedicated_secondary_cidrs, var.environment)))
  region_secondary_cidrs      = zipmap(slice(local.subnet_regions, 0, local.region_secondary_cidr_count), slice(lookup(local.dedicated_secondary_cidrs, var.environment), 0, min(length(local.subnet_regions), length(lookup(local.dedicated_secondary_cidrs, var.environment)))))
  internal_egress_cidrs       = concat(values(local.region_cidrs), values(local.region_secondary_cidrs))
  # Routing
  routes_for_all = [
    {
      name              = "priv-access"
      description       = "route all GCP private access through default route"
      destination_range = "199.36.153.4/30"
      priority          = 99
      next_hop_internet = "true"
    },
    {
      name              = "priv-access2"
      description       = "route all GCP private access through default route"
      destination_range = "199.36.153.8/30"
      priority          = 99
      next_hop_internet = "true"
    }
  ]
  routes = var.enable_private_access_routing ? concat(local.routes_for_all, var.routes) : var.routes

  # Define list of PGA zones
  # for GKE private cluster deployment, googleapis.com and gcr.io are required
  dns_pga_zones = [
    for domain, subdomain in var.private_access_dns_entries :
    {
      zone_name                          = replace(domain, ".", "-")
      domain                             = "${domain}."
      private_visibility_config_networks = [module.vpc.network_self_link]
      record_sets = [
        {
          name    = trimsuffix(trimsuffix(subdomain, domain), ".") # remove "." after removing domain
          type    = "A"
          ttl     = 300
          records = local.private_apis_ips
        },
        {
          name = "*"
          type = "CNAME"
          ttl  = 300
          records = [
            "${subdomain}.",
          ]
        },
      ]
    }
  ]
  dns_zones = {
    for zone in local.dns_pga_zones :
    zone.zone_name => zone
  }
}
