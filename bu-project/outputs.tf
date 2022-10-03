output "project_id" {
  description = "Project ID of the resulting project"
  value       = module.project.project_id
}

output "project_name" {
  description = "Display name of the resulting project"
  value       = module.project.name
}

output "project_number" {
  description = "Project number of the resulting project"
  value       = module.project.number
}

output "project_state_bucket" {
  description = "Terraform state bucket for this project"
  value       = google_storage_bucket.project_automation.name
}

output "project_automation_service_account" {
  description = "Google service account for project automation"
  value       = google_service_account.project_automation.email
}

output "project_automation_kubernetes_namespace" {
  description = "Kubernetes namespace for executing project automation pipelines"
  value       = kubernetes_service_account.project_automation.metadata.0.namespace
}

output "project_automation_kubernetes_service_account" {
  description = "Kuberentes ServiceAccount with workload identity bindings for this project"
  value       = kubernetes_service_account.project_automation.metadata.0.name
}
