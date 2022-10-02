variable "attestor_project_id" {
  description = "(Required) The Attestor project ID in which the Binary authorisation resources should be created. "
  type        = string
}

variable "deployer_project_numbers" {
  description = "(Required) The list of Deployer project numbers. The deployer project manages the Google Kubernetes Engine (GKE) clusters."
  type        = list(number)
}

variable "attestor_name_prefix" {
  description = "(Required) Attestor names prefix"
  type        = string
}

variable "crypto_key_id" {
  description = "(Required) ID of crypto key to be used in signing images."
  type        = string
}


