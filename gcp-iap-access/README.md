# gcp-iap

This module provisions IAP, and adds member identities to access given VM instances or MIG

## Pre-requisites
* API project services are to be enabled
  * iap.googleapis.com
* Project should have Oauth consent done.
## Roles
* 'roles/resourcemanager.projectIamAdmin' and 'roles/iap.admin' to create IAP policies and add members respectively
## Next steps
* Users can use tools mentioned in https://cloud.google.com/iap/docs/using-tcp-forwarding document to Tunnel the connection.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.7 |
| google | >= 3.65.0 |

## Providers

| Name | Version |
|------|---------|
| google | >= 3.65.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.iap-sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.iap-tags](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_iap_tunnel_instance_iam_binding.mig](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_tunnel_instance_iam_binding) | resource |
| [google_iap_tunnel_instance_iam_binding.vm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_tunnel_instance_iam_binding) | resource |
| [google_client_openid_userinfo.provider_identity](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_openid_userinfo) | data source |
| [google_compute_region_instance_group.data_source](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_region_instance_group) | data source |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| network | (Required) Self link to the network in which FW rules are defined to allow IAP traffic | `string` | n/a | yes |
| project\_id | (Required) The project ID in which the IAP should be enabled | `string` | n/a | yes |
| base\_priority | (Optional) Sets the base priority floor value for the created firewall rules. | `number` | `1000` | no |
| mig\_access | (Optional) Access object to create access list for Managed Instance Group. Example of mig\_name being 'https://www.googleapis.com/compute/v1/projects/pid-gcp-tlz-pavan-5231/regions/us-east4/instanceGroupManagers/suricata-igm' | <pre>object({<br>    mig_name = string<br>    members  = list(string)<br>  })</pre> | `null` | no |
| target\_service\_accounts | (Optional) List of SA used in creating VM instances. If neither targetServiceAccounts nor targetTags are specified, the firewall rule applies to all instances on the specified network | `list(string)` | `null` | no |
| target\_tags | (Optional) List of Tags used in VM instances. If neither targetServiceAccounts nor targetTags are specified, the firewall rule applies to all instances on the specified network | `list(string)` | `null` | no |
| vm\_access | (Optional) Access object to create access list for list of VM instances, in key value pair format. Example instance being 'projects/pid-gcp-tlz-pavan-5231/zones/us-east4-c/instances/suricata-igm-7558' | `map(list(string))` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| mig-vms | n/a |
