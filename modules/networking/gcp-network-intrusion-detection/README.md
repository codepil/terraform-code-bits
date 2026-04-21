# gcp-network-intrusion-detection
This module deploys an instance group via an instance template, packet mirroring, and the required backend services and firewalls to allow for the targeting and mirroring of traffic to facilitate an IDS service.
Traffic can be targeted by either subnet, instance, or instance tag. The targeted traffic is reflected to the instance group and is visible to the network adapters of those instances.
Suricata is presently the IDS configured to be deployed in the instance group by this module. Suricata operates on lists of rules to evaluate traffic. Public sets of rules are commonly used; however, custom rules can be written and applied as well.
The [Suricata-Update](https://github.com/OISF/suricata-update) tool was created to assist with the update and management of rule sets.

## Pre-requisites
* The collector and mirrored sources must be in the same region.
* Below API project services are to be enabled on the '<project\_id>'
  * compute.googleapis.com
* Compute instance Service Account is to be created, say suricata-ids@'<project\_id>'.iam.gserviceaccount.com. And same is provisioned to be accessing '<gcs\_bucket>'. Refer to module [ids-configuration-infrastructure](https://github.com/codepil/terraform-code-bits/ids-configuration-infrastructure/-/tree/main) for further details.
* Cloud service account (i.e., '<project\_id>'@cloudservices.gserviceaccount.com ) is to be added to golden images project for accessing Golden images.

## Assumptions/Dependencies
* Golden image is been created using latest Suricata binary installed, and with fluentd configurations to parse suricata.log and fast.log files.
* IDS/Suricata configuration files should be present on '<gcs\_bucket>/<config\_dir>' location. Refer to module [ids-configurations](https://github.com/codepil/terraform-code-bits/ids-configurations) for further details.
  * suricata.yaml
  * '<signature\_file\_name>' (ex: etpro.rules.tar.gz)
  * custom\_log.conf, if any
## Notes for module consumption
* Review your network deployment model for collector and packer mirroring policy, and accordingly model TF input. Refer to [doc](https://cloud.google.com/blog/products/networking/using-packet-mirroring-with-ids) for the details.
* Autoscaling defaults are not load tested, only indicative and adjusted based on POV in test environment.
* Set 'create\_firewall\_rules' to false, if your project would like to manage FW rules separately.
* Review the MIG instance update default policies and change them accordingly.
* Currently 'signature\_file\_name' is a single field. If there are multiple bundles, please combine and provide single source file name.
* TODO: [US255652] default tags used in log configurations are to be reviewed, while developing log sink for Splunk. Change shall go to golden image.
* Provisioning IAP is a separate module ([gcp-iap](https://github.com/codepil/terraform-code-bits/gcp-iap)), its only required for executing suricate-update CLI commands on the node, preferred to use either Bastion or Jump server for that purpose in production. Raise merge request on this module if the changes are useful for other BUs.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.5 |
| google | >= 3.65 |

## Providers

| Name | Version |
|------|---------|
| google | >= 3.65 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| mig | github.com/terraform-google-modules/cloud-foundation-fabric.git//modules/compute-mig?ref=v7.0.0 |  |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.ids](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.mig-hc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_forwarding_rule.ids](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_instance_template.ids](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) | resource |
| [google_compute_packet_mirroring.ids](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_packet_mirroring) | resource |
| [google_compute_region_backend_service.ids](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_backend_service) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| config\_dir | (Required) Directory path containing Suricate configuration files from GCS bucket | `string` | n/a | yes |
| gcs\_bucket | (Required) Name of GCS bucket, which contains files for Suricate configuration | `string` | n/a | yes |
| ids\_service\_account\_email | (Required) Service account email, for which GCS bucket access is already been provisioned | `string` | n/a | yes |
| network | A Network id where the IDS will be deployed | `string` | n/a | yes |
| project | Project ID in which to deploy the IDS, a host project in case of shared VPC | `string` | n/a | yes |
| region | The Region where the IDS will be deployed - must correspond with the subnet | `string` | n/a | yes |
| signature\_file\_name | (Required) Name of the file which contains rules from ProofPoint signature bundle, which to be added as a source to Suricata rules | `string` | n/a | yes |
| subnet | A Subnet self-link where the IDS will be deployed | `string` | n/a | yes |
| traffic\_source\_ranges | (Required) List of source IPs/CIDR ranges from which mirrored traffic is expected | `list(string)` | n/a | yes |
| autoscaler\_config | (Optional) Autoscaler configuration. Only one of 'cpu\_utilization\_target' 'load\_balancing\_utilization\_target' or 'metric' can be not null. | <pre>object({<br>    max_replicas                      = number<br>    min_replicas                      = number<br>    cooldown_period                   = number # in secs<br>    cpu_utilization_target            = number<br>    load_balancing_utilization_target = number<br>    metric = object({<br>      name                       = string<br>      single_instance_assignment = number<br>      target                     = number<br>      type                       = string # GAUGE, DELTA_PER_SECOND, DELTA_PER_MINUTE<br>      filter                     = string<br>    })<br>  })</pre> | <pre>{<br>  "cooldown_period": 180,<br>  "cpu_utilization_target": 0.65,<br>  "load_balancing_utilization_target": null,<br>  "max_replicas": 3,<br>  "metric": null,<br>  "min_replicas": 1<br>}</pre> | no |
| base\_priority | Sets the base priority floor value for the created firewall rules. Rules will increment upward (higher priority) from this floor. | `number` | `1000` | no |
| boot\_disk\_size | (Optional) Size of a boot disk, in GB | `number` | `20` | no |
| boot\_disk\_type | (Optional) The GCE disk type. Can be either 'pd-ssd', 'local-ssd', 'pd-balanced' or 'pd-standard' | `string` | `"pd-ssd"` | no |
| create\_firewall\_rules | Should this module create firewall rules | `bool` | `true` | no |
| filter | A common filter policy for mirrored traffic | <pre>object({<br>    ip_protocols = list(string)<br>    cidr_ranges  = list(string)<br>    direction    = string<br>  })</pre> | <pre>{<br>  "cidr_ranges": [<br>    "0.0.0.0/0"<br>  ],<br>  "direction": "BOTH",<br>  "ip_protocols": [<br>    "tcp",<br>    "udp",<br>    "icmp"<br>  ]<br>}</pre> | no |
| instance\_type | Machine instance type to be created | `string` | `"e2-medium"` | no |
| labels | Instance labels. | `map(string)` | `{}` | no |
| linux\_os\_type | Linux OS type, defaults to Ubuntu. Currently supported OS types are debian and ubuntu. Installer script get picked based on OS type. | `string` | `"ubuntu"` | no |
| mirroring\_policies | List of policies with required resources targeted for mirroring | <pre>map(object({<br>    project_id    = string<br>    vpc_name      = string<br>    subnets       = list(string)<br>    instance_tags = list(string)<br>    instances     = list(string)<br>  }))</pre> | `{}` | no |
| policy\_project | Project ID in which to deploy the Packet mirroring policy, a host project ID in case of shared VPC and Peered project ID in case of VPC Peering. It defaults to <project> value. | `string` | `null` | no |
| prefix | A word to use as a common prefix on all resources deployed | `string` | `"suricata"` | no |
| source\_image\_url | (Required) Boot image self-link, which is used for creating VM instances. Preferred to use provided golden images | `string` | `"pid-gcp-ssvc-os-images/gold-ids-ubuntu-1804-lts"` | no |
| update\_policy | (Optional) Update policy. Type can be 'OPPORTUNISTIC' or 'PROACTIVE', action 'REPLACE' or 'restart', surge type 'fixed' or 'percent'. Refer to https://cloud.google.com/compute/docs/instance-groups/rolling-out-updates-to-managed-instance-groups for more details | <pre>object({<br>    type                 = string # OPPORTUNISTIC | PROACTIVE<br>    minimal_action       = string # REPLACE | RESTART<br>    min_ready_sec        = number<br>    max_surge_type       = string # fixed | percent<br>    max_surge            = number<br>    max_unavailable_type = string<br>    max_unavailable      = number<br>  })</pre> | <pre>{<br>  "max_surge": 4,<br>  "max_surge_type": "fixed",<br>  "max_unavailable": 0,<br>  "max_unavailable_type": "fixed",<br>  "min_ready_sec": 30,<br>  "minimal_action": "REPLACE",<br>  "type": "PROACTIVE"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| mig | Suricata instance group manager |
| packet\_mirroring\_policies | Packet mirroring policy identifier |
