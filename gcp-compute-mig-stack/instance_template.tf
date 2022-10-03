# Create instance template, with a given service account
module "instance_template_service_account" {
  source       = "git::https://github.com/codepil/terraform-code-bits/gcp-service-account?ref=v1.0.1"
  count        = local.create_instance_template ? 1 : 0
  project_id   = var.project_id
  name         = var.instance_service_account_id
  display_name = "Terraform-managed-compute-instance-template"
  project_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
  ]
}

# MVP for now, additional variables can be added, like attaching_disks ..etc to enhance.
module "instance-template" {
  source                = "github.com/terraform-google-modules/cloud-foundation-fabric.git//modules/compute-vm?ref=v4.8.0"
  count                 = local.create_instance_template ? 1 : 0
  project_id            = var.project_id
  use_instance_template = true

  name               = var.instance_name
  region             = var.region
  zones              = var.zones
  tags               = concat([var.instance_tag], var.other_instance_tags)
  network_interfaces = var.network_interfaces
  boot_disk          = var.boot_disk

  service_account = module.instance_template_service_account[0].email

  labels        = local.labels
  metadata      = local.metadata
  instance_type = var.instance_type
}