/*
* # gcp-scheduler-job
*
* This module creates a scheduler job infrastructure, given the target job details.
* It supports creation of Pub/Sub, HTTP or App Engine HTTP end point job targets.
*
* To get more information about supported regions and job targets, see:
* https://cloud.google.com/scheduler/docs
*
* Pre-req:
* Cloud Scheduler API should be enabled.
* For App Engine targets, project must contain an App Engine app that is located in one of the supported region.
*/

/*
* TODO:
* 1) Explore ways to reduce code repetition in each resource definition.
*/

resource "google_cloud_scheduler_job" "pub_sub_job" {
  count            = var.pubsub_target == null ? 0 : 1
  name             = var.job_name
  description      = var.description
  schedule         = var.schedule
  time_zone        = var.time_zone
  attempt_deadline = var.attempt_deadline == null ? local.default_deadline.pub-sub : var.attempt_deadline

  retry_config {
    retry_count          = var.retry_config.count
    max_retry_duration   = var.retry_config.max_backoff_duration
    min_backoff_duration = var.retry_config.min_backoff_duration
    max_backoff_duration = var.retry_config.max_backoff_duration
    max_doublings        = var.retry_config.max_doublings
  }

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = local.topic
    data       = base64encode(var.pubsub_target.message)
  }

}

resource "google_cloud_scheduler_job" "http_job" {
  count            = var.http_target == null ? 0 : 1
  name             = var.job_name
  description      = var.description
  schedule         = var.schedule
  time_zone        = var.time_zone
  attempt_deadline = var.attempt_deadline == null ? local.default_deadline.http : var.attempt_deadline

  retry_config {
    retry_count          = var.retry_config.count
    max_retry_duration   = var.retry_config.max_backoff_duration
    min_backoff_duration = var.retry_config.min_backoff_duration
    max_backoff_duration = var.retry_config.max_backoff_duration
    max_doublings        = var.retry_config.max_doublings
  }

  http_target {
    http_method = var.http_target.http_method
    uri         = var.http_target.uri
    body        = base64encode(var.http_target.body)
    headers     = var.http_target.headers
    oidc_token {
      service_account_email = local.service_account_email
    }
  }
}

resource "google_cloud_scheduler_job" "app_engine_http_job" {
  count            = var.app_engine_http_target == null ? 0 : 1
  name             = var.job_name
  description      = var.description
  schedule         = var.schedule
  time_zone        = var.time_zone
  attempt_deadline = var.attempt_deadline == null ? local.default_deadline.app-eng : var.attempt_deadline

  retry_config {
    retry_count          = var.retry_config.count
    max_retry_duration   = var.retry_config.max_backoff_duration
    min_backoff_duration = var.retry_config.min_backoff_duration
    max_backoff_duration = var.retry_config.max_backoff_duration
    max_doublings        = var.retry_config.max_doublings
  }

  app_engine_http_target {
    http_method = var.app_engine_http_target.http_method
    body        = base64encode(var.app_engine_http_target.body)
    headers     = var.app_engine_http_target.headers

    app_engine_routing {
      service  = var.app_engine_http_target.app_engine_routing.service
      version  = var.app_engine_http_target.app_engine_routing.version
      instance = var.app_engine_http_target.app_engine_routing.instance
    }

    relative_uri = var.app_engine_http_target.relative_uri
  }
}



