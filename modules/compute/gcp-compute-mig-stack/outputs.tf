output "instance_template" {
  description = "Instance template resource."
  value       = data.google_compute_instance_template.default
}

output "group_manager" {
  description = "Instance group resource."
  value       = var.name != null ? module.mig.group_manager : null
}

output "mig_health_check" {
  description = "Auto-created health-check resource."
  value       = var.name != null ? module.mig.health_check : null
}

output "mig_autoscaler" {
  description = "Auto-created autoscaler resource."
  value       = var.name != null ? module.mig.autoscaler : null
}

output "elb-https" {
  description = "Details of external load balancer resource."
  value       = var.lb_type == "EXTERNAL" ? module.lb-https : null
}

output "ilb" {
  description = "Details of internal load balancer resource."
  value       = var.lb_type == "INTERNAL" ? module.lb-ilb : null
}