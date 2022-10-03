project_id = "<your-project-id>"
region     = "us-east4"
########### Job Data ################
job_name    = "test-job"
description = "sample description.."
schedule    = "*/2 * * * *" # every 2nd minute

retry_config = {
  count                = 2,
  max_retry_duration   = "10s",
  min_backoff_duration = null,
  max_backoff_duration = null,
  max_doublings        = null
}

########### Job target ############
pubsub_target = {
  topic_name = "test-topic",
  message    = "test message payload"
  attributes = null
}
