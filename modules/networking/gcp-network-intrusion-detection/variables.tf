variable "project" {
  description = "Project ID in which to deploy the IDS, a host project in case of shared VPC"
  type        = string
}

variable "network" {
  description = "A Network id where the IDS will be deployed"
  type        = string
}

variable "subnet" {
  description = "A Subnet self-link where the IDS will be deployed"
  type        = string
}

variable "region" {
  description = "The Region where the IDS will be deployed - must correspond with the subnet"
  type        = string
}

variable "prefix" {
  description = "A word to use as a common prefix on all resources deployed"
  type        = string
  default     = "suricata"
}

variable "mirroring_policies" {
  description = "List of policies with required resources targeted for mirroring"
  type = map(object({
    project_id    = string
    vpc_name      = string
    subnets       = list(string)
    instance_tags = list(string)
    instances     = list(string)
  }))
  default = {}
}

variable "filter" {
  description = "A common filter policy for mirrored traffic"
  type = object({
    ip_protocols = list(string)
    cidr_ranges  = list(string)
    direction    = string
  })
  default = {
    ip_protocols = ["tcp", "udp", "icmp"]
    cidr_ranges  = ["0.0.0.0/0"]
    direction    = "BOTH"
  }
}

variable "policy_project" {
  description = "Project ID in which to deploy the Packet mirroring policy, a host project ID in case of shared VPC and Peered project ID in case of VPC Peering. It defaults to <project> value."
  type        = string
  default     = null
}

variable "signature_file_name" {
  description = "(Required) Name of the file which contains rules from ProofPoint signature bundle, which to be added as a source to Suricata rules"
  type        = string
}

variable "gcs_bucket" {
  description = "(Required) Name of GCS bucket, which contains files for Suricate configuration"
  type        = string
}

variable "config_dir" {
  description = "(Required) Directory path containing Suricate configuration files from GCS bucket"
  type        = string
}

variable "create_firewall_rules" {
  description = "Should this module create firewall rules"
  type        = bool
  default     = true
}

variable "base_priority" {
  description = "Sets the base priority floor value for the created firewall rules. Rules will increment upward (higher priority) from this floor."
  type        = number
  default     = 1000
}

variable "linux_os_type" {
  description = "Linux OS type, defaults to Ubuntu. Currently supported OS types are debian and ubuntu. Installer script get picked based on OS type."
  type        = string
  default     = "ubuntu"
  validation {
    condition     = contains(["ubuntu", "debian"], var.linux_os_type)
    error_message = "The linux_os_type value must be debian or ubuntu."
  }
}

variable "source_image_url" {
  description = "(Required) Boot image self-link, which is used for creating VM instances. Preferred to use provided golden images"
  type        = string
  default     = "pid-gcp-ssvc-os-images/gold-ids-ubuntu-1804-lts"
}

variable "boot_disk_type" {
  description = "(Optional) The GCE disk type. Can be either 'pd-ssd', 'local-ssd', 'pd-balanced' or 'pd-standard'"
  type        = string
  default     = "pd-ssd"
}

variable "boot_disk_size" {
  description = "(Optional) Size of a boot disk, in GB"
  type        = number
  default     = 20
}

variable "labels" {
  description = "Instance labels."
  type        = map(string)
  default     = {}
}

variable "autoscaler_config" {
  description = "(Optional) Autoscaler configuration. Only one of 'cpu_utilization_target' 'load_balancing_utilization_target' or 'metric' can be not null."
  type = object({
    max_replicas                      = number
    min_replicas                      = number
    cooldown_period                   = number # in secs
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
    cooldown_period                   = 180 # with apt-get upgrade ..etc
    cpu_utilization_target            = 0.65
    load_balancing_utilization_target = null
    metric                            = null
  }
}

variable "update_policy" {
  description = "(Optional) Update policy. Type can be 'OPPORTUNISTIC' or 'PROACTIVE', action 'REPLACE' or 'restart', surge type 'fixed' or 'percent'. Refer to https://cloud.google.com/compute/docs/instance-groups/rolling-out-updates-to-managed-instance-groups for more details"
  type = object({
    type                 = string # OPPORTUNISTIC | PROACTIVE
    minimal_action       = string # REPLACE | RESTART
    min_ready_sec        = number
    max_surge_type       = string # fixed | percent
    max_surge            = number
    max_unavailable_type = string
    max_unavailable      = number
  })
  default = {
    type                 = "PROACTIVE"
    minimal_action       = "REPLACE"
    min_ready_sec        = 30
    max_surge_type       = "fixed"
    max_surge            = 4 # must be greater than max_replicas by least one.
    max_unavailable_type = "fixed"
    max_unavailable      = 0 #do not want any unavailable machines during an update
  }
}

variable "instance_type" {
  description = "Machine instance type to be created"
  type        = string
  default     = "e2-medium"
}

variable "traffic_source_ranges" {
  description = "(Required) List of source IPs/CIDR ranges from which mirrored traffic is expected"
  type        = list(string)
}

variable "ids_service_account_email" {
  description = "(Required) Service account email, for which GCS bucket access is already been provisioned"
  type        = string
}


