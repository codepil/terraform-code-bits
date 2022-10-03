output "lm_vms" {
  description = "List of LM collector instances created"
  value       = module.lm_collector_vms.self_links
}