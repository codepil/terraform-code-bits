# gcp-logicmonitor-collector

This module creates an Logic monitor collector infrastructure given a GCP Project/VPC network.

Below infrastructure is created by the module,
* Un Managed Instance Group & VM instance based on image\_url and instance\_type
* Firewall rule for UDP ports used by collector ("162" #snmap traps, "2055" #netflow, "6343" #sflow)
* IAP tunnel firewall for Windows RDP port 3389, and SSH 22
* IAM binding for given user to use IAP

Use https://cloud.google.com/iap/docs/using-tcp-forwarding#gcloud_3 to connect to VM.

## Limitations
* Given that validity of LM collector binary is only 2 hrs & no silent installation option for Windows image,
installing Collector on GCP infra is going to be a manual task.
* Linux collector image would be possible to silent-install but this type of collector wouldn't help to collect metrics from Windows instance

Given above limitations, metadata handling and startup\_scripts in template folder in this module is commented out, and users are suggested to use IAP and steps in https://cloud.google.com/iap/docs/using-tcp-forwarding#gcloud_3 to connect to VM, to install. Collector binary is downloadable from https://heartland.logicmonitor.com/santaba/uiv3/setting/index.jsp(at settings, at collector, Add, select type ..etc) using Test SSO.

Also Managed Instance Group (MIG) is not supported for the same reasons.

## Pre-requisites
* Project should have enabled Compute Engine API (compute.googleapis.com).
* Recommended to use Test's golden images for image\_url, if so then Cloud service account (i.e., <prj\_id>@cloudservices.gserviceaccount.com) is to be added to Test golden images project for accessing Test Golden images.
## Reference
* https://www.logicmonitor.com/support/rest-api-developers-guide/v1/collectors/downloading-a-collector-installer#Installation
* to-do manually https://heartland.logicmonitor.com/santaba/uiv3/setting/index.jsp

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.7 |
| google | = 3.65.0 |
| google-beta | = 3.65.0 |

## Providers

| Name | Version |
|------|---------|
| google | = 3.65.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| lm\_collector\_vms | github.com/terraform-google-modules/cloud-foundation-fabric.git//modules/compute-vm |  |
| lm\_instance\_service\_account | git::https://github.com/codepil/terraform-code-bits/gcp-service-account?ref=v1.0.1 |  |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.iap](https://registry.terraform.io/providers/hashicorp/google/3.65.0/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.lm_fw](https://registry.terraform.io/providers/hashicorp/google/3.65.0/docs/resources/compute_firewall) | resource |
| [google_iap_tunnel_instance_iam_binding.enable_iap](https://registry.terraform.io/providers/hashicorp/google/3.65.0/docs/resources/iap_tunnel_instance_iam_binding) | resource |
| [google_client_openid_userinfo.provider_identity](https://registry.terraform.io/providers/hashicorp/google/3.65.0/docs/data-sources/client_openid_userinfo) | data source |
| [google_compute_subnetwork.lm-subnetwork](https://registry.terraform.io/providers/hashicorp/google/3.65.0/docs/data-sources/compute_subnetwork) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| collector\_name\_prefix | (Required) Prefix string to be used for all VM/resources created by this module | `string` | n/a | yes |
| labels | Required labels applied to all resources | <pre>object({<br>    costcenter         = string<br>    dataclassification = string<br>    eol_date           = string<br>    lifecycle          = string<br>    service_id         = string<br>  })</pre> | n/a | yes |
| project\_id | (Required) The project ID in which the resources should be created | `string` | n/a | yes |
| region | (Required) Region where all resources will be deployed | `string` | n/a | yes |
| subnet\_name | (Required) Name of subnetwork to be attached to the VMs | `string` | n/a | yes |
| vpc\_name | (Required) Name of GCP VPC network to deploy resources into | `string` | n/a | yes |
| zones | (Required) List of zones in which to create VMs and instance groups | `list(string)` | n/a | yes |
| additional\_source\_network\_ip\_ranges | (Optional) Custom list of IP ranges, other than specified in 'sub\_network', to allow traffic to LM collectors | `list(string)` | `[]` | no |
| boot\_disk | (Required) Boot disk properties | <pre>object({<br>    image = string<br>    size  = number<br>    type  = string<br>  })</pre> | <pre>{<br>  "image": "projects/pid-gousgggp-ssvc-os-images/global/images/windows-2016-v2021080622-golden",<br>  "size": 40,<br>  "type": "pd-ssd"<br>}</pre> | no |
| collector\_instance\_type | (Required) Instance type to be created. Refer to https://www.logicmonitor.com/support/collectors/collector-overview/collector-capacity | `string` | `"f1-micro"` | no |
| collector\_login\_users | List of users, groups, or service accounts that are allowed access to the collector VM using the IAP tunnel. The GCP account deploying this code is automatically appended to this list.  Entries should have appropriate 'user:', 'group:', or 'serviceAccount:' prefixes. Use https://cloud.google.com/iap/docs/using-tcp-forwarding#gcloud_3 to connect to VM. | `list(string)` | `[]` | no |
| collectors\_per\_zone | Number of VM instances to create in each zone | `number` | `1` | no |
| other\_vm\_instance\_tags | (Optional) Custom list of instance tags to be created | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| lm\_vms | List of LM collector instances created |
