# MVP for now, creates an external load balancer with created MIG as backend
module "lb-https" {
  source               = "GoogleCloudPlatform/lb-http/google"
  version              = "5.1.0"
  count                = var.lb_type == "EXTERNAL" && var.lb_name_prefix != null ? 1 : 0
  project              = var.project_id
  name                 = var.lb_name_prefix
  target_tags          = local.target_tags
  firewall_networks    = local.firewall_networks
  backends             = local.backends
  ssl                  = true
  use_ssl_certificates = true
  ssl_certificates     = var.ssl_certificates
}