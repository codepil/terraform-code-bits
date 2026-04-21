project_id = "<your-project-id>"
region     = "us-east4"

########### Job Data ################
job_name    = "http-job"
description = "sample description.."
schedule    = "*/5 * * * *" # every 5th minute

retry_config = {
  count                = 2,
  max_retry_duration   = "10s",
  min_backoff_duration = null,
  max_backoff_duration = null,
  max_doublings        = null
}

########### Job target ############
http_target = {
  http_method = "POST"
  uri         = "https://example.com/ping"
  body        = "sample description.."
  headers     = {}
}