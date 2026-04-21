output "pubsub-job-id" {
  description = "Id of scheduler job with pubsub topic created"
  value       = var.pubsub_target != null ? google_cloud_scheduler_job.pub_sub_job[0].id : null
}

output "http-job-id" {
  description = "Id of scheduler job with HTTP target created"
  value       = var.http_target != null ? google_cloud_scheduler_job.http_job[0].id : null
}

output "app-engine-http-job-id" {
  description = "Id of scheduler job with Apa engine HTTP target created"
  value       = var.app_engine_http_target != null ? google_cloud_scheduler_job.app_engine_http_job[0].id : null
}
