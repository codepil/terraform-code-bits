# gcp-syslog-collector

This module creates an syslog collector infrastructure to receive syslog messages from source systems/forwarders.
Syslog forwarder can configure either through TCP or UDP protocol, on port 514 with IP address from either (TCP/UDP) of Load Balancers created by this module.

Below infrastructure is created by the module,
* Managed Instance Group (MIG) stack for syslog-collector
* Internal Load Balancer group for TCP & UDP on port 514, with necessary health checks

## Pre-requisites
* Project should have enabled Compute Engine API (compute.googleapis.com).

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.7 |
| google | = 3.65.0 |
| google-beta | = 3.65.0 |

## Providers

| Name | Version |
|------|---------|
| local | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| mig-syslog-collector | git::https://github.com/codepil/terraform-code-bits/gcp-compute-mig-stack.git?ref=v1.1.0 |  |

## Resources

| Name | Type |
|------|------|
| [local_file.startup](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | (Required) Prefix name for infrastructure created. | `string` | n/a | yes |
| project\_id | (Required) The project ID in which the resources should be created | `string` | n/a | yes |
| region | (Required) Compute region. | `string` | n/a | yes |
| subnet\_name | (Required) Name of subnetwork to be used | `string` | n/a | yes |
| vpc\_name | (Required) Name of VPC network to be used | `string` | n/a | yes |
| zones | (Required) Compute zone, instance will cycle through the list, defaults to the 'b' zone in the region. | `list(string)` | n/a | yes |
| autoscaler\_config | (Optional) Autoscaler configuration. Only one of 'cpu\_utilization\_target' 'load\_balancing\_utilization\_target' or 'metric' can be not null. | <pre>object({<br>    max_replicas                      = number<br>    min_replicas                      = number<br>    cooldown_period                   = number<br>    cpu_utilization_target            = number<br>    load_balancing_utilization_target = number<br>    metric = object({<br>      name                       = string<br>      single_instance_assignment = number<br>      target                     = number<br>      type                       = string # GAUGE, DELTA_PER_SECOND, DELTA_PER_MINUTE<br>      filter                     = string<br>    })<br>  })</pre> | <pre>{<br>  "cooldown_period": 30,<br>  "cpu_utilization_target": 0.65,<br>  "load_balancing_utilization_target": null,<br>  "max_replicas": 3,<br>  "metric": null,<br>  "min_replicas": 1<br>}</pre> | no |
| boot\_disk | (Required) Boot disk properties. | <pre>object({<br>    image = string<br>    size  = number<br>    type  = string<br>  })</pre> | <pre>{<br>  "image": "projects/rhel-cloud/global/images/rhel-7-v20210721",<br>  "size": 20,<br>  "type": "pd-ssd"<br>}</pre> | no |
| instance\_type | (Required) Machine instance type to be created | `string` | `"f1-micro"` | no |
| lb\_source\_tags | (Required) Source tags to be used for Firewall rule. Its same as syslog forwarding client/source instance tag | `list(string)` | <pre>[<br>  "syslog-client"<br>]</pre> | no |
| other\_instance\_tags | (Optional) Custom list of instance tags to be created. | `list(string)` | `[]` | no |
| regional | (Optional) Use regional instance group. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| group\_manager\_id | Instance group resource identifier |
| tcp\_lb\_ip\_address | IP address of TCP load balancer |
| udp\_lb\_ip\_address | IP address of UDP load balancer |
