output "mig-vms" {
  value = var.mig_access != null ? data.google_compute_region_instance_group.data_source[0].instances: []
}