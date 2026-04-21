Wrapper around terraform-google-network, with some  specific mandatory add-ons:
* default firewall rules
* default prescribed subnet ranges
* flow logging

## Pre-requisites
1) Enable below Project service APIs
* dns.googleapis.com, if enable\_private\_access\_routing is true

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud-dns"></a> [cloud-dns](#module\_cloud-dns) | terraform-google-modules/cloud-dns/google | 3.1.0 |
| <a name="module_generate_subnets"></a> [generate\_subnets](#module\_generate\_subnets) | ./modules/generate-subnets |  |
| <a name="module_nat"></a> [nat](#module\_nat) | ./modules/gcp-cloud-nat |  |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | github.com/terraform-google-modules/terraform-google-network |  |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.allow_pga_api_all_egress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.project_firewall_deny_egress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.project_firewall_deny_ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.project_firewall_internal_egress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_nat"></a> [create\_nat](#input\_create\_nat) | Boolean indicating whether Cloud Nat should be configured. This will include a cloud router, one or more external static IP addresses, and cloud NAT resources. | `bool` | `false` | no |
| <a name="input_enable_private_access_routing"></a> [enable\_private\_access\_routing](#input\_enable\_private\_access\_routing) | Enable whether special routes are automatically added to enable private access. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The lifecycle of this project.  Valid values are: dev, qa, cert-ncde (non-cde), prod-ncde (non-cde), cert-cde, prod-cde, or svcs (shared services). | `string` | n/a | yes |
| <a name="input_existing_nat_addresses"></a> [existing\_nat\_addresses](#input\_existing\_nat\_addresses) | List of google\_compute\_address resource selflinks for the reserved IP addresses to use for Cloud NAT.  This overrides number\_nat\_addresses and no new IPs would be reserved. | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the VPC to be created. Should contain lowercase letters, numbers, and dashes only. | `string` | n/a | yes |
| <a name="input_number_nat_addresses"></a> [number\_nat\_addresses](#input\_number\_nat\_addresses) | The number of external static IP addresses to configure for Cloud NAT. | `number` | `1` | no |
| <a name="input_private_access_dns_entries"></a> [private\_access\_dns\_entries](#input\_private\_access\_dns\_entries) | Create Cloud DNS entries, by defining entries in key-value format. Key being domain name and value being the subdomain name. This is required when enable\_private\_access\_routing is true. | `map(string)` | <pre>{<br>  "appspot.com": "appspot.com",<br>  "cloudproxy.app": "tunnel.cloudproxy.app",<br>  "gcr.io": "gcr.io",<br>  "googleapis.com": "private.googleapis.com",<br>  "run.app": "run.app"<br>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project ID in which to deploy the VPC and its subnets. | `string` | n/a | yes |
| <a name="input_routes"></a> [routes](#input\_routes) | List of routes represented as map. | `list(map(string))` | `[]` | no |
| <a name="input_secondary_ranges"></a> [secondary\_ranges](#input\_secondary\_ranges) | Map of subnets listing maps of secondary ranges | <pre>map(list(object({<br>    range_name    = string<br>    ip_cidr_range = string<br>  })))</pre> | `{}` | no |
| <a name="input_subnet_flow_logs"></a> [subnet\_flow\_logs](#input\_subnet\_flow\_logs) | Configure flow log capture parameters for all subnets. | <pre>object({<br>    subnet_flow_logs          = string # "true" to enable flow logs<br>    subnet_flow_logs_interval = string # Aggregation interval<br>    subnet_flow_logs_sampling = string # Sample rate of VPC flow logs<br>    subnet_flow_logs_metadata = string # Metadata to be included<br>  })</pre> | <pre>{<br>  "subnet_flow_logs": "true",<br>  "subnet_flow_logs_interval": "INTERVAL_5_SEC",<br>  "subnet_flow_logs_metadata": "INCLUDE_ALL_METADATA",<br>  "subnet_flow_logs_sampling": "0.5"<br>}</pre> | no |
| <a name="input_subnet_regions"></a> [subnet\_regions](#input\_subnet\_regions) | List of regions in which to create subnets within the VPC, using a predefined subnet structure.  Specify this or vpc\_custom\_subnets, otherwise no subnets will be created. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nat_ips"></a> [nat\_ips](#output\_nat\_ips) | Selflinks to static IPs that were reserved.  Note, if no IPs were created, empty list is returned. |
| <a name="output_nat_names"></a> [nat\_names](#output\_nat\_names) | Names of the google\_compute\_router\_nats that was created. |
| <a name="output_nat_router_names"></a> [nat\_router\_names](#output\_nat\_router\_names) | Names of the google\_computer\_routers that was created. |
| <a name="output_network"></a> [network](#output\_network) | Selflink of the vpc created. |
| <a name="output_network_name"></a> [network\_name](#output\_network\_name) | Simple name of the vpc created. |
| <a name="output_route_names"></a> [route\_names](#output\_route\_names) | List of the route names created. |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | Map of all subnets created.  Keyed by subnet\_region/subnet\_name, values being outputs of google\_copute\_subnet resources that were created. |
