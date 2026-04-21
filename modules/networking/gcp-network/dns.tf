module "cloud-dns" {
  source                             = "terraform-google-modules/cloud-dns/google"
  version                            = "3.1.0"
  for_each                           = var.enable_private_access_routing ? local.dns_zones : {}
  project_id                         = var.project_id
  type                               = "private"
  name                               = each.value.zone_name
  domain                             = each.value.domain
  private_visibility_config_networks = each.value.private_visibility_config_networks
  recordsets                         = each.value.record_sets
}
