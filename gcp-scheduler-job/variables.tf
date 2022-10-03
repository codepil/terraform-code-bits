variable "project_id" {
  description = "(Required) The project ID in which the resources should be created."
  type        = string
}

variable "region" {
  description = "(Required) Region where the scheduler job resides."
  type        = string
}

variable "job_name" {
  description = "(Required) The name of the job."
  type        = string
}

variable "description" {
  description = "(Optional) A human-readable description for the job. This string must not contain more than 500 characters"
  type        = string
  default     = null
}

variable "schedule" {
  description = "(Optional) Describes the schedule on which the job will be executed. It uses the unix-cron format."
  type        = string
  default     = ""
}

variable "time_zone" {
  type        = string
  description = "(Optional) Specifies the time zone to be used in interpreting schedule. The value of this field must be a time zone name from the tz database"
  default     = null
}

variable "attempt_deadline" {
  description = "(Optional) The deadline for job attempts. If the request handler does not respond by this deadline then the request is cancelled. Cloud Scheduler will retry the job according to the RetryConfig."
  type        = string
  default     = null
}

variable "retry_config" {
  description = "(Optional) By default, if a job does not complete successfully, meaning that an acknowledgement is not received from the handler, then it will be retried with exponential backoff according to the settings. Refer to https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job#retry_config for the object structure"
  type = object({
    count                = string,
    max_retry_duration   = string,
    min_backoff_duration = string,
    max_backoff_duration = string,
    max_doublings        = string
  })
  default = null
}

variable "pubsub_target" {
  description = "(Optional) Job created with Pub/Sub target if pubsub_target is present in the variables. Structure is documented at https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job#pubsub_target"
  type = object({
    topic_name = string,
    message    = string,
    attributes = string
  })
  default = null
}

variable "http_target" {
  description = "(Optional) Job created with HTTP target if http_target is present in the variables. Structure is documented at https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job#http_target"
  type = object({
    uri         = string,
    http_method = string,
    body        = string,
    headers     = map(string)
  })
  default = null
}

variable "service_account_email" {
  description = "(optional) A Service account email for generating OIDC tokens for HTTP job target. If null then its picks up default compute engine service account. "
  type        = string
  default     = null
}

variable "app_engine_http_target" {
  description = "(Optional) Job created with  App Engine target if app_engine_http_target is present in the variables. Structure is documented at https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job#app_engine_http_target"
  type = object({
    relative_uri = string,
    http_method  = string,
    body         = string,
    headers      = map(string)
    app_engine_routing = object({
      service  = string
      version  = string
      instance = string
    })
  })
  default = null
}
