variable "project_id" {
  description = "(Required) The project ID in which the resources should be created."
  type        = string
}

variable "key_ring" {
  description = "(Required) The KeyRing self_link that this key belongs to."
  type        = string
}

variable "key_name" {
  description = "(Required) The name of the crypto key to be created."
  type        = string
}

variable "iam_role_members" {
  description = "Map of roles containing list of IAM members to be granted access.  See `use_iam_binding` on how this is applied."
  type        = map(list(string))
  default     = {}
}

variable "use_iam_binding" {
  type        = bool
  description = "Flag to indicate how IAM roles are granted to members: use of authoritative binding (true), use additive (false).  Note, authoritative method will overwrite any IAM changes made out of band from this code.  Additive will leave existing members unchanged, but provide less enforcement of IAM as code."
  default     = true
}

variable "purpose" {
  description = "(Required) The Crypto key purpose. See https://cloud.google.com/kms/docs/reference/rest/v1/projects.locations.keyRings.cryptoKeys#CryptoKeyPurpose for possible inputs"
  type        = string
}

variable "rotation_period" {
  description = "(Optional) The rotation period of the key. The rotation period has the format of a decimal number with up to 9 fractional digits, followed by the letter s (seconds). It must be greater than a day (ie, 86400). Defaults to 90 days"
  type        = string
  default     = "7776000s"
}

variable "algorithm" {
  description = "(Optional) The algorithm to use when creating a version. See https://cloud.google.com/kms/docs/reference/rest/v1/CryptoKeyVersionAlgorithm for possible inputs. If not set it defaults to Your company recommended value."
  type        = string
  default     = null
}

variable "protection_level" {
  description = "(Optional) The protection level to use when creating a version. Possible values are SOFTWARE and HSM."
  type        = string
  default     = "SOFTWARE"
}

variable "labels" {
  type        = map(string)
  description = "(Optional) A map of key:value pairs to apply as labels to assign to the crypto key."
  default     = {}
}
