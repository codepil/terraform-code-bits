data "google_project" "project" {
  project_id = var.project_id
}

data "google_compute_instance_template" "default" {
  name    = local.instance_template
  project = var.project_id
}

locals {
  labels = merge(data.google_project.project.labels, var.labels)
  # Create instance template only if no existing instance template.
  create_instance_template = var.existing_instance_template == null ? true : false
  instance_template        = local.create_instance_template ? module.instance-template[0].template.self_link : var.existing_instance_template
  target_tags              = local.create_instance_template ? [var.instance_tag] : data.google_compute_instance_template.default.tags
  # if startup_script_path is present then merge with other metadata values as base module doesn't support metadata_startup_script
  metadata = var.startup_script_path != null ? merge(var.metadata, { startup-script = "${file(var.startup_script_path)}" }) : var.metadata
  # Define default from MIG created health check
  default_health_check_policy = {
    health_check      = var.health_check_config != null ? module.mig.health_check.self_link : null
    initial_delay_sec = 30
  }

  # Define default backend group from MIG created
  default_lb_groups = [{
    group                        = module.mig.group_manager.instance_group
    balancing_mode               = null
    capacity_scaler              = null
    description                  = null
    max_connections              = null
    max_connections_per_instance = null
    max_connections_per_endpoint = null
    max_rate                     = null
    max_rate_per_instance        = null
    max_rate_per_endpoint        = null
    max_utilization              = null
  }]
  lb_groups         = var.backends != null ? concat(local.default_lb_groups, var.backends.groups) : local.default_lb_groups
  firewall_networks = var.firewall_networks

  named_port = [
    for k, v in var.named_ports :
    {
      name = k
      port = v
    }
  ]

  # Define default backend for load balancer based on the 'named_port' definition.
  default_port     = var.lb_port_default != null ? var.lb_port_default : local.named_port[0].port
  default_protocol = var.lb_protocol_default != null ? var.lb_protocol_default : local.named_port[0].name
  default_backend = {
    default = {
      description                     = null
      protocol                        = upper(local.default_protocol)
      port                            = local.default_port
      port_name                       = local.default_protocol
      timeout_sec                     = 10
      connection_draining_timeout_sec = null
      enable_cdn                      = false
      security_policy                 = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null
      custom_request_headers          = null

      health_check = {
        check_interval_sec  = null
        timeout_sec         = null
        healthy_threshold   = null
        unhealthy_threshold = null
        request_path        = var.default_url_request_path
        port                = local.default_port
        host                = null
        logging             = null
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = local.lb_groups

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
    }
  }

  # Add to user given backends only when 'include_default_backend' is true
  backends = merge(var.include_default_backend ? local.default_backend : null, var.backends)

}