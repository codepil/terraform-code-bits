locals {
  automation_sa_roles = [
    # General non-admin permissions
    "roles/editor",
    # Admin role needed for the SA to manage project-level IAM bindings
    "roles/resourcemanager.projectIamAdmin",
    # Admin roles needed for the SA to manage resource-level IAM bindings
    "roles/cloudkms.admin",
    "roles/compute.instanceAdmin",
    "roles/compute.networkAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/pubsub.admin",
    "roles/storage.admin",
    # Admin role needed to setup/deploy KMS, encryptor/decryptor needed during deployments
    "roles/cloudkms.admin",
    "roles/cloudkms.cryptoKeyEncrypterDecrypter",
    # Admin role needed to setup and/or integrate with Secrets Manager
    "roles/secretmanager.admin",
    # Admin role needed to create setup IAP and grant access to tunnels to users/serviceaccounts
    "roles/iap.admin",
    # Admin role needed to deploy Twistlock and Istio to any GKE clusters created.
    "roles/container.admin",
    # Admin role to manage logging configs in project
    "roles/logging.admin",
    # App Engine Creator (Editor role has everything else except file reader, which hopefully we don't need)
    "roles/appengine.appCreator",
  ]

  # Aggregate map of {ROLE => [MEMBERS]} for default IAM binding groups and  any additional roles from tfvars
  all_project_iam_members = var.iam_role_members

  static_labels = {
    unit_code             = var.unit_code
    lifecycle             = var.environment
    automation_project_id = var.automation_project_id
    businessregion        = local.business_region
    country               = local.geo_location
    tier                  = "gcp-project"
  }

  labels = merge(var.additional_labels, local.static_labels)
  environment_char_mapping = {
    "dev"       = "d"
    "qa"        = "q"
    "cert-cde"  = "c"
    "prod-cde"  = "p"
    "cert-ncde" = "s"
    "prod-ncde" = "g"
    "svcs"      = "p"
  }
  environment_char = lookup(local.environment_char_mapping, var.environment, "g")
  # Return either the specified var.project_name, or a calculated one based on:
  #  pid-go<country><region><buregion><environment>-<unit_code>-<suffix>
  project_name = length(var.project_name) > 0 ? var.project_name : (
    "pid-go${var.geo_location}${var.region}${var.business_region}${local.environment_char}-${var.unit_code}-${var.project_descriptor}"
  )
  business_region = length(var.project_name) > 0 ? substr(var.project_name, 9, 2) : var.business_region
  geo_location    = length(var.project_name) > 0 ? substr(var.project_name, 6, 2) : var.geo_location
}
