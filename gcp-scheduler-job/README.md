# gcp-scheduler-job

This module creates a scheduler job infrastructure, given the target job details.
It supports creation of Pub/Sub, HTTP or App Engine HTTP end point job targets. It also supports combination of job targets in a single deployment depending on presense of respective target(s) in the input.

Refer to [examples](/examples) for sample tfvars for a given job target. 

HTTP job target currently supports OAuth using OIDC tokens using Service Account, however can be modified to support other authentication mechanisms as mentioned in [TF resource](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job) documentation.

To get more information about supported regions and job targets, see:
https://cloud.google.com/scheduler/docs

##Pre-requisites

1) Cloud Scheduler API (cloudscheduler.googleapis.com) should be enabled.

2) Project must contain an App Engine app that is located in one of the supported region.

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
| [google_cloud_scheduler_job.app_engine_http_job](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job) | resource |
| [google_cloud_scheduler_job.http_job](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job) | resource |
| [google_cloud_scheduler_job.pub_sub_job](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job) | resource |
| [google_compute_default_service_account.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_default_service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| job\_name | (Required) The name of the job. | `string` | n/a | yes |
| project\_id | (Required) The project ID in which the resources should be created. | `string` | n/a | yes |
| region | (Required) Region where the scheduler job resides. | `string` | n/a | yes |
| app\_engine\_http\_target | (Optional) Job created with  App Engine target if app\_engine\_http\_target is present in the variables. Structure is documented at https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job#app_engine_http_target | <pre>object({<br>    relative_uri = string,<br>    http_method  = string,<br>    body         = string,<br>    headers      = map(string)<br>    app_engine_routing = object({<br>      service  = string<br>      version  = string<br>      instance = string<br>    })<br>  })</pre> | `null` | no |
| attempt\_deadline | (Optional) The deadline for job attempts. If the request handler does not respond by this deadline then the request is cancelled. Cloud Scheduler will retry the job according to the RetryConfig. | `string` | `null` | no |
| description | (Optional) A human-readable description for the job. This string must not contain more than 500 characters | `string` | `null` | no |
| http\_target | (Optional) Job created with HTTP target if http\_target is present in the variables. Structure is documented at https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job#http_target | <pre>object({<br>    uri         = string,<br>    http_method = string,<br>    body        = string,<br>    headers     = map(string)<br>  })</pre> | `null` | no |
| pubsub\_target | (Optional) Job created with Pub/Sub target if pubsub\_target is present in the variables. Structure is documented at https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job#pubsub_target | <pre>object({<br>    topic_name = string,<br>    message    = string,<br>    attributes = string<br>  })</pre> | `null` | no |
| retry\_config | (Optional) By default, if a job does not complete successfully, meaning that an acknowledgement is not received from the handler, then it will be retried with exponential backoff according to the settings. Refer to https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job#retry_config for the object structure | <pre>object({<br>    count                = string,<br>    max_retry_duration   = string,<br>    min_backoff_duration = string,<br>    max_backoff_duration = string,<br>    max_doublings        = string<br>  })</pre> | `null` | no |
| schedule | (Optional) Describes the schedule on which the job will be executed. It uses the unix-cron format. | `string` | `""` | no |
| service\_account\_email | (optional) A Service account email for generating OIDC tokens for HTTP job target. If null then its picks up default compute engine service account. | `string` | `null` | no |
| time\_zone | (Optional) Specifies the time zone to be used in interpreting schedule. The value of this field must be a time zone name from the tz database | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| app-engine-http-job-id | Id of scheduler job with Apa engine HTTP target created |
| http-job-id | Id of scheduler job with HTTP target created |
| pubsub-job-id | Id of scheduler job with pubsub topic created |
