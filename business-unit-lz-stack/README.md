# GCP Landing Zone Business Unit Stack

This module is used as a blueprint to create and manage Landing Zone instances for each business unit or operating unit.

This module creates the following:

* a root Google Cloud folder for this landing zone
* three SDLC-specific folders to contain application projects
    * Dev-QA, Non-CDE, and CDE, all under the root LZ folder
* a BU Operations folder under the root LZ folder, containing:
    * a landing zone operations project to store LZ-specific operational resources such as Terraform state and Terraform service accounts
* three SDLC-specific Shared VPC host projects, for use by application projects as needed
* one "shared" Shared VPC host project, to be connected to all SDLC environments as needed
* one "lz-images" project to contain VM images, image build processes, and an LZ specific instance of GCR, with Twistlock service account granted permissions by default.
* any standardized organization policies, IAM policies, and user groups to support various Landing Zone operations
* a BU-specific Google Cloud service account for managing BU application projects for each SDLC folder and the Operations folder
* Kubernetes service accounts with workload identity bindings for each project and folder

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| google | ~> 3.45.0 |
| kubernetes | ~> 1.13.3 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 3.45.0 |
| kubernetes | ~> 1.13.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| automation\_project | github.com/terraform-google-modules/cloud-foundation-fabric//modules/project?ref=v4.3.0 |  |
| conhub\_spoke\_project | github.com/terraform-google-modules/cloud-foundation-fabric//modules/project?ref=v4.3.0 |  |
| conhub\_spoke\_vpc | github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc?ref=v4.3.0 |  |
| env\_svpc\_automation\_service\_accounts | github.com/terraform-google-modules/cloud-foundation-fabric//modules/iam-service-account?ref=v4.3.0 |  |
| env\_svpc\_hosts | github.com/terraform-google-modules/cloud-foundation-fabric//modules/project?ref=v4.3.0 |  |
| gcr | git::https://git.gp-archcon.com/tf-sharedmodules-internal/gcp-container-registry.git |  |
| images\_automation\_service\_account | github.com/terraform-google-modules/cloud-foundation-fabric//modules/iam-service-account?ref=v4.3.0 |  |
| images\_project | github.com/terraform-google-modules/cloud-foundation-fabric//modules/project?ref=v4.3.0 |  |

## Resources

| Name | Type |
|------|------|
| [google_billing_account_iam_member.binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/billing_account_iam_member) | resource |
| [google_folder.environment](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder) | resource |
| [google_folder.unit](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder) | resource |
| [google_folder_iam_binding.environment](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_iam_binding) | resource |
| [google_folder_iam_binding.unit](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_iam_binding) | resource |
| [google_folder_organization_policy.environments-boolean](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_organization_policy) | resource |
| [google_folder_organization_policy.environments-list](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_organization_policy) | resource |
| [google_folder_organization_policy.trusted-images](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_organization_policy) | resource |
| [google_folder_organization_policy.unit-boolean](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_organization_policy) | resource |
| [google_folder_organization_policy.unit-list](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_organization_policy) | resource |
| [google_project_iam_binding.conhub_peering_delegate](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | resource |
| [google_project_iam_binding.conhub_spoke_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | resource |
| [google_project_iam_member.env_svpc_automation_project_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.environment_automation_project_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.images_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.environment](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.workload_identity](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_storage_bucket.env_svpc_automation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket.images_automation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket.tfstate](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_binding.bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_binding) | resource |
| [google_storage_bucket_iam_member.images_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_member.member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [kubernetes_namespace.bu_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_role.environment_agent](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role) | resource |
| [kubernetes_role_binding.jenkins_agent](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [kubernetes_role_binding.lz_env_agent](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [kubernetes_service_account.lz_folder_sa](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.lz_images_sa](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.lz_svpc_sa](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| billing\_account\_id | Country billing account account. | `string` | n/a | yes |
| global\_automation\_project\_id | The global automation project ID for SAs and k8s namespaces, etc | `string` | n/a | yes |
| root\_node | Root node in folders/folder\_id or organizations/org\_id format. | `string` | n/a | yes |
| unit\_code | Buisness Unit Code (2-5 alpha-numeric characters) | `string` | n/a | yes |
| unit\_name | Top folder name. It must be between 3 and 30 characters, using only upper/lower case characters, numbers, underscores, hyphens, or spaces. | `string` | n/a | yes |
| automation\_project\_services | API services that will be enabled on the BU automation project. Removing any of the APIs in the default list will cause errors in the creation of resources as part of this module. | `list(string)` | <pre>[<br>  "cloudbilling.googleapis.com",<br>  "cloudresourcemanager.googleapis.com",<br>  "storage-component.googleapis.com",<br>  "secretmanager.googleapis.com",<br>  "cloudkms.googleapis.com",<br>  "containerregistry.googleapis.com"<br>]</pre> | no |
| business\_region | One of [na, ap, eu, uk] | `string` | `"na"` | no |
| conhub\_mgmt\_service\_accounts | n/a | <pre>object({<br>    devqa  = string<br>    noncde = string<br>    cde    = string<br>    shared = string<br>  })</pre> | <pre>{<br>  "cde": "pid-gcp-nets-ch-cde-1@pid-gcp-nets-lz-ops.iam.gserviceaccount.com",<br>  "devqa": "pid-gcp-nets-ch-devqa-1@pid-gcp-nets-lz-ops.iam.gserviceaccount.com",<br>  "noncde": "pid-gousgnag-nets-ch-noncde-1@pid-gcp-nets-lz-ops.iam.gserviceaccount.com",<br>  "shared": "pid-gcp-nets-ch-shared-1@pid-gcp-nets-lz-ops.iam.gserviceaccount.com"<br>}</pre> | no |
| country\_code | One of [us, cn, uk, in] | `string` | `"us"` | no |
| create\_billing\_iam\_bindings | If true, configure BU project provisioners to use provided billing account to create projects | `bool` | `true` | no |
| domain | Domain name for this G Suite organization | `string` | `"example.com"` | no |
| enable\_conhub | Boolean indicating whether to enable creation of Connectivity Hub components in this project | `bool` | `false` | no |
| enable\_gcr | Boolean indicating whether to enable GCR in the lz-images project. | `bool` | `false` | no |
| environment\_folder\_service\_account\_roles | IAM roles granted to the environment service account on the environment sub-folder. | `set(string)` | <pre>[<br>  "roles/compute.networkAdmin",<br>  "roles/owner",<br>  "roles/resourcemanager.folderAdmin",<br>  "roles/resourcemanager.projectCreator"<br>]</pre> | no |
| environments\_iam\_members | Map of `{ <environment> : { <role> : [members] } }` for any additional IAM bindings to apply to environment folders | <pre>object({<br>    devqa  = map(list(string)),<br>    noncde = map(list(string)),<br>    cde    = map(list(string)),<br>    ops    = map(list(string)),<br>  })</pre> | <pre>{<br>  "cde": {},<br>  "devqa": {},<br>  "noncde": {},<br>  "ops": {}<br>}</pre> | no |
| environments\_policy\_boolean | Map of environments, mapping boolean based organizational policies to apply to business unit folder | `map(map(bool))` | `{}` | no |
| environments\_policy\_list | Map of environments, mapping list/value based organizational policies to apply to business unit folder | <pre>map(map(object({<br>    inherit_from_parent = bool<br>    suggested_value     = string<br>    status              = bool<br>    values              = list(string)<br>  })))</pre> | `{}` | no |
| gcs\_defaults | Defaults use for the state GCS buckets. | `map(string)` | <pre>{<br>  "location": "US",<br>  "storage_class": "MULTI_REGIONAL"<br>}</pre> | no |
| images\_project\_service\_account\_roles | IAM roles granted to the automation service account for the *-lz-images project. | `set(string)` | <pre>[<br>  "roles/editor",<br>  "roles/resourcemanager.projectIamAdmin",<br>  "roles/compute.instanceAdmin",<br>  "roles/compute.networkAdmin",<br>  "roles/iam.serviceAccountAdmin",<br>  "roles/storage.admin",<br>  "roles/secretmanager.admin",<br>  "roles/iap.admin"<br>]</pre> | no |
| images\_project\_services | API services that will be enabled on the LZ images/GCR project. Removing any of the APIs in the default list will cause errors in the creation of resources as part of this module. | `list(string)` | <pre>[<br>  "storage-component.googleapis.com",<br>  "storage-api.googleapis.com",<br>  "containerregistry.googleapis.com",<br>  "compute.googleapis.com",<br>  "secretmanager.googleapis.com",<br>  "iam.googleapis.com"<br>]</pre> | no |
| labels | Required labels applied to LZ resouces | `map(string)` | `{}` | no |
| lz\_delegated\_conhub\_roles | Custom role for peeing between LZ lifecycle project and conhub spoke project | `list(string)` | <pre>[<br>  "organizations/155946218325/roles/PeeringDelegate"<br>]</pre> | no |
| scanning\_service\_account | Service account which will be granted permissions for scanning GCR in *-lz-images project of the LZ. | `string` | `"act-twistlock@pid-gousgggp-sec-scan01.iam.gserviceaccount.com"` | no |
| shared\_vpc\_host\_project\_services | API services that will be enabled on each of the Shared VPC host projects. | `list(string)` | <pre>[<br>  "cloudbilling.googleapis.com",<br>  "cloudresourcemanager.googleapis.com",<br>  "storage-component.googleapis.com",<br>  "secretmanager.googleapis.com"<br>]</pre> | no |
| trusted\_images\_projects | List of `projects/<project_id>` from which projects within this landing zone may pull GCE images. The LZ automation project will be included.  Do not use at same time as unit\_policy\_list compute.trustedImageProjects.  Only use one or the other. | `list(string)` | `[]` | no |
| unit\_iam\_members | IAM members for roles applied on the unit folder. | `map(list(string))` | `{}` | no |
| unit\_policy\_boolean | Map of boolean based organizational policies to apply to business unit folder | `map(bool)` | `{}` | no |
| unit\_policy\_list | Map of list/value based organizational policies to apply to business unit folder. NOTE: For policy compute.trustedImageProjects, only specify here or with the trusted\_images\_projects parameter, not both. | <pre>map(object({<br>    inherit_from_parent = bool<br>    suggested_value     = string<br>    status              = bool<br>    values              = list(string)<br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| unit\_automation\_project | n/a |
| unit\_environment\_folders | n/a |
| unit\_root\_folder | n/a |
| unit\_svpc\_projects | n/a |

# Disclaimer
Copyright 2021 your organisations. This software is provided for use by your organisations only.  Use for any other entity is forbidden.

This file generated by terraform-docs v0.12.1 or greater (https://github.com/terraform-docs/terraform-docs)
