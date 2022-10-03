/*
Each project that gets created and will have any automation run WITHIN it, needs the following:
Project created
Automation SA created in *-lz-ops project for that project
State bucket created in *-lz-ops project for that project
Automation SA granted roles/storage.admin on that bucket
Automation SA granted deployment roles on that project
Kubernetes SA created in the bu_namespace for that project, with annotation of the above automation SA
Kubernetes role binding
*/

### Create *-lz-images project
module "images_project" {
  source          = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/project?ref=v4.3.0"
  parent          = local.ops_folder_id
  prefix          = null
  name            = local.images_project_name
  billing_account = var.billing_account_id
  services        = var.images_project_services
  labels          = local.labels
}

### Create TF state bucket and service account for infrastructure deployment automation
resource "google_storage_bucket" "images_automation" {
  project                     = module.automation_project.project_id
  name                        = "${module.images_project.project_id}-tf-state"
  location                    = var.gcs_defaults.location
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  labels = merge(local.labels, { tier = "gcp-bucket" })
}

module "images_automation_service_account" {
  source       = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/iam-service-account?ref=v4.3.0"
  project_id   = module.automation_project.project_id
  name         = module.images_project.project_id
  display_name = "Landing Zone automation account for ${module.images_project.project_id}"
  generate_key = false
  iam = {
    "roles/iam.workloadIdentityUser" = ["serviceAccount:${var.global_automation_project_id}.svc.id.goog[lz-bu-${var.unit_code}/${module.images_project.project_id}]"]
  }
}

### Grant SA storage admin role to bucket
resource "google_storage_bucket_iam_member" "images_member" {
  bucket = google_storage_bucket.images_automation.name
  role   = "roles/storage.admin"
  member = module.images_automation_service_account.iam_email
}

### Grant appropriate permissions for future automation in the images
### project to the above automation service account
resource "google_project_iam_member" "images_member" {
  for_each = toset(var.images_project_service_account_roles)
  project  = module.images_project.project_id
  role     = each.key
  member   = module.images_automation_service_account.iam_email
}

### k8s stuff in kubernetes.tf

### Optionally, setup GCR, granting access to the scanning service account
module "gcr" {
  source          = "git::https://git.gp-archcon.com/tf-sharedmodules-internal/gcp-container-registry.git"
  count           = var.enable_gcr ? 1 : 0
  project_id      = module.images_project.project_id
  location        = var.gcs_defaults.location
  use_iam_binding = false
  gcr_scan_member = length(var.scanning_service_account) > 0 ? "serviceAccount:${var.scanning_service_account}" : null
}
