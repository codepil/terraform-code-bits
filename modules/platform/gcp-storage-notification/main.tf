/*
* # gcp-storage-notification
*
* This module creates a Google storage notification, given the GCS Bucket name and Pub/Sub topic ID.
*
* Pre-req:
* Enable the Pub/Sub API for the project that will receive notifications.
* Refer to https://cloud.google.com/storage/docs/reporting-changes#prereqs for permissions required on pub/sub topic & GCS bucket
*/

resource "google_storage_notification" "notification" {
  bucket             = var.storage_bucket_name
  payload_format     = var.payload_format
  topic              = var.pubsub_topic_name
  event_types        = var.event_types
  custom_attributes  = var.message_attributes
  object_name_prefix = var.object_name_prefix

  depends_on = [google_pubsub_topic_iam_binding.binding]
}

// Enable notifications by giving the correct IAM permission to the unique service account.
resource "google_pubsub_topic_iam_binding" "binding" {
  topic   = var.pubsub_topic_name
  role    = "roles/pubsub.publisher"
  members = local.members
}
