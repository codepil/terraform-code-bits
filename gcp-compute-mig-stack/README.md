# gcp-compute-mig-stack

This module creates a Managed Instance Group(MIG) stack by creating necessary stack elements like Service Accounts, Instance Templates and Load Balancers along with MIGs having Auto Scaler and Health checks enabled.

This module can be used for,

* Creating MIG, given instance template
* Creating MIG and load balancers, given instance template
* Given the image URL, Creating Instance Template & MIG
* * Optionally creating HTTPS external Load Balancer, with MIG as a default backend service
* * Optionally creating internal TCP/UDP Load Balancer, with MIG as a default backend service
* Adding additional Canary versions of instance(s) to MIG

Refer to [./examples](./examples) directory for possible scenario(s)/values.

## Pre-requisites
* Project should have enabled Compute Engine API (compute.googleapis.com).

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.7 |
| google | >= 3.65.0 |
| google-beta | >= 3.65.0 |

## Providers

| Name | Version |
|------|---------|
| google | >= 3.65.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| instance-template | github.com/terraform-google-modules/cloud-foundation-fabric.git//modules/compute-vm?ref=v4.8.0 |  |
| instance\_template\_service\_account | git::https://github.com/codepil/terraform-code-bits/gcp-service-account?ref=v1.0.1 |  |
| lb-https | GoogleCloudPlatform/lb-http/google | 5.1.0 |
| lb-ilb | GoogleCloudPlatform/lb-internal/google | 4.0.0 |
| mig | github.com/terraform-google-modules/cloud-foundation-fabric.git//modules/compute-mig?ref=v4.8.0 |  |

## Resources

| Name | Type |
|------|------|
| [google_compute_instance_template.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_instance_template) | data source |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| location | (Required) Compute zone, or region if `regional` is set to true. | `string` | n/a | yes |
| name | (Optional) Managed group name. | `string` | n/a | yes |
| project\_id | (Required) The project ID in which the resources should be created | `string` | n/a | yes |
| subnet\_name | (Required) Name of subnetwork to be used | `string` | n/a | yes |
| vpc\_name | (Required) Name of VPC network to be used | `string` | n/a | yes |
| additional\_versions | (Optional) Additional application versions, target\_type is either 'fixed' or 'percent'. | <pre>map(object({<br>    instance_template = string<br>    target_type       = string # fixed | percent<br>    target_size       = number<br>  }))</pre> | `null` | no |
| auto\_healing\_policies | (Optional) Auto-healing policies for this group. Autohealing policies can use an externally defined health check, or have this module auto-create one | <pre>object({<br>    health_check      = string<br>    initial_delay_sec = number<br>  })</pre> | `null` | no |
| autoscaler\_config | (Optional) Autoscaler configuration. Only one of 'cpu\_utilization\_target' 'load\_balancing\_utilization\_target' or 'metric' can be not null. | <pre>object({<br>    max_replicas                      = number<br>    min_replicas                      = number<br>    cooldown_period                   = number<br>    cpu_utilization_target            = number<br>    load_balancing_utilization_target = number<br>    metric = object({<br>      name                       = string<br>      single_instance_assignment = number<br>      target                     = number<br>      type                       = string # GAUGE, DELTA_PER_SECOND, DELTA_PER_MINUTE<br>      filter                     = string<br>    })<br>  })</pre> | `null` | no |
| backends | (Optional) Map backend indices to list of backend maps. Default backend is created automatically when include\_default\_backend is true. | <pre>map(object({<br>    protocol  = string<br>    port      = number<br>    port_name = string<br><br>    description            = string<br>    enable_cdn             = bool<br>    security_policy        = string<br>    custom_request_headers = list(string)<br><br>    timeout_sec                     = number<br>    connection_draining_timeout_sec = number<br>    session_affinity                = string<br>    affinity_cookie_ttl_sec         = number<br><br>    health_check = object({<br>      check_interval_sec  = number<br>      timeout_sec         = number<br>      healthy_threshold   = number<br>      unhealthy_threshold = number<br>      request_path        = string<br>      port                = number<br>      host                = string<br>      logging             = bool<br>    })<br><br>    log_config = object({<br>      enable      = bool<br>      sample_rate = number<br>    })<br><br>    groups = list(object({<br>      group = string<br><br>      balancing_mode               = string<br>      capacity_scaler              = number<br>      description                  = string<br>      max_connections              = number<br>      max_connections_per_instance = number<br>      max_connections_per_endpoint = number<br>      max_rate                     = number<br>      max_rate_per_instance        = number<br>      max_rate_per_endpoint        = number<br>      max_utilization              = number<br>    }))<br>    iap_config = object({<br>      enable               = bool<br>      oauth2_client_id     = string<br>      oauth2_client_secret = string<br>    })<br>  }))</pre> | `null` | no |
| boot\_disk | Boot disk properties. Optional if 'existing\_instance\_template' is provided. | <pre>object({<br>    image = string<br>    size  = number<br>    type  = string<br>  })</pre> | <pre>{<br>  "image": "projects/debian-cloud/global/images/family/debian-10",<br>  "size": 10,<br>  "type": "pd-ssd"<br>}</pre> | no |
| default\_url\_request\_path | (Optional) Url request path for default backend | `string` | `"/"` | no |
| existing\_instance\_template | Instance template self-link. | `string` | `null` | no |
| firewall\_networks | (Required) Names of the networks to create firewall rules in, it defaults to 'default' VPC network. | `list(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| health\_check\_config | (Optional) auto-created health check configuration, use the output self-link to set it in the auto healing policy. Refer to examples for usage. | <pre>object({<br>    type    = string      # http https tcp ssl http2<br>    check   = map(any)    # actual health check block attributes<br>    config  = map(number) # interval, thresholds, timeout<br>    logging = bool<br>  })</pre> | `null` | no |
| ilb\_source\_tags | Source tags to be used for Firewall rule. Only applicable if lb\_type is INTERNAL | `list(string)` | `[]` | no |
| include\_default\_backend | (Optional) Include created MIG as a backend to the load balancer | `bool` | `true` | no |
| instance\_name | Instances base name. Optional if 'existing\_instance\_template' is provided. | `string` | `null` | no |
| instance\_service\_account\_id | Id of the service account identity which to be created with instance template. The value specified will automatically be suffixed by @<project\_id>.iam.gserviceaccount.com. Optional if 'existing\_instance\_template' is provided. | `string` | `"sa-instance-template-default"` | no |
| instance\_tag | Instance tag to be created. This tag is used as target\_tag while creating load balancers. This value is not used if 'existing\_instance\_template' is provided, where tags are fetched from existing\_instance\_template dynamically while creating the load balancer | `string` | `"mig-instance-default"` | no |
| instance\_type | Machine instance type to be created | `string` | `"f1-micro"` | no |
| labels | Instance labels. Optional if 'existing\_instance\_template' is provided. | `map(string)` | `{}` | no |
| lb\_name\_prefix | (Optional) Name for the forwarding rule and prefix for supporting resources. Should be non-null to create a HTTPS load balancer | `string` | `null` | no |
| lb\_port\_default | (Optional) Port number for default backend, it defaults to named\_ports value when null | `string` | `null` | no |
| lb\_protocol\_default | (Optional) Protocol for default backend, it defaults to named\_ports value when null | `string` | `null` | no |
| lb\_type | Type of load balancer to be created. Takes values either INTERNAL or EXTERNAL | `string` | `"NONE"` | no |
| metadata | Instance metadata. Optional if 'existing\_instance\_template' is provided. | `map(string)` | `{}` | no |
| named\_ports | (Optional) Named ports. Protocol being the key and port number being the value. It's first entry becomes the default backend values for Load Balancer. | `map(number)` | `null` | no |
| network\_interfaces | Network interfaces configuration. Use self links for Shared VPC, set addresses and alias\_ips to null if not needed. Optional if 'existing\_instance\_template' is provided. | <pre>list(object({<br>    nat        = bool<br>    network    = string<br>    subnetwork = string<br>    addresses = object({<br>      internal = list(string)<br>      external = list(string)<br>    })<br>    alias_ips = map(list(string))<br>  }))</pre> | `null` | no |
| other\_instance\_tags | Additional list of instance tags to be created. | `list(string)` | `[]` | no |
| region | Compute region. Optional if 'existing\_instance\_template' is provided. | `string` | `null` | no |
| regional | (Optional) Use regional instance group. When set, `location` should be same as the region. | `bool` | `false` | no |
| ssl\_certificates | (Required) SSL cert self\_link list. | `list(string)` | `[]` | no |
| startup\_script\_path | Name of start up script to be used, example: startup-scripts/configure\_syslog\_collector. Optional if 'existing\_instance\_template' is provided. | `string` | `null` | no |
| target\_pools | (Optional) list of URLs for target pools to which new instances in the group are added. | `list(string)` | `[]` | no |
| target\_size | (Optional) Group target size, sets to null when using an autoscaler. | `number` | `null` | no |
| update\_policy | (Optional) Update policy. Type can be 'OPPORTUNISTIC' or 'PROACTIVE', action 'REPLACE' or 'restart', surge type 'fixed' or 'percent'. | <pre>object({<br>    type                 = string # OPPORTUNISTIC | PROACTIVE<br>    minimal_action       = string # REPLACE | RESTART<br>    min_ready_sec        = number<br>    max_surge_type       = string # fixed | percent<br>    max_surge            = number<br>    max_unavailable_type = string<br>    max_unavailable      = number<br>  })</pre> | `null` | no |
| wait\_for\_instances | (Optional) Wait for all instances to be created/updated before returning. | `bool` | `true` | no |
| zones | (Optional) Compute zone, instance will cycle through the list, defaults to the 'b' zone in the region. Optional if 'existing\_instance\_template' is provided. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| elb-https | Details of external load balancer resource. |
| group\_manager | Instance group resource. |
| ilb | Details of internal load balancer resource. |
| instance\_template | Instance template resource. |
| mig\_autoscaler | Auto-created autoscaler resource. |
| mig\_health\_check | Auto-created health-check resource. |
