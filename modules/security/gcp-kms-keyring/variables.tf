###
#  module variables
###

#https://www.terraform.io/docs/configuration/variables.html#declaring-an-input-variable
# define a module's input variables

variable "project_id" {
  description = "The project ID in which the resources should be created."
  type        = string
}

variable "key_ring_name" {
  description = "The name of the key ring to be created. Please be aware that KeyRings cannot be deleted from Google Cloud Platform once created."
  type        = string
}

variable "location" {
  description = "The location of the key ring to be created. Default is \"global\"."
  type        = string
  default     = "global"
}

variable "role_mappings" {
  description = "A list maps of the accounts and roles to be bound to this kms key ring. If this is empty, no keyring-specific roles will be assigned. Example: [ { account=\"service1@pid.iam.google.com\", role=\"roles/cloudkms.admin\"}]"
  type        = list(object({ account = string, role = string }))
  default     = []
}



