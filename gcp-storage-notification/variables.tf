variable "project_id" {
  description = "(Required) The project ID in which the resources should be created."
  type        = string
}

variable "storage_bucket_name" {
  description = "(Required) Name of the GCS Bucket"
  type        = string
}

variable "payload_format" {
  description = "(Optional) The desired content of the Payload. One of 'JSON_API_V1' or 'NONE'"
  type        = string
  default     = "JSON_API_V1"
}

variable "pubsub_topic_name" {
  description = "(Required) The Cloud PubSub topic to which this subscription publishes. Expects either the topic name, assumed to belong to the default GCP provider project, or the project-level name, i.e. 'projects/my-gcp-project/topics/my-topic' or 'my-topic'. If the project is not set in the provider, you will need to use the project-level name."
  type        = string
}

variable "event_types" {
  description = "(Optional) List of event type filters for this notification config. If not specified, Cloud Storage will send notifications for all event types. The valid types are @ https://cloud.google.com/storage/docs/pubsub-notifications#events"
  type        = list(string)
  default     = null
}

variable "message_attributes" {
  description = "(Optional) A custom set of key/value attribute pairs to attach to each Cloud PubSub message published for this notification subscription. refer to https://cloud.google.com/storage/docs/pubsub-notifications#attributes for default attributes"
  type        = map(string)
  default     = {}
}

variable "object_name_prefix" {
  description = "(Optional) Specifies a prefix path filter for this notification config. Cloud Storage will only send notifications for objects in this bucket whose names begin with the specified prefix."
  type        = string
  default     = null
}
