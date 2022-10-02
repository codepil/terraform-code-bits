output "attestor" {
  description = "Created Attestor details"
  value       = google_binary_authorization_attestor.attestor
}

output "note" {
  description = "Created Container analysis note details"
  value       = google_container_analysis_note.build-note
}