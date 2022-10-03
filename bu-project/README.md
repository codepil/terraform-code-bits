# GCP Landing Zone - Terraform project creation module
This module creates the following:
* a project under the specified environment folder (`devqa`, `noncde`, `cde`, or `ops`)
* a dedicated service account for subsequent applicaiton deployment (in the LZ's automation project)
* a dedicated GCS bucket for storing project Terraform state (in the LZ's automation project)
* workload identity bindings for pipeline executions as the dedicated service account
* Google Cloud APIs enabled per the `project_services` variable
* project-level IAM and organization policies as defined in Terraform variables
To-Do:
* configure default network using the gcp-vpc shared module
* configure IAM access (compute image user) to gold image project
* configure IAM access to GCR

## Examples
Example parameters are in the examples/ folder.

## Project Naming
Once project names are set, THEY CANNOT BE CHANGED.  Thus it is important to understand the nuances to naming a project properly before creating one.

There are 2 ways to specify a project name.  Either through an explicit parameter, project\_name, or having the module generate a standard project name for you via some parameters (geo\_location, region, business\_region, project\_descriptor).  

Both example below result in the same project\_name, pid-gcp-exbu-res01.

### Explicit Naming
```hcl
unit_name            = "exbu"
environment          = "dev"
project_name         = "pid-gcp-exbu-res01"
randomize_project_id = false
```

### Programatically Generated Naming
```hcl
unit_name = "exbu"
environment = "dev"
geo_location = "us"
region = "e"
business_region = "na"
project_descriptor = "res01"    # "res01" is the default for this parameter
randomize_project_id = false
```
NOTE: The unit\_code and environment parameters are used in the programatic name generation, but are also required parameters for additional reasons other than naming.  See below for randomize\_project\_id.

### Randomized Project Name
By default, project names (generated or specified) have a random 4 digit hexadecimal identifier (ie, "-4e9f") appended to them resulting in something like "pid-gcp-exbu-res01-4e9f".  The original intent was to enable quick spin-up of many projects of the same base name.  If you do not want this (which is common), specify `ramdomize_project_id=false` in your project manifests.  This option works with both explicit and programatic project name generation.

### Project Descriptor
By default, GCP projects historically used a descriptor of "res01" which allowed for simple incrementing as new projects of similar base name were created (ie, pid-gcp-exbu-res01, pid-gcp-exbu-res02, and so on).  GCP LZ is enabling the customization of that suffix to be more functionally descriptive.  ie, setting project\_descriptor to "poc-myapp" above would generate "pid-gcp-exbu-poc-myapp" then another manifest with project\_descriptor of "dev-myapp" would generate "pid-gcp-exbu-dev-myapp" which would help quickly identify which project was the PoC vs Dev project.

### Project Name Length
It is also important to note that GCP project names must be 30 characters or less, and the your organisations standard pid-goXXXXXX-UNIT- prefix uses 18 characters of that.  That leaves 12 characters for a combination of project\_descriptor and randomization suffixes (and their seperating hyphen).  If using the randomization feature above, only 7 characters are left.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| google | <4.0,>=3.45.0 |
| kubernetes | ~> 1.13.3 |

## Providers

| Name | Version |
|------|---------|
| google | <4.0,>=3.45.0 |
| kubernetes | ~> 1.13.3 |
| random | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| project | github.com/terraform-google-modules/cloud-foundation-fabric//modules/project?ref=v4.3.0 |  |

## Resources

| Name | Type |
|------|------|
| [google_project_iam_member.project_automation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.automation_project_apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_service_account.project_automation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.workload_identity](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_storage_bucket.project_automation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.project_automation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [kubernetes_service_account.project_automation](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [random_id.project_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_id.tf_state_bucket_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| automation\_project\_id | Project id used for environmental automation service accounts. | `string` | n/a | yes |
| environment | The lifecycle of this project.  Valid values are: `dev`, `qa`, `cert-ncde`, `prod-ncde`, `cert-cde`, `prod-cde` or `svcs`.  `ncde` denotes non-cde and `svcs` denotes shared services environment (within the LZ).  NOTE: this will determine the prescribed CIDR used for VPC creation, if var.vpc\_info is defined. | `string` | n/a | yes |
| parent\_folder | ID of the folder under which the project will be created, in the `folders/XXXXXXXXXX` format | `string` | n/a | yes |
| unit\_code | Operational unit short name (resource prefix). | `string` | n/a | yes |
| additional\_labels | Any non-default resource labels for project resources | `map(string)` | `{}` | no |
| allow\_destroy | If true, safeguards will be disabled allowing the project to be destroyed | `bool` | `false` | no |
| billing\_account | Billing account id associated with the project | `string` | `"00EC5A-761F56-8F7463"` | no |
| business\_region | The business\_region is for business units that have distinctive organizational/financial segmentation region to region.  Choices are 'as' (AsiaPacific), 'eu' (Europe), 'uk' (United Kingdom), 'na' (North America), 'gg' (Global). If in question, use 'na' as most business units are financially based in the US. | `string` | `"na"` | no |
| domain | Domain name for this G Suite organization | `string` | `"example.com"` | no |
| geo\_location | The geo location (country/continent) in which resources in this project will be deployed.  Choices are 'eu' (Europe), 'us' (Unites States), 'ww' (World wide, rare). If resources will be deployed across multiple geo locations, use ww. | `string` | `"us"` | no |
| global\_automation\_project\_id | Project ID used for workload identity and pipeline execution. | `string` | `"pid-gousgnap-lzds-res01"` | no |
| iam\_role\_members | IAM additive bindings in {ROLE => [MEMBER,...]} format. MEMBER should be of the form 'group:<groupname>@example.com' or 'serviceAccount:<service\_account\_email\_addr>'. | `map(list(string))` | `{}` | no |
| policy\_boolean | Map of boolean org policies and enforcement value, set value to null for policy restore. | `map(bool)` | `{}` | no |
| policy\_list | Map of list org policies, status is true for allow, false for deny, null for restore. Values can only be used for allow or deny. | <pre>map(object({<br>    inherit_from_parent = bool<br>    suggested_value     = string<br>    status              = bool<br>    values              = list(string)<br>  }))</pre> | `{}` | no |
| project\_descriptor | A suffix to append to the end of the auto-generated portion of the project name. Use this to denote the function of the resources in the project. Can only contain alphanumeric characters and hyphens. Do NOT specify a leading hyphen, it is automatic.  Minimum of 3, maximum of 12 characters (max of 7 if randomize\_project\_id is enabled). | `string` | `"res01"` | no |
| project\_name | (DEPRECATED) Name of the project to create. This will also act as the project\_id.  It can be 6-25 characters if randomize\_project\_id = true, 6-30 if false. Please follow your organisations project naming standards.  NOTE: This parameter has been deprecated and only exists for compatability with existing project deployments.  Instead, please specify values for geo\_location, region, business\_region and project\_descriptor, which will automatically generate a properly structured project\_name.  If empty string (default), code will auto-generate the project name and project ID. | `string` | `""` | no |
| project\_services | Service APIs to enable for the project. NOTE: If you specify any services, the default values will not be used, thus you must include the defaults in your service list. | `set(string)` | <pre>[<br>  "compute.googleapis.com",<br>  "storage-component.googleapis.com",<br>  "secretmanager.googleapis.com"<br>]</pre> | no |
| randomize\_project\_id | If true, append a randomized four-character string to the end of `project_name` to ensure uniqueness | `bool` | `true` | no |
| region | The cloud region in which the application resources will be deployed.  Choices are 'n' (North), 's' (South), 'e' (East), 'w' (West), 'c' (Central), 'g' (Global). If resources will be in multiple regions, use g. | `string` | `"g"` | no |

## Outputs

| Name | Description |
|------|-------------|
| project\_automation\_kubernetes\_namespace | Kubernetes namespace for executing project automation pipelines |
| project\_automation\_kubernetes\_service\_account | Kuberentes ServiceAccount with workload identity bindings for this project |
| project\_automation\_service\_account | Google service account for project automation |
| project\_id | Project ID of the resulting project |
| project\_name | Display name of the resulting project |
| project\_number | Project number of the resulting project |
| project\_state\_bucket | Terraform state bucket for this project |

# Disclaimer
Copyright 2021 your organisations. This software is provided for use by your organisations only.  Use for any other entity is forbidden.

This file generated by terraform-docs v0.12.1 or greater (https://github.com/terraform-docs/terraform-docs)
