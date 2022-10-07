output "self_link" {
  description = "The URI of the created notification resource"
  value       = google_storage_notification.notification.self_link
}
