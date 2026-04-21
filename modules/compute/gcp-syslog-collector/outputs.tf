output "group_manager_id" {
  description = "Instance group resource identifier"
  value       = module.mig-syslog-collector.group_manager.id
}

output "tcp_lb_ip_address" {
  description = "IP address of TCP load balancer"
  value       = module.mig-syslog-collector.ilb.tcp.ip_address
}

output "udp_lb_ip_address" {
  description = "IP address of UDP load balancer"
  value       = module.mig-syslog-collector.ilb.udp.ip_address
}