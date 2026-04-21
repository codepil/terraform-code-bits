module "lb-ilb" {
  source  = "GoogleCloudPlatform/lb-internal/google"
  version = "4.0.0"
  # One LB per named port
  for_each = var.lb_type == "INTERNAL" && var.named_ports != null ? var.named_ports : {}

  region      = var.region
  project     = var.project_id
  network     = var.vpc_name
  subnetwork  = var.subnet_name
  name        = "${var.lb_name_prefix}-${each.key}"
  ports       = [each.value]
  ip_protocol = upper(each.key)
  # UDP based health checks are not supported currently, hence falling back to user input on type of health checks to be used.
  # TODO: for review, some of this constants are driven by App cycle, should we move this definition to var.ilb.health_check ?
  health_check = {
    type                = var.health_check_config.type
    check_interval_sec  = 5
    healthy_threshold   = 2
    timeout_sec         = 5
    unhealthy_threshold = 2
    response            = ""
    proxy_header        = "NONE"
    port                = var.health_check_config.check.port
    port_name           = null
    request             = null
    request_path        = null
    host                = null
    enable_log          = true
  }
  target_tags = local.target_tags
  source_tags = var.ilb_source_tags
  # MVP for now, to satisfy single MIG as in syslog collector infrastructure use case
  # TODO: Typically LB should take multiple MIG backends, this is to be refactored to include additional
  #       user defined backend in similar lines with backend defined for external LB in local.tf.
  #       Both backends has different schema based on base module used, research to get a common definition
  backends = [
    {
      group       = module.mig.group_manager.instance_group
      description = "backend services of internal load balancer, created by Terraform"
    }
  ]
}