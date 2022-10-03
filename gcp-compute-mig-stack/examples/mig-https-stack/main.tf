# Instance startup script
data "local_file" "python-https" {
  filename = "${path.module}/start_https_server.sh"
}
# create MIG stack i.e., Instance template, MIG and Load Balancer.
module "mig-https-stack" {
  source = "../.."

  project_id  = "<your_project_id>"
  region      = "us-east4"
  vpc_name    = "example-private-network"
  subnet_name = "us-east4-qa-tier2"

  #### create instance template, and it's service account #############
  instance_service_account_id = "sa-instance-1"
  instance_name               = "test-instance-template-1"
  zones                       = ["us-east4-a", "us-east4-b"]
  instance_tag                = "https-server"
  other_instance_tags         = ["ssh"]

  network_interfaces = [{
    network    = "projects/<your_project_id>/global/networks/example-private-network"
    subnetwork = "projects/<your_project_id>/regions/us-east4/subnetworks/us-east4-qa-tier2"
    nat        = false
    addresses  = null
    alias_ips  = null
  }]

  boot_disk = {
    image = "projects/debian-cloud/global/images/family/debian-10"
    type  = "pd-ssd"
    size  = 10
  }
  metadata = {
    startup-script = data.local_file.python-https.content
  }

  ########### create MIG  #################################################
  name     = "test-mig"
  location = "us-east4-a" # if regional then it should be "us-east4" and 'regional' set to true

  named_ports = {
    "https" = 443
  }

  # Auto scaling based on the CPU utilisation
  autoscaler_config = {
    max_replicas                      = 3
    min_replicas                      = 2
    cooldown_period                   = 30
    cpu_utilization_target            = 0.65
    load_balancing_utilization_target = null
    metric                            = null
  }

  health_check_config = {
    type    = "https"
    check   = { port = 443 }
    config  = {}
    logging = true
  }
  # no external health check policies, otherwise define auto_healing_policies here.

  update_policy = {
    type                 = "PROACTIVE"
    minimal_action       = "REPLACE"
    min_ready_sec        = 30
    max_surge_type       = "fixed"
    max_surge            = 1
    max_unavailable_type = null
    max_unavailable      = null
  }

  wait_for_instances = false

  ##### LB with MIG as default backend ######################
  lb_type                 = "EXTERNAL"
  lb_name_prefix          = "lb-test1"
  firewall_networks       = ["example-private-network"]
  include_default_backend = true
  ssl_certificates        = ["projects/<your_project_id>/global/sslCertificates/test-ssl-cert"]

}