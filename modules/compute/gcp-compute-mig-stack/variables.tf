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
  default = null
}

variable "health_check_config" {
  description = "(Optional) auto-created health check configuration, use the output self-link to set it in the auto healing policy. Refer to examples for usage."
  type = object({
    type    = string      # http https tcp ssl http2
    check   = map(any)    # actual health check block attributes
    config  = map(number) # interval, thresholds, timeout
    logging = bool
  })
  default = null
}

variable "auto_healing_policies" {
  description = "(Optional) Auto-healing policies for this group. Autohealing policies can use an externally defined health check, or have this module auto-create one"
  type = object({
    health_check      = string
    initial_delay_sec = number
  })
  default = null
}

variable "location" {
  description = "(Required) Compute zone, or region if `regional` is set to true."
  type        = string
}

variable "name" {
  description = "(Optional) Managed group name."
  type        = string
}

variable "named_ports" {
  description = "(Optional) Named ports. Protocol being the key and port number being the value. It's first entry becomes the default backend values for Load Balancer."
  type        = map(number)
  default     = null
}

variable "regional" {
  description = "(Optional) Use regional instance group. When set, `location` should be same as the region."
  type        = bool
  default     = false
}

variable "target_pools" {
  description = "(Optional) list of URLs for target pools to which new instances in the group are added."
  type        = list(string)
  default     = []
}

variable "target_size" {
  description = "(Optional) Group target size, sets to null when using an autoscaler."
  type        = number
  default     = null
}

variable "update_policy" {
  description = "(Optional) Update policy. Type can be 'OPPORTUNISTIC' or 'PROACTIVE', action 'REPLACE' or 'restart', surge type 'fixed' or 'percent'."
  type = object({
    type                 = string # OPPORTUNISTIC | PROACTIVE
    minimal_action       = string # REPLACE | RESTART
    min_ready_sec        = number
    max_surge_type       = string # fixed | percent
    max_surge            = number
    max_unavailable_type = string
    max_unavailable      = number
  })
  default = null
}

variable "additional_versions" {
  description = "(Optional) Additional application versions, target_type is either 'fixed' or 'percent'."
  type = map(object({
    instance_template = string
    target_type       = string # fixed | percent
    target_size       = number
  }))
  default = null
}

variable "wait_for_instances" {
  description = "(Optional) Wait for all instances to be created/updated before returning."
  type        = bool
  default     = true
}

variable "existing_instance_template" {
  description = "Instance template self-link."
  type        = string
  default     = null
}

variable "instance_name" {
  description = "Instances base name. Optional if 'existing_instance_template' is provided."
  type        = string
  default     = null
}

variable "instance_type" {
  description = "Machine instance type to be created"
  type        = string
  default     = "f1-micro"
}

variable "region" {
  description = "Compute region. Optional if 'existing_instance_template' is provided."
  type        = string
  default     = null
}

variable "zones" {
  description = "(Optional) Compute zone, instance will cycle through the list, defaults to the 'b' zone in the region. Optional if 'existing_instance_template' is provided."
  type        = list(string)
  default     = []
}

variable "instance_tag" {
  description = "Instance tag to be created. This tag is used as target_tag while creating load balancers. This value is not used if 'existing_instance_template' is provided, where tags are fetched from existing_instance_template dynamically while creating the load balancer"
  type        = string
  default     = "mig-instance-default"
}

variable "other_instance_tags" {
  description = "Additional list of instance tags to be created."
  type        = list(string)
  default     = []
}

variable "boot_disk" {
  description = "Boot disk properties. Optional if 'existing_instance_template' is provided."
  type = object({
    image = string
    size  = number
    type  = string
  })
  default = {
    image = "projects/debian-cloud/global/images/family/debian-10"
    type  = "pd-ssd"
    size  = 10
  }
}

variable "network_interfaces" {
  description = "Network interfaces configuration. Use self links for Shared VPC, set addresses and alias_ips to null if not needed. Optional if 'existing_instance_template' is provided."
  type = list(object({
    nat        = bool
    network    = string
    subnetwork = string
    addresses = object({
      internal = list(string)
      external = list(string)
    })
    alias_ips = map(list(string))
  }))
  default = null
}

variable "instance_service_account_id" {
  type        = string
  description = "Id of the service account identity which to be created with instance template. The value specified will automatically be suffixed by @<project_id>.iam.gserviceaccount.com. Optional if 'existing_instance_template' is provided."
  default     = "sa-instance-template-default"
}

variable "labels" {
  description = "Instance labels. Optional if 'existing_instance_template' is provided."
  type        = map(string)
  default     = {}
}

variable "startup_script_path" {
  type        = string
  default     = null
  description = "Name of start up script to be used, example: startup-scripts/configure_syslog_collector. Optional if 'existing_instance_template' is provided."
}

variable "metadata" {
  description = "Instance metadata. Optional if 'existing_instance_template' is provided."
  type        = map(string)
  default     = {}
}

variable "lb_name_prefix" {
  description = "(Optional) Name for the forwarding rule and prefix for supporting resources. Should be non-null to create a HTTPS load balancer"
  type        = string
  default     = null
}

variable "firewall_networks" {
  description = "(Required) Names of the networks to create firewall rules in, it defaults to 'default' VPC network."
  type        = list(string)
  default     = ["default"]
}

variable "backends" {
  description = "(Optional) Map backend indices to list of backend maps. Default backend is created automatically when include_default_backend is true. "
  type = map(object({
    protocol  = string
    port      = number
    port_name = string

    description            = string
    enable_cdn             = bool
    security_policy        = string
    custom_request_headers = list(string)

    timeout_sec                     = number
    connection_draining_timeout_sec = number
    session_affinity                = string
    affinity_cookie_ttl_sec         = number

    health_check = object({
      check_interval_sec  = number
      timeout_sec         = number
      healthy_threshold   = number
      unhealthy_threshold = number
      request_path        = string
      port                = number
      host                = string
      logging             = bool
    })

    log_config = object({
      enable      = bool
      sample_rate = number
    })

    groups = list(object({
      group = string

      balancing_mode               = string
      capacity_scaler              = number
      description                  = string
      max_connections              = number
      max_connections_per_instance = number
      max_connections_per_endpoint = number
      max_rate                     = number
      max_rate_per_instance        = number
      max_rate_per_endpoint        = number
      max_utilization              = number
    }))
    iap_config = object({
      enable               = bool
      oauth2_client_id     = string
      oauth2_client_secret = string
    })
  }))
  default = null
}

variable "include_default_backend" {
  description = "(Optional) Include created MIG as a backend to the load balancer"
  type        = bool
  default     = true
}

variable "lb_port_default" {
  description = "(Optional) Port number for default backend, it defaults to named_ports value when null"
  type        = string
  default     = null
}

variable "lb_protocol_default" {
  description = "(Optional) Protocol for default backend, it defaults to named_ports value when null"
  type        = string
  default     = null
}

variable "default_url_request_path" {
  description = "(Optional) Url request path for default backend"
  type        = string
  default     = "/"
}

variable "ssl_certificates" {
  description = "(Required) SSL cert self_link list."
  type        = list(string)
  default     = []
}

variable "ilb_source_tags" {
  description = "Source tags to be used for Firewall rule. Only applicable if lb_type is INTERNAL"
  type        = list(string)
  default     = []
}

variable "lb_type" {
  description = "Type of load balancer to be created. Takes values either INTERNAL or EXTERNAL"
  type        = string
  default     = "NONE"
  validation {
    condition     = contains(["INTERNAL", "EXTERNAL", "NONE"], var.lb_type)
    error_message = "Valid values for var: lb_type are (INTERNAL, EXTERNAL, NONE)."
  }
}
