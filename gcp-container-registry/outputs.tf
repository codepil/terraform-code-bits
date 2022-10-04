output "bucket_id" {
  description = "ID(name) of the GCS bucket created for GCR."
  value       = google_container_registry.registry.id
}
output "bucket_self_link" {
  description = "Self_link of the GCS bucket created for GCR."
  value       = google_container_registry.registry.bucket_self_link
}