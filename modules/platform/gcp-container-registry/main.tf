/*
* # gcp-container-registry
*
* This module creates a container registry in GCP, and assigns
* IAM members to specified roles on the underlying bucket behind 
* the container registry.
*
* Requires the following APIs:
* * containerregistry.googleapis.com
*/

/*
 * NOTE: The code here-in was copied/derived from
 * https://github.com/terraform-google-modules/cloud-foundation-fabric/tree/master/modules/container-registry
 * for customized use internally by Your company.  As such, the original license
 * is below.
 */

resource "google_container_registry" "registry" {
  project  = var.project_id
  location = var.location
}

# Apply additive IAM grants if var.use_iam_binding is false
resource "google_storage_bucket_iam_member" "members" {
  for_each = var.use_iam_binding ? {} : local.iam_additive
  role     = each.value["role"]
  member   = each.value["member"]
  bucket   = google_container_registry.registry.id
}

# Apply authoritative IAM grants if var.use_iam_binding is true
resource "google_storage_bucket_iam_binding" "bindings" {
  for_each = var.use_iam_binding ? var.iam_role_members : {}
  bucket   = google_container_registry.registry.id
  role     = each.key
  members  = each.value
}

# Grant a role on GCR's storage bucket, to scan for image vulnerabilities
resource "google_storage_bucket_iam_member" "member" {
  bucket   = google_container_registry.registry.id
  role    = "roles/storage.objectViewer"
  member = var.gcr_scan_member
}
