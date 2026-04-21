
variable "project" {
  description = "Project ID in which to deploy the IDS, a host project in case of shared VPC"
  type        = string
}

variable "prefix" {
  description = "A word to use as a common prefix on all resources deployed"
  type        = string
  default     = "suricata"
}

