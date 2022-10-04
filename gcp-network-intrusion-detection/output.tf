output "mig" {
  description = "Suricata instance group manager"
  value       = module.mig.group_manager
}

output "packet_mirroring_policies" {
  description = "Packet mirroring policy identifier"
  value       = google_compute_packet_mirroring.ids
}