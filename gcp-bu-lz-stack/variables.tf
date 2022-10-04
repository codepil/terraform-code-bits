variable "domain" {
  description = "Domain name for this G Suite organization"
  default     = "example.com"
}

variable "lz_delegated_conhub_roles" {
  description = "Custom role for peeing between LZ lifecycle project and conhub spoke project"
  type        = list(string)
  default = [
    "organizations/155946218325/roles/PeeringDelegate",
  ]
}

variable "global_automation_project_id" {
  description = "The global automation project ID for SAs and k8s namespaces, etc"
  type        = string
}

variable "unit_name" {
  description = "Top folder name. It must be between 3 and 30 characters, using only upper/lower case characters, numbers, underscores, hyphens, or spaces."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][-_ a-zA-Z0-9]{1,28}[a-zA-Z0-9]$", var.unit_name))
    error_message = "The unit_name must be between 3 and 30 characters, and contain only letters, digits, underscores, hyphens, and spaces.  It also must start and end with a letter or digit."
  }
}

variable "labels" {
  description = "Required labels applied to LZ resouces"
  type        = map(string)
  default     = {}
}

variable "unit_code" {
  description = "Buisness Unit Code (2-5 alpha-numeric characters)"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,4}$", var.unit_code))
    error_message = "The unit_code must be 3 or 4 characters long, and contain only lower case letters and digits."
  }
}

variable "country_code" {
  description = "One of [us, cn, uk, in]"
  default     = "us"
}

variable "business_region" {
  description = "One of [na, ap, eu, uk]"
  default     = "na"
}

variable "root_node" {
  description = "Root node in folders/folder_id or organizations/org_id format."
  type        = string
}

variable "billing_account_id" {
  description = "Country billing account account."
  type        = string
}

variable "create_billing_iam_bindings" {
  description = "If true, configure BU project provisioners to use provided billing account to create projects"
  default     = true
}

variable "unit_iam_members" {
  description = "IAM members for roles applied on the unit folder."
  type        = map(list(string))
  default     = {}
}

variable "unit_policy_boolean" {
  description = "Map of boolean based organizational policies to apply to business unit folder"
  type        = map(bool)
  default     = {}
}

variable "unit_policy_list" {
  description = "Map of list/value based organizational policies to apply to business unit folder. NOTE: For policy compute.trustedImageProjects, only specify here or with the trusted_images_projects parameter, not both."
  type = map(object({
    inherit_from_parent = bool
    suggested_value     = string
    status              = bool
    values              = list(string)
  }))
  default = {}
}

variable "environments_iam_members" {
  description = "Map of `{ <environment> : { <role> : [members] } }` for any additional IAM bindings to apply to environment folders"
  type = object({
    devqa  = map(list(string)),
    noncde = map(list(string)),
    cde    = map(list(string)),
    ops    = map(list(string)),
  })
  default = {
    devqa  = {},
    noncde = {},
    cde    = {},
    ops    = {},
  }
}

variable "environments_policy_boolean" {
  description = "Map of environments, mapping boolean based organizational policies to apply to business unit folder"
  type        = map(map(bool))
  default     = {}
}

variable "environments_policy_list" {
  description = "Map of environments, mapping list/value based organizational policies to apply to business unit folder"
  type = map(map(object({
    inherit_from_parent = bool
    suggested_value     = string
    status              = bool
    values              = list(string)
  })))
  default = {}
}

variable "gcs_defaults" {
  description = "Defaults use for the state GCS buckets."
  type        = map(string)
  default = {
    location      = "US"
    storage_class = "MULTI_REGIONAL"
  }
  validation {
    condition     = contains(["US", "EU", "ASIA"], var.gcs_defaults.location) && var.gcs_defaults.storage_class == "MULTI_REGIONAL"
    error_message = "The gcs_defaults.location value must be US, EU, or ASIA. The gcs_defaults.storage_class value must be MULTI_REGIONAL."
  }
}

variable "automation_project_services" {
  description = "API services that will be enabled on the BU automation project. Removing any of the APIs in the default list will cause errors in the creation of resources as part of this module."
  type        = list(string)
  default = [
    "cloudbilling.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "storage-component.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudkms.googleapis.com",
    "containerregistry.googleapis.com",
  ]
}

variable "shared_vpc_host_project_services" {
  description = "API services that will be enabled on each of the Shared VPC host projects."
  type        = list(string)
  default = [
    "cloudbilling.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "storage-component.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "dns.googleapis.com",
  ]
}

variable "images_project_services" {
  description = "API services that will be enabled on the LZ images/GCR project. Removing any of the APIs in the default list will cause errors in the creation of resources as part of this module."
  type        = list(string)
  default = [
    #"cloudbilling.googleapis.com",
    #"cloudresourcemanager.googleapis.com",
    "storage-component.googleapis.com",
    "storage-api.googleapis.com",
    "containerregistry.googleapis.com",
    "compute.googleapis.com",
    "secretmanager.googleapis.com",
    "iam.googleapis.com",
    #"cloudbuild.googleapis.com",  # future?, will need update to lz-infra-bootstrap automation project services too
  ]
}

variable "environment_folder_service_account_roles" {
  description = "IAM roles granted to the environment service account on the environment sub-folder."
  type        = set(string)
  default = [
    "roles/compute.networkAdmin",
    "roles/owner",
    "roles/resourcemanager.folderAdmin",
    "roles/resourcemanager.projectCreator",
  ]
}

variable "trusted_images_projects" {
  description = "List of `projects/<project_id>` from which projects within this landing zone may pull GCE images. The LZ automation project will be included.  Do not use at same time as unit_policy_list compute.trustedImageProjects.  Only use one or the other."
  type        = list(string)
  default     = []
}

variable "images_project_service_account_roles" {
  description = "IAM roles granted to the automation service account for the *-lz-images project."
  type        = set(string)
  default = [
    # General non-admin permissions
    "roles/editor",
    # Admin role needed for the SA to manage project-level IAM bindings
    "roles/resourcemanager.projectIamAdmin",
    # Admin roles needed for creating/configuring related resources
    "roles/compute.instanceAdmin",
    "roles/compute.networkAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/storage.admin",
    # Admin role needed to setup and/or integrate with Secrets Manager
    "roles/secretmanager.admin",
    # Admin role needed to create setup IAP and grant access to tunnels to users/serviceaccounts
    "roles/iap.admin",
  ]
}

variable "scanning_service_account" {
  description = "Service account which will be granted permissions for scanning GCR in *-lz-images project of the LZ."
  type        = string
  default     = "act-twistlock@pid-gcp-sec-scan01.iam.gserviceaccount.com"
}

variable "enable_gcr" {
  description = "Boolean indicating whether to enable GCR in the lz-images project."
  type        = bool
  default     = false
}

variable "enable_conhub" {
  description = "Boolean indicating whether to enable creation of Connectivity Hub components in this project"
  type        = bool
  default     = false
}

variable "conhub_mgmt_service_accounts" {
  type = object({
    devqa  = string
    noncde = string
    cde    = string
    shared = string
  })
  default = {
    devqa  = "pid-gcp-nets-ch-devqa-1@pid-gcp-nets-lz-ops.iam.gserviceaccount.com"
    noncde = "pid-gousgnag-nets-ch-noncde-1@pid-gcp-nets-lz-ops.iam.gserviceaccount.com"
    cde    = "pid-gcp-nets-ch-cde-1@pid-gcp-nets-lz-ops.iam.gserviceaccount.com"
    shared = "pid-gcp-nets-ch-shared-1@pid-gcp-nets-lz-ops.iam.gserviceaccount.com"
  }
}
