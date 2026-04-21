project_id = "<your-project-id>"
region     = "us-east4"

########### Job Data ################
job_name    = "app-engine-http-job"
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
# for App Engine : my-instance-001.prod.web.pid-gcp-tlz-gke01-d0cc.uk.r.appspot.com/ping
app_engine_http_target = {
  http_method  = "POST"
  relative_uri = "/ping"
  body         = "sample description.."
  headers      = {}
  app_engine_routing = {
    service  = "web"
    version  = "prod"
    instance = "my-instance-001"
  }
}