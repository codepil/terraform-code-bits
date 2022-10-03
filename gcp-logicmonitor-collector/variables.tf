variable "project_id" {
  description = "(Required) The project ID in which the resources should be created"
  type        = string
}

variable "vpc_name" {
  description = "(Required) Name of GCP VPC network to deploy resources into"
  type        = string
}

variable "subnet_name" {
  description = "(Required) Name of subnetwork to be attached to the VMs"
  type        = string
}

variable "region" {
  description = "(Required) Region where all resources will be deployed"
  type        = string
}

variable "zones" {
  description = "(Required) List of zones in which to create VMs and instance groups"
  type        = list(string)
}

variable "labels" {
  description = "Required labels applied to all resources"
  type = object({
    costcenter         = string
    dataclassification = string
    eol_date           = string
    lifecycle          = string
    service_id         = string
  })
}

variable "collector_name_prefix" {
  description = "(Required) Prefix string to be used for all VM/resources created by this module"
  type        = string
}

variable "collector_instance_type" {
  description = "(Required) Instance type to be created. Refer to https://www.logicmonitor.com/support/collectors/collector-overview/collector-capacity"
  type        = string
  default     = "f1-micro"
}

variable "collectors_per_zone" {
  description = "Number of VM instances to create in each zone"
  type        = number
  default     = 1
}

variable "other_vm_instance_tags" {
  description = "(Optional) Custom list of instance tags to be created"
  type        = list(string)
  default     = []
}

variable "additional_source_network_ip_ranges" {
  description = "(Optional) Custom list of IP ranges, other than specified in 'sub_network', to allow traffic to LM collectors"
  type        = list(string)
  default     = []
}

variable "boot_disk" {
  description = "(Required) Boot disk properties"
  type = object({
    image = string
    size  = number
    type  = string
  })
  default = {
    image = "projects/pid-gousgggp-ssvc-os-images/global/images/windows-2016-v2021080622-golden"
    type  = "pd-ssd"
    size  = 40
  }
}

variable "collector_login_users" {
  description = "List of users, groups, or service accounts that are allowed access to the collector VM using the IAP tunnel. The GCP account deploying this code is automatically appended to this list.  Entries should have appropriate 'user:', 'group:', or 'serviceAccount:' prefixes. Use https://cloud.google.com/iap/docs/using-tcp-forwarding#gcloud_3 to connect to VM."
  type        = list(string)
  default     = []
}


