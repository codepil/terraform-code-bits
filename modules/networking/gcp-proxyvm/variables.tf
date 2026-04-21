variable "name" {
  description = "Instances base name."
  type        = string
}

variable "project_id" {
  description = "Project id."
  type        = string
}

variable "region" {
  description = "Compute region."
  type        = string
}

variable "zones" {
  description = "Compute zone, instance will cycle through the list, defaults to the 'b' zone in the region."
  type        = list(string)
  default     = []
}

variable "members" {
  description = "List of users, groups, or service accounts that are allowed access to the proxy VM using the IAP tunnel. The GCP account deploying this code is automatically appended to this list.  Entries should have appropriate 'user:', 'group:', or 'serviceAccount:' prefixes."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Instance network tags."
  type        = list(string)
  default     = []
}

variable "instance_type" {
  description = "Instance type."
  type        = string
  default     = "f1-micro"
}

variable "labels" {
  description = "Instance labels."
  type        = map(string)
  default     = {}
}

variable "metadata" {
  description = "Instance metadata."
  type        = map(string)
  default     = {}
}

variable "network" {
  description = "Selflink to the network in which to deploy."
  type        = string
}

variable "subnetwork" {
  description = "Selflink to the subnetwork in which to deploy"
  type        = string
}

variable "boot_disk_image" {
  description = "Boot disk image.  May be specific image or image family"
  type        = string
  default     = "projects/debian-cloud/global/images/family/debian-10"
}

variable "boot_disk_size" {
  description = "Boot disk size in GB"
  type        = string
  default     = "20"
}

variable "instance_count" {
  description = "The number of proxy VMs to create."
  type        = number
  default     = 1
}

variable "enable_scheduler_permissions" {
  description = "Provision cloud instance scheduler permissions to start/stop proxyVM instances"
  type        = bool
  default     = false
}
