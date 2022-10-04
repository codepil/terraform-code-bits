## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| google | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| existing\_nat\_addresses | List of google\_compute\_address resource selflinks for the reserved IP addresses to use.  This overrides number\_nat\_addresses and no new IPs would be reserved. | `list(string)` | `[]` | no |
| nat\_name | Name to use for the Cloud Nat resource. | `string` | n/a | yes |
| network | Network that this cloud NAT should be setup within. Specify the full path/selflink | `string` | n/a | yes |
| number\_nat\_addresses | The number of external static IP addresses to configure for Cloud NAT.  If "existing\_nat\_addresses" is specified, this is ignored. | `number` | `1` | no |
| project\_id | The GCP project ID in which to deploy the VPC and its subnets. | `string` | n/a | yes |
| region | Region that this cloud NAT should be setup within.  This should align with the subnets to which this will provide NAT services. | `string` | n/a | yes |
| router\_name | Name to use for the auto-created cloud router resource. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| addresses | Selflinks to static IPs that were reserved.  Note, if no IPs were created, empty list is returned. |
| name | Name of the google\_compute\_router\_nat that was created. |
| router\_name | Name of the google\_computer\_router that was created. |

