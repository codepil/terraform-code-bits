
resource "random_id" "project_suffix" {
  byte_length = 2
}

resource "random_id" "tf_state_bucket_suffix" {
  byte_length = 2
}

###############################################################################
# Project creation
###############################################################################

module "project" {
  source          = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/project?ref=v4.3.0"
  billing_account = var.billing_account
  parent          = var.parent_folder
  prefix          = null
  name            = var.randomize_project_id ? "${local.project_name}-${random_id.project_suffix.hex}" : local.project_name
  services        = var.project_services
  service_config = {
    disable_on_destroy         = var.allow_destroy ? false : true # allow TF resources to be destroyed and leave APIs intact if allow_destroy is true, as this is needed for destroying project that may contain compute/other resources
    disable_dependent_services = var.allow_destroy ? false : true
  }
  # Only expose non-authoritative mapping to avoid TF SA lockout
  iam_additive   = local.all_project_iam_members
  policy_boolean = var.policy_boolean
  policy_list    = var.policy_list
  labels         = local.labels
}

# Ensure any required APIs are also enabled on the automation project
# See https://cloud.google.com/service-usage/docs/enabled-service#calling
resource "google_project_service" "automation_project_apis" {
  for_each = var.project_services
  project  = var.automation_project_id
  service  = each.value

  disable_on_destroy         = false
  disable_dependent_services = false
}

###############################################################################
# Project autoamtion service account and TF state bucket
###############################################################################

resource "google_service_account" "project_automation" {
  project      = var.automation_project_id
  account_id   = module.project.project_id
  display_name = "Automation Service Account (Terraform managed)"
  description  = "Landing Zone automation account for ${module.project.project_id}"
}

resource "google_project_iam_member" "project_automation" {
  for_each = toset(local.automation_sa_roles)
  project  = module.project.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.project_automation.email}"
}

resource "google_storage_bucket" "project_automation" {
  project                     = var.automation_project_id
  name                        = "${module.project.project_id}-tf-state"
  force_destroy               = var.allow_destroy
  uniform_bucket_level_access = true
  location                    = "US"
  labels                      = local.labels
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_iam_member" "project_automation" {
  bucket = google_storage_bucket.project_automation.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.project_automation.email}"
}

################################################################################
# LZ service-account workload identities                                       #
################################################################################

provider "kubernetes" {
  load_config_file = "false"
}

resource "kubernetes_service_account" "project_automation" {
  metadata {
    namespace = "lz-bu-${var.unit_code}"
    name      = module.project.project_id
    annotations = {
      "iam.gke.io/gcp-service-account" : google_service_account.project_automation.email
    }
    labels = { sdlc = var.environment, project = module.project.project_id }
  }
  automount_service_account_token = true
}

resource "google_service_account_iam_member" "workload_identity" {
  service_account_id = google_service_account.project_automation.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.global_automation_project_id}.svc.id.goog[lz-bu-${var.unit_code}/${module.project.project_id}]"
}
