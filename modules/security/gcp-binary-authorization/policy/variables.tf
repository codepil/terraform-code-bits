variable "deployer_project_id" {
  description = "(Required) The deployer project ID. The deployer project manages the Google Kubernetes Engine (GKE) clusters, where you deploy images."
  type        = string
}

variable "attestor_names" {
  description = "(Required) List of attestor names, in the format [projects/<attestor_project_id>/attestors/<attestor_name>,]"
  type        = list(string)
}

variable "default_evaluation_mode" {
  description = "(Optional) Default admission rule. Possible values are ALWAYS_ALLOW, REQUIRE_ATTESTATION, and ALWAYS_DENY. Default admission rule is global to all clusters."
  type        = string
  default     = "ALWAYS_DENY"
}

variable "images_exempted" {
  description = "(Optional) List of an image names or pattern to whitelist, in the form registry/path/to/image. This supports a trailing * as a wildcard."
  type        = list(string)
  default     = []
}

variable "cluster_admission_rules" {
  description = "(Optional) List of cluster specific admission rules. Cluster is name/id of the GKE cluster & possible values of evaluation_mode are ALWAYS_ALLOW, REQUIRE_ATTESTATION, and ALWAYS_DENY"
  type        = list(object({
    cluster = string
    evaluation_mode = string
  }))
  default     = []
}


