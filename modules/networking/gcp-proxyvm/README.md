# Proxy VM for private GKE cluster/Jenkins Agents access

This building block is designed to create a proxy-VM aka a jump server with appropriate ingress controls,
to enable access the resources like a private GKE cluster and a compute instance without external IP.
User access by default is provisioned to LZ Jenkins' workload identity user.

This module creates a linux VM, IAP and related Firewall rules to allow SSH inbound connection.
It optionally provisions Cloud instance schedule component's IAM permissions which control the automated shutdown/startup of proxy-VM instances as needed by Jenkins pipeline. Users can enable this functionality by using enable\_scheduler\_permissions flag.

Users can use steps mentioned in https://cloud.google.com/iap/docs/using-tcp-forwarding document to access proxy-VM.

## Pre-requisites
1) Firewall rules in a given VPC should be allowing internal VM to VM communication, inorder for Proxy VM to reach compute infrastructure.
2) Automation SA should be having equivalent of 'roles/iam.roleAdmin' to create custom IAM roles, if enable\_scheduler\_permissions is true.
3) Automation SA should be having equivalent of 'roles/resourcemanager.projectIamAdmin' and 'roles/iap.admin' to create IAP policies and add members
4) Project service APIs for compute.googleapis.com & iap.googleapis.com are enabled.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_linuxvm"></a> [linuxvm](#module\_linuxvm) | github.com/terraform-google-modules/cloud-foundation-fabric.git//modules/compute-vm?ref=v4.4.2 |  |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.iap](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_iap_tunnel_instance_iam_binding.enable_iap](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_tunnel_instance_iam_binding) | resource |
| [google_project_iam_custom_role.schedule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_member.compute_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [random_id.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [google_client_openid_userinfo.provider_identity](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_openid_userinfo) | data source |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Instances base name. | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Selflink to the network in which to deploy. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project id. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Compute region. | `string` | n/a | yes |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | Selflink to the subnetwork in which to deploy | `string` | n/a | yes |
| <a name="input_boot_disk_image"></a> [boot\_disk\_image](#input\_boot\_disk\_image) | Boot disk image.  May be specific image or image family | `string` | `"projects/debian-cloud/global/images/family/debian-10"` | no |
| <a name="input_boot_disk_size"></a> [boot\_disk\_size](#input\_boot\_disk\_size) | Boot disk size in GB | `string` | `"20"` | no |
| <a name="input_enable_scheduler_permissions"></a> [enable\_scheduler\_permissions](#input\_enable\_scheduler\_permissions) | Provision cloud instance scheduler permissions to start/stop proxyVM instances | `bool` | `false` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | The number of proxy VMs to create. | `number` | `1` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type. | `string` | `"f1-micro"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Instance labels. | `map(string)` | `{}` | no |
| <a name="input_members"></a> [members](#input\_members) | List of users, groups, or service accounts that are allowed access to the proxy VM using the IAP tunnel. The GCP account deploying this code is automatically appended to this list.  Entries should have appropriate 'user:', 'group:', or 'serviceAccount:' prefixes. | `list(string)` | `[]` | no |
| <a name="input_metadata"></a> [metadata](#input\_metadata) | Instance metadata. | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Instance network tags. | `list(string)` | `[]` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Compute zone, instance will cycle through the list, defaults to the 'b' zone in the region. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_external_ips"></a> [external\_ips](#output\_external\_ips) | Instance main interface external IP addresses. |
| <a name="output_instance_names"></a> [instance\_names](#output\_instance\_names) | Instance names. |
| <a name="output_internal_ips"></a> [internal\_ips](#output\_internal\_ips) | Instance main interface internal IP addresses. |
| <a name="output_self_links"></a> [self\_links](#output\_self\_links) | Instance self links. |
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | Service account email. |
| <a name="output_service_account_iam_email"></a> [service\_account\_iam\_email](#output\_service\_account\_iam\_email) | Service account email. |
