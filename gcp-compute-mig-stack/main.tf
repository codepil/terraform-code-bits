/*
* # gcp-compute-mig-stack
*
* This module creates a Managed Instance Group(MIG) stack by creating necessary stack elements like Service Accounts, Instance Templates and Load Balancers along with MIGs having Auto Scaler and Health checks enabled.
*
* This module can be used for,
*
* * Creating MIG, given instance template
* * Creating MIG and load balancers, given instance template
* * Given the image URL, Creating Instance Template & MIG
* * * Optionally creating HTTPS external Load Balancer, with MIG as a default backend service
* * * Optionally creating internal TCP/UDP Load Balancer, with MIG as a default backend service
* * Adding additional Canary versions of instance(s) to MIG
*
* Refer to [examples](/examples) directory for possible scenario(s)/values.
*
*
* ## Pre-requisites
* * Project should have enabled Compute Engine API (compute.googleapis.com).
*
*/

# Creates Managed Instance Group
module "mig" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric.git//modules/compute-mig?ref=v4.8.0"
  project_id = var.project_id
  location   = var.location
  name       = var.name

  # Default version is always present
  default_version = {
    instance_template = local.instance_template
    name              = "default"
  }

  # optional versions
  versions     = var.additional_versions
  target_pools = var.target_pools
  named_ports  = var.named_ports

  # override if autoscaler_config is present
  target_size = var.autoscaler_config == null ? var.target_size : null

  # Autoscaling
  autoscaler_config = var.autoscaler_config

  # Health checks
  health_check_config = var.health_check_config
  # if no external health checks then use policy based on provided health checks
  auto_healing_policies = var.auto_healing_policies == null ? local.default_health_check_policy : var.auto_healing_policies

  # instance update policy
  update_policy = var.update_policy

  wait_for_instances = var.wait_for_instances
}




