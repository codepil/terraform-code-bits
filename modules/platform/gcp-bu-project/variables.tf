###############################################################################
# Landing Zone details
###############################################################################

variable "unit_code" {
  description = "Operational unit short name (resource prefix)."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,4}$", var.unit_code))
    error_message = "The unit_code value must be an alphanumeric string, 3 or 4 characters long, matching the unit_code assigned to the parent Landing Zone."
  }
}

variable "automation_project_id" {
  description = "Project id used for environmental automation service accounts."
  type        = string
}

variable "global_automation_project_id" {
  description = "Project ID used for workload identity and pipeline execution."
  default     = "pid-gcp-lzds-res01"
}

variable "environment" {
  description = "The lifecycle of this project.  Valid values are: `dev`, `qa`, `cert-ncde`, `prod-ncde`, `cert-cde`, `prod-cde` or `svcs`.  `ncde` denotes non-cde and `svcs` denotes shared services environment (within the LZ).  NOTE: this will determine the prescribed CIDR used for VPC creation, if var.vpc_info is defined."
  type        = string
  validation {
    condition     = contains(["dev", "qa", "cert-ncde", "prod-ncde", "cert-cde", "prod-cde", "svcs"], var.environment)
    error_message = "The environment value must be one of the following: dev, qa, cert-ncde, prod-ncde, cert-cde, prod-cde, or svcs."
  }
}

variable "domain" {
  description = "Domain name for this G Suite organization"
  default     = "example.com"
}

###############################################################################
# Project details
###############################################################################

variable "parent_folder" {
  description = "ID of the folder under which the project will be created, in the `folders/XXXXXXXXXX` format"
  type        = string
}

variable "project_name" {
  description = "(DEPRECATED) Name of the project to create. This will also act as the project_id.  It can be 6-25 characters if randomize_project_id = true, 6-30 if false. Please follow your organisations project naming standards.  NOTE: This parameter has been deprecated and only exists for compatability with existing project deployments.  Instead, please specify values for geo_location, region, business_region and project_descriptor, which will automatically generate a properly structured project_name.  If empty string (default), code will auto-generate the project name and project ID."
  type        = string
  # Note, the contains() function in validation condition is for whitelisting existing projects that violate the naming standard.  Better this than relaxing the regex to cover them and allow future violations.
  validation {
    condition     = length(var.project_name) <= 30 && (can(regex("^pid-go(us|eu|as|ap|gg)[nsewcg](as|ap|eu|uk|na)i{0,1}[bdqsgcp]-[a-z0-9]{3,4}-[a-z0-9][-a-z0-9]{2,12}$", var.project_name)) || var.project_name == "" || contains(["prj-gousenaid-astro-res01", "prj-gousenaib-oratde-res01", "dgov-dev-57e8", "pid-gousgggq-sec-scan01", "pid-gcp-sec-scan01", "pid-gcp-ssvc-os-images", "pid-gousgggd-ssvc-os-images"], var.project_name))
    error_message = "The project name must follow the standard naming convention, AND be 25 characters or less with randomize_project_id = true or 30 characters or less with randomize_project_id = false."
  }
  default = ""
}

variable "randomize_project_id" {
  description = "If true, append a randomized four-character string to the end of `project_name` to ensure uniqueness"
  default     = true
}

variable "billing_account" {
  description = "Billing account id associated with the project"
  default     = "00EC5A-761F56-8F7463"
}

variable "additional_labels" {
  description = "Any non-default resource labels for project resources"
  type        = map(string)
  default     = {}
}

###############################################################################
# Project API Services
###############################################################################

variable "project_services" {
  description = "Service APIs to enable for the project. NOTE: If you specify any services, the default values will not be used."
  type        = set(string)
  default = [
    "compute.googleapis.com",
    "storage-component.googleapis.com",
    "secretmanager.googleapis.com",
  ]
}

###############################################################################
# Project-level IAM policies
###############################################################################

variable "iam_role_members" {
  description = "IAM additive bindings in {ROLE => [MEMBER,...]} format. MEMBER should be of the form 'group:<groupname>@example.com' or 'serviceAccount:<service_account_email_addr>'."
  type        = map(list(string))
  default     = {}
}

###############################################################################
# Project-level org policies
###############################################################################

variable "policy_boolean" {
  description = "Map of boolean org policies and enforcement value, set value to null for policy restore."
  type        = map(bool)
  default     = {}
}

variable "policy_list" {
  description = "Map of list org policies, status is true for allow, false for deny, null for restore. Values can only be used for allow or deny."
  type = map(object({
    inherit_from_parent = bool
    suggested_value     = string
    status              = bool
    values              = list(string)
  }))
  default = {}
}

###############################################################################
# Operational flag to enable destruction of project
###############################################################################

variable "allow_destroy" {
  description = "If true, safeguards will be disabled allowing the project to be destroyed"
  default     = false
}
# pid-gcp-unitcode-suffix
variable "geo_location" {
  description = "The geo location (country/continent) in which resources in this project will be deployed.  Choices are 'eu' (Europe), 'us' (Unites States), 'ww' (World wide, rare). If resources will be deployed across multiple geo locations, use ww."
  type        = string
  validation {
    condition     = contains(["as", "eu", "us", "gg"], var.geo_location)
    error_message = "The region value must be one of the following: as, eu, us, gg."
  }
  default = "us"
}

variable "region" {
  description = "The cloud region in which the application resources will be deployed.  Choices are 'n' (North), 's' (South), 'e' (East), 'w' (West), 'c' (Central), 'g' (Global). If resources will be in multiple regions, use g."
  type        = string
  validation {
    condition     = contains(["n", "s", "e", "w", "c", "g"], var.region)
    error_message = "The region value must be one of the following: n, s, e, w, c, g."
  }
  default = "g"
}

variable "business_region" {
  description = "The business_region is for business units that have distinctive organizational/financial segmentation region to region.  Choices are 'as' (AsiaPacific), 'eu' (Europe), 'uk' (United Kingdom), 'na' (North America), 'gg' (Global). If in question, use 'na' as most business units are financially based in the US."
  type        = string
  validation {
    condition     = contains(["as", "ap", "eu", "uk", "na"], var.business_region)
    error_message = "The business_service_region value must be one of the following: as, ap (deprecated), eu, uk, na."
  }
  default = "na"
}

variable "project_descriptor" {
  description = "A suffix to append to the end of the auto-generated portion of the project name. Use this to denote the function of the resources in the project. Can only contain alphanumeric characters and hyphens. Do NOT specify a leading hyphen, it is automatic.  Minimum of 3, maximum of 12 characters (max of 7 if randomize_project_id is enabled)."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9][-a-z0-9]{2,11}$", var.project_descriptor))
    error_message = "The project_descriptor value can only contain up to 12 alphanumeric characters and hyphens (hyphen cannot be the first character)."
  }
  default = "res01"
}
