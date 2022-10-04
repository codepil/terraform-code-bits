locals {
  subnet_offsets = length(var.subnet_offsets) > 0 ? var.subnet_offsets : local.default_subnet_offsets
  default_subnet_offsets = {
    admin = {
      netnum = 1
      mask   = "24"
    }
    k8s-infra-nodes = {
      netnum = 1
      mask   = "23"
    }
    edge = {
      netnum = 16
      mask   = "26"
    }
    tier1-lb = {
      netnum = 17
      mask   = "26"
    }
    tier1 = {
      netnum = 5
      mask   = "24"
    }
    tier2-lb = {
      netnum = 18
      mask   = "26"
    }
    tier2 = {
      netnum = 3 # additional 000 011 network bits
      mask   = "23"
    }
    tier3 = {
      netnum = 4 # additional 000 100 network bits
      mask   = "23"
    }
    tier1-k8s-1-nodes = {
      netnum = 2 # additional 0010 network bits
      mask   = "21"
    }
    tier1-k8s-2-nodes = {
      netnum = 3 # additional 0011 network bits
      mask   = "21"
    }
    tier2-k8s-1-nodes = {
      netnum = 4 # additional 0100 network bits
      mask   = "21"
    }
    tier2-k8s-2-nodes = {
      netnum = 5 # additional 0101 network bits
      mask   = "21"
    }
    tier1-autoscale = {
      netnum = 4 # additional 100 network bits
      mask   = "20"
    }
    tier2-autoscale = {
      netnum = 3 # additional 11 network bits
      mask   = "19"
    }
  }

  secondary_offsets = length(var.secondary_offsets) > 0 ? var.secondary_offsets : local.default_secondary_offsets
  default_secondary_offsets = {
    k8s-infra-nodes = {
      k8s-infra-pods = {
        netnum = 0 # additional 0 0000 network bits
        mask   = "16"
      }
      k8s-infra-services = {
        netnum = 1 # additional 0 0001 network bits
        mask   = "16"
      }
    }
    tier1-k8s-1-nodes = {
      tier1-k8s-1-pods = {
        netnum = 3 # additional 0 11 network bits
        mask   = "14"
      }
      tier1-k8s-1-services = {
        netnum = 2 # additional 0 010 network bits
        mask   = "15"
      }
    }
    tier1-k8s-2-nodes = {
      tier1-k8s-2-pods = {
        netnum = 4 # additional 1 00 network bits
        mask   = "14"
      }
      tier1-k8s-2-services = {
        netnum = 3 # additional 0 011 network bits
        mask   = "15"
      }
    }
    tier2-k8s-1-nodes = {
      tier2-k8s-1-pods = {
        netnum = 5 # additional 1 01 network bits
        mask   = "14"
      }
      tier2-k8s-1-services = {
        netnum = 4 # additional 0 100 network bits
        mask   = "15"
      }
    }
    tier2-k8s-2-nodes = {
      tier2-k8s-2-pods = {
        netnum = 6 # additional 1 10 network bits
        mask   = "14"
      }
      tier2-k8s-2-services = {
        netnum = 5 # additional 0 101 network bits
        mask   = "15"
      }
    }
  }

  # ***** Subnet Calculations *****
  # NOTE: The structures being created are tuned toward use with https://github.com/terraform-google-modules/terraform-google-network
  # If you wish to use https://github.com/terraform-google-modules/cloud-foundation-fabric instead,
  # the local.subnets will need restructuring (and nesting of secondary range info, removal of flowlog information), 
  # and creation additonal data structures for parameters specified differently.
  interim_subnet_info = flatten([for rn, rc in var.region_cidrs :
    [for sn, si in local.subnet_offsets :
      {
        name        = "${rn}-${var.environment}-${sn}"
        region      = rn
        region_cidr = var.region_cidrs[rn]
        #offset      = si.offset
        mask   = si.mask,
        netnum = si.netnum
        #offset_in_dec = tonumber(element(split(".", si.offset), 1) * 65536) + tonumber(element(split(".", si.offset), 2) * 256) + tonumber(element(split(".", si.offset), 3))
        maskdiff = tonumber(element(split("/", si.mask), 1)) - tonumber(element(split("/", rc), 1))
      }
    ]
  ])
  # Create the map of subnets with subnet cidr calculation
  subnets = { for si in local.interim_subnet_info :
    si.name => merge(var.subnet_attributes, {
      lookup(var.subnet_map_fields, "region_key", "region")    = si.region
      lookup(var.subnet_map_fields, "name_key", "name")        = si.name
      lookup(var.subnet_map_fields, "cidr_key", "subnet_cidr") = cidrsubnet(si.region_cidr, si.maskdiff, si.netnum)
    })
  }

  ######## Secondary admin range calculations ########
  region_secondary_subnet_pairs = setproduct(keys(var.region_secondary_cidrs), keys(local.secondary_offsets))
  interim_secondary_info = { for pair in local.region_secondary_subnet_pairs :
    "${pair.0}-${var.environment}-${pair.1}" => [for secn, seci in lookup(local.secondary_offsets, pair.1) :
      {
        name        = "${pair.0}-${var.environment}-${secn}"
        region_cidr = var.region_secondary_cidrs[pair.0]
        netnum      = seci.netnum
        maskdiff    = tonumber(element(split("/", seci.mask), 1)) - tonumber(element(split("/", var.region_secondary_cidrs[pair.0]), 1))
      }
    ]
  }

  # Create the map of subnets with subnet cidr calculation
  secondary_ranges = { for subn, subni in local.interim_secondary_info :
    subn => [for seci in subni :
      {
        lookup(var.secondary_map_fields, "name_key", "name")    = seci.name
        lookup(var.secondary_map_fields, "cidr_key", "ip_cidr") = cidrsubnet(seci.region_cidr, seci.maskdiff, seci.netnum)
      }
    ]
  }

}




