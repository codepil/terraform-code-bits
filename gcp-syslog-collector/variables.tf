variable "project_id" {
  description = "(Required) The project ID in which the resources should be created"
  type        = string
}

variable "vpc_name" {
  description = "(Required) Name of VPC network to be used"
  type        = string
}

variable "subnet_name" {
  description = "(Required) Name of subnetwork to be used"
  type        = string
}

variable "region" {
  description = "(Required) Compute region."
  type        = string
}

variable "zones" {
  description = "(Required) Compute zone, instance will cycle through the list, defaults to the 'b' zone in the region."
  type        = list(string)
}

variable "regional" {
  description = "(Optional) Use regional instance group."
  type        = bool
  default     = false
}

variable "name" {
  description = "(Required) Prefix name for infrastructure created."
  type        = string
}

variable "autoscaler_config" {
  description = "(Optional) Autoscaler configuration. Only one of 'cpu_utilization_target' 'load_balancing_utilization_target' or 'metric' can be not null."
  type = object({
    max_replicas                      = number
    min_replicas                      = number
    cooldown_period                   = number
    cpu_utilization_target            = number
    load_balancing_utilization_target = number
    metric = object({
      name                       = string
      single_instance_assignment = number
      target                     = number
      type                       = string # GAUGE, DELTA_PER_SECOND, DELTA_PER_MINUTE
      filter                     = string
    })
  })
  default = {
    max_replicas                      = 3
    min_replicas                      = 1
    cooldown_period                   = 30
    cpu_utilization_target            = 0.65
    load_balancing_utilization_target = null
    metric                            = null
  }
}

variable "instance_type" {
  description = "(Required) Machine instance type to be created"
  type        = string
  default     = "f1-micro"
}

variable "other_instance_tags" {
  description = "(Optional) Custom list of instance tags to be created."
  type        = list(string)
  default     = []
}

variable "boot_disk" {
  description = "(Required) Boot disk properties."
  type = object({
    image = string
    size  = number
    type  = string
  })
  default = {
    image = "projects/rhel-cloud/global/images/rhel-7-v20210721"
    type  = "pd-ssd"
    size  = 20
  }
}

variable "lb_source_tags" {
  description = "(Required) Source tags to be used for Firewall rule. Its same as syslog forwarding client/source instance tag"
  type        = list(string)
  default     = ["syslog-client"]
}

