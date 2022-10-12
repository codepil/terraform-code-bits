# Google Kubernetes Engine (GKE)

This building block is designed to create a GKE cluster deployment with private access, on its dedicated VPC network.

Control plane access is controlled through Proxy VM instance is created with, Identity Aware Proxy tunnel,
and firewall rule to allow SSH inbound.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| google | ~> 3.52.0 |
| google-beta | ~> 3.52.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| gke\_default\_pool | github.com/terraform-google-modules/cloud-foundation-fabric/modules/gke-nodepool | n/a |
| gke\_sbx\_cluster | github.com/terraform-google-modules/cloud-foundation-fabric/modules/gke-cluster | n/a |
| gke\_service\_account | github.com/terraform-google-modules/cloud-foundation-fabric/modules/iam-service-account | n/a |
| gke\_vpc | github.com/terraform-google-modules/cloud-foundation-fabric/modules/net-vpc | n/a |
| proxyvm | ../gcp-proxyvm | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| gke\_node\_zones | Zones in which GKE nodes will run | `list(string)` | n/a | yes |
| gke\_region | Default region for GKE cluster. This will be used in VPC subnet and GKE creation | `string` | n/a | yes |
| project\_id | The ID of the Google Cloud project that will contain the GKE sandbox cluster | `string` | n/a | yes |
| vm\_region | Compute region. | `string` | n/a | yes |
| boot\_disk\_image | Boot disk image.  May be specific image or image family | `string` | `"projects/debian-cloud/global/images/family/debian-10"` | no |
| boot\_disk\_size | Boot disk size in GB | `string` | `"20"` | no |
| gke\_autoscaling\_config | GKE autoscaling configuration. | <pre>object({<br>    min_node_count = number<br>    max_node_count = number<br>  })</pre> | <pre>{<br>  "max_node_count": 3,<br>  "min_node_count": 1<br>}</pre> | no |
| gke\_cluster\_name | Name of the GKE cluster | `string` | `"gke-default-cluster"` | no |
| gke\_ip\_cidr | IP range for primary (non-aliased) GKE IPs | `string` | `"10.0.0.0/24"` | no |
| gke\_machine\_type | Machine type for default node pool | `string` | `"n1-standard-2"` | no |
| gke\_master\_authorized\_ranges | IP address ranges that can access the Kubernetes cluster master through HTTPS. | `map` | <pre>{<br>  "internal-vms": "10.0.0.0/8"<br>}</pre> | no |
| gke\_master\_cidr | IP range for GKE master nodes. This range must be non-overlapping with other subnet ranges in the VPC or peered VPCs. | `string` | `"192.168.1.0/28"` | no |
| gke\_pod\_cidr | IP range for GKE pod IPs | `string` | `"172.16.0.0/20"` | no |
| gke\_pods\_per\_node | Max pods per node on default node pool | `number` | `64` | no |
| gke\_service\_account\_name | Name of the service account identity which to be created to manage GKE cluster | `string` | `"sa-gke-default"` | no |
| gke\_service\_cidr | IP range for GKE service IPs | `string` | `"192.168.0.0/24"` | no |
| gke\_subnet\_name | Name of the sub network to be created | `string` | `"gke-default-subnet"` | no |
| gke\_vpc\_name | Name of the VPC network to be created for hosting GKE cluster | `string` | `"gke-default-vpc"` | no |
| instance\_count | The number of proxy VMs to create. | `number` | `1` | no |
| instance\_type | Instance type. | `string` | `"f1-micro"` | no |
| labels | Any additional labels that should be included in the LZ resources | `map(string)` | `{}` | no |
| members | List of users, groups, or service accounts that are allowed access to the proxy VM using the IAP tunnel. The GCP account deploying this code is automatically appended to this list.  Entries should have appropriate 'user:', 'group:', or 'serviceAccount:' prefixes. | `list(string)` | `[]` | no |
| tags | Instance network tags. | `list(string)` | `[]` | no |
| vm\_name | Instances base name. | `string` | `"proxyvm-default"` | no |
| vm\_zones | Compute zone, instance will cycle through the list, defaults to the 'b' zone in the region. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| external\_ips | Instance main interface external IP addresses. |
| instance\_names | Instance names. |
| internal\_ips | Instance main interface internal IP addresses. |
| self\_links | Instance self links. |
| service\_account\_email | Service account email. |
| service\_account\_iam\_email | Service account email. |
