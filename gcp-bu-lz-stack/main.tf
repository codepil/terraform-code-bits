/**
* # GCP Landing Zone Business Unit Stack
*
* This module is used as a blueprint to create and manage Landing Zone instances for each business unit or operating unit.
*
* This module creates the following:
*
* * a root Google Cloud folder for this landing zone
* * three SDLC-specific folders to contain application projects
*     * Dev-QA, Non-CDE, and CDE, all under the root LZ folder
* * a BU Operations folder under the root LZ folder, containing:
*     * a landing zone operations project to store LZ-specific operational resources such as Terraform state and Terraform service accounts
* * three SDLC-specific Shared VPC host projects, for use by application projects as needed
* * one "shared" Shared VPC host project, to be connected to all SDLC environments as needed
* * any standardized organization policies, IAM policies, and user groups to support various Landing Zone operations
* * a BU-specific Google Cloud service account for managing BU application projects for each SDLC folder and the Operations folder
* * Kubernetes service accounts with workload identity bindings for each project and folder
*/

###############################################################################
#                            Folders and folder IAM                           #
###############################################################################

resource "google_folder" "unit" {
  display_name = var.unit_name
  parent       = var.root_node
}

resource "google_folder" "environment" {
  for_each     = local.environments
  display_name = each.value
  parent       = google_folder.unit.name
}

resource "google_folder_iam_binding" "unit" {
  for_each = local.all_unit_folder_iam_bindings
  folder   = google_folder.unit.name
  role     = each.key
  members  = each.value
}

resource "google_folder_iam_binding" "environment" {
  for_each = {
    for binding in local.all_environment_folder_iam_bindings : "${binding.env}-${binding.role}" => binding
  }
  folder  = each.value.folder
  role    = each.value.role
  members = each.value.members
}

###############################################################################
#                            Organizational Policy                            #
###############################################################################

resource "google_folder_organization_policy" "unit-boolean" {
  for_each   = var.unit_policy_boolean
  folder     = google_folder.unit.name
  constraint = each.key
  dynamic "boolean_policy" {
    for_each = each.value == null ? [] : [each.value]
    iterator = policy
    content {
      enforced = policy.value
    }
  }

  dynamic "restore_policy" {
    for_each = each.value == null ? [""] : []
    content {
      default = true
    }
  }
}

resource "google_folder_organization_policy" "unit-list" {
  for_each   = var.unit_policy_list
  folder     = google_folder.unit.name
  constraint = each.key

  dynamic "list_policy" {
    for_each = each.value.status == null ? [] : [each.value]
    iterator = policy
    content {
      inherit_from_parent = policy.value.inherit_from_parent
      suggested_value     = policy.value.suggested_value
      dynamic "allow" {
        for_each = policy.value.status ? [""] : []
        content {
          values = (
            try(length(policy.value.values) > 0, false)
            ? policy.value.values
            : null
          )
          all = (
            try(length(policy.value.values) > 0, false)
            ? null
            : true
          )
        }
      }
      dynamic "deny" {
        for_each = policy.value.status ? [] : [""]
        content {
          values = (
            try(length(policy.value.values) > 0, false)
            ? policy.value.values
            : null
          )
          all = (
            try(length(policy.value.values) > 0, false)
            ? null
            : true
          )
        }
      }
    }
  }
}

resource "google_folder_organization_policy" "environments-boolean" {
  for_each   = local.environments_policy_boolean_pairs
  folder     = google_folder.environment[each.value.environment].name
  constraint = each.value.constraint
  dynamic "boolean_policy" {
    for_each = each.value.constraint_setting == null ? [] : [each.value.constraint_setting]
    iterator = policy
    content {
      enforced = policy.value
    }
  }
  dynamic "restore_policy" {
    for_each = each.value.constraint_setting == null ? [""] : []
    content {
      default = true
    }
  }
}

resource "google_folder_organization_policy" "environments-list" {
  for_each   = local.environments_policy_list_pairs
  folder     = google_folder.environment[each.value.environment].name
  constraint = each.value.constraint

  dynamic "list_policy" {
    for_each = each.value.constraint_setting.status == null ? [] : [each.value.constraint_setting]
    iterator = policy
    content {
      inherit_from_parent = policy.value.inherit_from_parent
      suggested_value     = policy.value.suggested_value
      dynamic "allow" {
        for_each = policy.value.status ? [""] : []
        content {
          values = (
            try(length(policy.value.values) > 0, false)
            ? policy.value.values
            : null
          )
          all = (
            try(length(policy.value.values) > 0, false)
            ? null
            : true
          )
        }
      }
      dynamic "deny" {
        for_each = policy.value.status ? [] : [""]
        content {
          values = (
            try(length(policy.value.values) > 0, false)
            ? policy.value.values
            : null
          )
          all = (
            try(length(policy.value.values) > 0, false)
            ? null
            : true
          )
        }
      }
    }
  }
}

resource "google_folder_organization_policy" "trusted-images" {
  folder     = google_folder.unit.name
  constraint = "compute.trustedImageProjects"
  list_policy {
    inherit_from_parent = true
    allow {
      values = local.unit_trusted_images_projects
    }
  }
}

################################################################################
#                           Automation Project                                 #
################################################################################

module "automation_project" {
  source          = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/project?ref=v4.3.0"
  parent          = local.ops_folder_id
  prefix          = null
  name            = local.automation_project_name
  billing_account = var.billing_account_id
  services        = local.automation_project_services
  labels          = local.labels
  # do not disable services in GCP upon revokation here, since
  # infrastructure projects may be reliant upon them
  service_config = {
    disable_on_destroy         = false
    disable_dependent_services = false
  }
}

################################################################################
#                                Service Accounts                              #
################################################################################

resource "google_service_account" "environment" {
  for_each     = local.environments
  project      = var.global_automation_project_id
  account_id   = "act-lz-bu-${var.unit_code}-${each.key}-master"
  display_name = "${var.unit_code} ${each.key} (Terraform managed)."
}

resource "google_project_iam_member" "environment_automation_project_iam_member" {
  for_each = local.environment_automation_iam_members
  project  = module.automation_project.project_id
  role     = each.value.role
  member   = each.value.member
}

###############################################################################
#                            Billing Account IAM                              #
###############################################################################

resource "google_billing_account_iam_member" "binding" {
  for_each           = var.create_billing_iam_bindings ? local.environments : {}
  billing_account_id = var.billing_account_id
  role               = "roles/billing.user"
  member             = "serviceAccount:${google_service_account.environment[each.key].email}"
}

################################################################################
#                               GCS and GCS IAM                                #
################################################################################

resource "google_storage_bucket" "tfstate" {
  for_each                    = local.environments
  project                     = var.global_automation_project_id
  name                        = "bkt-go${var.country_code}g${var.business_region}po-lz-bu-${var.unit_code}-${each.key}-tf"
  location                    = var.gcs_defaults.location
  storage_class               = var.gcs_defaults.storage_class
  force_destroy               = false
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  labels = merge(local.labels, { tier = "gcp-bucket" })
}


resource "google_storage_bucket_iam_binding" "bindings" {
  for_each = local.environments
  bucket   = google_storage_bucket.tfstate[each.key].name
  role     = "roles/storage.objectAdmin"
  members  = ["serviceAccount:${google_service_account.environment[each.key].email}"]
}
