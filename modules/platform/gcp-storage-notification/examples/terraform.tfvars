project_id          = "<your_project_id>"
storage_bucket_name = "tlz-test-bucket"
pubsub_topic_name   = "test-topic"

# optional
event_types = ["OBJECT_FINALIZE", "OBJECT_METADATA_UPDATE"]
message_attributes = {
  new-attribute = "new-attribute-value"
}