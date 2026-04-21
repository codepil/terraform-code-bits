# gcp-storage-notification

This module creates a Google storage notification, given the GCS Bucket name and Pub/Sub topic ID.

Pre-req:
Enable the Pub/Sub API for the project that will receive notifications.
Refer to https://cloud.google.com/storage/docs/reporting-changes#prereqs for permissions required on pub/sub topic & GCS bucket

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.7 |
| google | >= 3.65.0 |

## Providers

| Name | Version |
|------|---------|
| google | >= 3.65.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_pubsub_topic_iam_binding.binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_binding) | resource |
| [google_storage_notification.notification](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_notification) | resource |
| [google_storage_project_service_account.gcs_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/storage_project_service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | (Required) The project ID in which the resources should be created. | `string` | n/a | yes |
| pubsub\_topic\_name | (Required) The Cloud PubSub topic to which this subscription publishes. Expects either the topic name, assumed to belong to the default GCP provider project, or the project-level name, i.e. 'projects/my-gcp-project/topics/my-topic' or 'my-topic'. If the project is not set in the provider, you will need to use the project-level name. | `string` | n/a | yes |
| storage\_bucket\_name | (Required) Name of the GCS Bucket | `string` | n/a | yes |
| event\_types | (Optional) List of event type filters for this notification config. If not specified, Cloud Storage will send notifications for all event types. The valid types are @ https://cloud.google.com/storage/docs/pubsub-notifications#events | `list(string)` | `null` | no |
| message\_attributes | (Optional) A custom set of key/value attribute pairs to attach to each Cloud PubSub message published for this notification subscription. refer to https://cloud.google.com/storage/docs/pubsub-notifications#attributes for default attributes | `map(string)` | `{}` | no |
| object\_name\_prefix | (Optional) Specifies a prefix path filter for this notification config. Cloud Storage will only send notifications for objects in this bucket whose names begin with the specified prefix. | `string` | `null` | no |
| payload\_format | (Optional) The desired content of the Payload. One of 'JSON\_API\_V1' or 'NONE' | `string` | `"JSON_API_V1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| self\_link | The URI of the created notification resource |
