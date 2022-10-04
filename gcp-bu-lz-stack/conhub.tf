################################################################################
#                              Connectivity Hub                                #
################################################################################

/**
* As part of the LZ scaffolding, create the following resources to integrate
* with connectivity hub:
* - a "gateway" google_cloud_project for each LZ environment: `devqa`, `noncde`, and `cde`
* - one VPC network for each gateway project
* - an IAM binding for each SVPC TF service account to peer with their gateway network
* - an IAM binding for the NETS automation SA to manage each gateway project
*/

module "conhub_spoke_project" {
  for_each        = var.enable_conhub ? local.conhub_spokes : {}
  source          = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/project?ref=v4.3.0"
  billing_account = var.billing_account_id
  parent          = local.ops_folder_id
  prefix          = null
  name            = each.value
  services = [
    "logging.googleapis.com",
    "secretmanager.googleapis.com",
    "serviceusage.googleapis.com",
    "stackdriver.googleapis.com",
  ]
  labels = local.labels
}

module "conhub_spoke_vpc" {
  for_each                        = module.conhub_spoke_project
  source                          = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc?ref=v4.3.0"
  project_id                      = local.conhub_spokes[each.key]
  name                            = replace(local.conhub_spokes[each.key], "pid-", "vpc-")
  delete_default_routes_on_create = true
  routing_mode                    = "REGIONAL"
}

resource "google_project_iam_binding" "conhub_spoke_admin" {
  for_each = var.enable_conhub ? local.environments_chs : {}
  project  = module.conhub_spoke_project[each.key].project_id
  role     = "roles/compute.networkAdmin"

  members = [
    "serviceAccount:${var.conhub_mgmt_service_accounts[each.key]}"
  ]
}

resource "google_project_iam_binding" "conhub_peering_delegate" {
  for_each = var.enable_conhub ? { for item in local.all_conhub_delegate_roles : "${item[0]}-${item[1]}" => {
    environment = item[0]
    role        = item[1]
    email       = module.env_svpc_automation_service_accounts[item[0]].email
  } } : {}
  project = module.conhub_spoke_project[each.value.environment].project_id
  role    = each.value.role

  members = [
    "serviceAccount:${each.value.email}",
  ]
}
