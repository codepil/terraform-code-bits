output "cluster_name" {
  description = "Cluster name"
  value       = data.google_container_cluster.gke-terraform.name
}

output "endpoint" {
  description = "Cluster Endpoint"
  value       = data.google_container_cluster.gke-terraform.endpoint
}

output "ns_self_links" {
  description = "Cluster's namespace self links."
  value       = { for p in sort(keys(var.nsname)) : p => kubernetes_namespace.gkenamespace[p].metadata[0].self_link }
}
