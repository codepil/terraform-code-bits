variable "key_project_id" {
  description = "(Required) The key project ID in which the crypto key is to be created. "
  type        = string
}

variable "attestor_project_number" {
  description = "(Required) The Attestor project number in which the Binary authorisation resources should be created. "
  type        = number
}

variable "deployer_project_numbers" {
  description = "(Required) List of deployer project numbers. The deployer projects are the one that hosts Google Kubernetes Engine (GKE) clusters."
  type        =  list(number)
}

variable "attestor_key_name" {
  description = "(Required) Name of attestor key"
  type        = string
}

variable "key_ring_name" {
  description = "(Optional) Name of Keyring. If Keyring by given name is not present in the key_project_id then new Keyring shall be created with that name. "
  type        = string
  default = "attestor-key-ring"
}

variable "location" {
  description = "(Optional) Location of Keyring to be created or fetched."
  type        = string
  default     = "global"
}

variable "key_users" {
  description = "(Optional) List of users or SAs that would require to have cryptoOperator role provisioned as part this module. Deployment automation SAs which creates Attestors are to be part of this list."
  type = list(string)
  default = []
}


