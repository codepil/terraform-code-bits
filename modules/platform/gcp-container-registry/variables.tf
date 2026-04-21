variable "iam_role_members" {
  description = "Map of member list, keyed by role, used to assign roles using authoritative binding to the backend storage bucket behind the registry.  NOTE: these roles will be granted in additive manor, so-as not to cause issue with GCP's own permission grants as part of GCR."
  type        = map(list(string))
  default     = {}
}

variable "location" {
  description = "Location of the registry. Can be US, EU, ASIA or empty. Note: empty string defaults to US now, but may change in future."
  type        = string
  default     = null
}

variable "project_id" {
  description = "Project id of the project in which to create the registry."
  type        = string
}

variable "use_iam_binding" {
  type        = bool
  description = "Flag to indicate how IAM roles are granted to members: use of authoritative binding (true), use additive (false).  Note, authoritative method will overwrite any IAM changes made out of band from this code.  Additive will leave existing members unchanged, but provide less enforcement of IAM as code."
  default     = true
}

variable "gcr_scan_member" {
  description = "Member identity allowed to scan GCR for image vulnerabilities, from Prisma console"
  type        = string
  default     = "serviceAccount:act-twistlock@pid-gcp-sec-scan01.iam.gserviceaccount.com"
}