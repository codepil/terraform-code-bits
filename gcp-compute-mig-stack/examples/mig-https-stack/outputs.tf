
output "group_manager" {
  description = "Instance group resource."
  value       = module.mig-https-stack.group_manager
}

output "mig_health_check" {
  description = "Auto-created health-check resource."
  value       = module.mig-https-stack.mig_health_check
}

output "lb_backend_services" {
  description = "The backend service resources of HTTPS load balancer."
  value       = module.mig-https-stack.lb_backend_services
}