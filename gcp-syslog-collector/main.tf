/*
* # gcp-syslog-collector
*
* This module creates an syslog collector infrastructure to receive syslog messages from source systems/forwarders.
* Syslog forwarder can configure either through TCP or UDP protocol, on port 514 with IP address from either (TCP/UDP) of Load Balancers created by this module.
*
* Below infrastructure is created by the module,
* * Managed Instance Group (MIG) stack for syslog-collector
* * Internal Load Balancer group for TCP & UDP on port 514, with necessary health checks
*
* ## Pre-requisites
* * Project should have enabled Compute Engine API (compute.googleapis.com).
*
*/

# Instance startup script
data "local_file" "startup" {
  filename = "${path.module}/configure_syslog_collector.sh"
}

# create MIG stack i.e., Instance template, MIG and Load Balancer.
module "mig-syslog-collector" {
  source = "../gcp-compute-mig-stack"

  project_id  = var.project_id
  region      = var.region
  vpc_name    = var.vpc_name
  subnet_name = var.subnet_name

  #### create instance template, and it's service account #############
  instance_service_account_id = "${var.name}-instance-sa"
  instance_name               = "${var.name}-instance-template"
  regional                    = var.regional
  zones                       = var.zones
  instance_type               = var.instance_type
  instance_tag                = var.name
  other_instance_tags         = var.other_instance_tags

  network_interfaces = [{
    network    = "projects/${var.project_id}/global/networks/${var.vpc_name}"
    subnetwork = "projects/${var.project_id}/regions/${var.region}/subnetworks/${var.subnet_name}"
    nat        = false
    addresses  = null
    alias_ips  = null
  }]

  boot_disk = var.boot_disk
  metadata = {
    startup-script = data.local_file.startup.content
  }

  ########### create MIG  #################################################
  name     = "${var.name}-mig"
  location = var.zones[0]
  # syslog forwarding client can use either TCP or UDP protocols, hence create LB for both
  named_ports = {
    "tcp" = 514
    "udp" = 514
  }

  # Auto scaling based on the CPU utilisation
  autoscaler_config = var.autoscaler_config
  health_check_config = {
    type    = "tcp"
    check   = { port = 514 }
    config  = {}
    logging = true
  }

  update_policy = {
    type                 = "PROACTIVE"
    minimal_action       = "REPLACE"
    min_ready_sec        = 30
    max_surge_type       = "fixed"
    max_surge            = 1
    max_unavailable_type = null
    max_unavailable      = null
  }

  lb_type         = "INTERNAL"
  lb_name_prefix  = "${var.name}-ilb"
  ilb_source_tags = var.lb_source_tags
}