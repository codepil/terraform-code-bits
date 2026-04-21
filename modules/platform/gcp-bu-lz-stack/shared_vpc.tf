################################################################################
# Landing Zone Shared VPC host projects                                        #
################################################################################

module "env_svpc_hosts" {
  for_each        = local.shared_vpc_hosts
  source          = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/project?ref=v4.3.0"
  billing_account = var.billing_account_id
  parent          = local.ops_folder_id
  prefix          = null
  name            = each.value
  services        = var.shared_vpc_host_project_services
  shared_vpc_host_config = {
    enabled          = true
    service_projects = []
  }
  labels = local.labels
}

resource "google_storage_bucket" "env_svpc_automation" {
  for_each                    = local.shared_vpc_hosts
  project                     = module.automation_project.project_id
  name                        = "${module.env_svpc_hosts[each.key].project_id}-tf-state"
  location                    = "US"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  labels = merge(local.labels, { tier = "gcp-bucket" })
}

module "env_svpc_automation_service_accounts" {
  for_each     = local.shared_vpc_hosts
  source       = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/iam-service-account?ref=v4.3.0"
  project_id   = module.automation_project.project_id
  name         = module.env_svpc_hosts[each.key].project_id
  display_name = "Landing Zone automation account for ${module.env_svpc_hosts[each.key].project_id}"
  generate_key = false
  iam = {
    "roles/iam.workloadIdentityUser" = ["serviceAccount:${var.global_automation_project_id}.svc.id.goog[lz-bu-${var.unit_code}/${module.env_svpc_hosts[each.key].project_id}]"]
  }
}

resource "google_project_iam_member" "env_svpc_automation_project_member" {
  for_each = local.environment_svpc_iam_members
  project  = module.env_svpc_hosts[each.value.environment].project_id
  role     = each.value.role
  member   = each.value.member
}

resource "google_storage_bucket_iam_member" "member" {
  for_each = local.shared_vpc_hosts
  bucket   = google_storage_bucket.env_svpc_automation[each.key].name
  role     = "roles/storage.admin"
  member   = module.env_svpc_automation_service_accounts[each.key].iam_email
}
