/*
* # gcp-logicmonitor-collector
*
* This module creates an Logic monitor collector infrastructure given a GCP Project/VPC network.
*
* Below infrastructure is created by the module,
* * Un Managed Instance Group & VM instance based on image_url and instance_type
* * Firewall rule for UDP ports used by collector ("162" #snmap traps, "2055" #netflow, "6343" #sflow)
* * IAP tunnel firewall for Windows RDP port 3389, and SSH 22
* * IAM binding for given user to use IAP
*
* Use https://cloud.google.com/iap/docs/using-tcp-forwarding#gcloud_3 to connect to VM.
*
* ## Limitations
* * Given that validity of LM collector binary is only 2 hrs & no silent installation option for Windows image,
* installing Collector on GCP infra is going to be a manual task.
* * Linux collector image would be possible to silent-install but this type of collector wouldn't help to collect metrics from Windows instance
*
* Given above limitations, metadata handling and startup_scripts in template folder in this module is commented out, and users are suggested to use IAP and steps in https://cloud.google.com/iap/docs/using-tcp-forwarding#gcloud_3 to connect to VM, to install. Collector binary is downloadable from https://heartland.logicmonitor.com/santaba/uiv3/setting/index.jsp(at settings, at collector, Add, select type ..etc) using Test SSO.
*
* Also Managed Instance Group (MIG) is not supported for the same reasons.
*
* ## Pre-requisites
* * Project should have enabled Compute Engine API (compute.googleapis.com).
* * Recommended to use Test's golden images for image_url, if so then Cloud service account (i.e., <prj_id>@cloudservices.gserviceaccount.com) is to be added to Test golden images project for accessing Test Golden images.
* ## Reference
* * https://www.logicmonitor.com/support/rest-api-developers-guide/v1/collectors/downloading-a-collector-installer#Installation
* * to-do manually https://heartland.logicmonitor.com/santaba/uiv3/setting/index.jsp
*/


module "lm_instance_service_account" {
  source       = "git::https://github.com/codepil/terraform-code-bits/gcp-service-account?ref=v1.0.1"
  project_id   = var.project_id
  name         = "lm-collector-instance-sa"
  display_name = "Terraform-managed-logic-monitor-collector-instance-sa"
  project_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
  ]
}

module "lm_collector_vms" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric.git//modules/compute-vm"
  project_id = var.project_id
  name       = var.collector_name_prefix
  region     = var.region
  zones      = local.instance_zone_list
  network_interfaces = [{
    network    = local.vpc_network
    subnetwork = local.subnetwork
    nat        = false
    addresses  = null
    alias_ips  = null
  }]
  boot_disk       = var.boot_disk
  instance_type   = var.collector_instance_type
  instance_count  = local.instance_count
  service_account = module.lm_instance_service_account.email
  tags            = distinct(concat(var.other_vm_instance_tags, local.lm_collector_network_tags))

  //Note: silent install is not supported, commenting related code
  //metadata        = local.metadata

  # Unmanaged Instance group is needed when operating in instance mode
  group  = { named_ports = {} }
  labels = var.labels
}

# Create firewall rule to ingress from any internal VM instance on given subnet
# based on https://www.logicmonitor.com/support/collectors/collector-overview/about-the-logicmonitor-collector
resource "google_compute_firewall" "lm_fw" {
  name        = "lm-collector-ingress"
  project     = var.project_id
  network     = var.vpc_name
  description = "Allow traffic to LogicMonitor collector servers, created by Terraform"
  target_tags = local.lm_collector_network_tags
  allow {
    protocol = "udp"
    ports    = local.lm_collector_udp_ports
  }
  source_ranges = concat(var.additional_source_network_ip_ranges, [data.google_compute_subnetwork.lm-subnetwork.ip_cidr_range])
}


