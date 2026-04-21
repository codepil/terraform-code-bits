project_id  = "pid-gcp-tlz-gke01-d0cc"
region      = "us-east4"
vpc_name    = "vpc-gcp-tlz-gke-sbx-devqa"
subnet_name = "gke-sbx-01"

#### create instance template, and it's service account #############
instance_service_account_id = "sa-instance-1"
instance_name               = "test-instance-template-1"
zones                       = ["us-east4-a", "us-east4-b"]
instance_tag                = "https-server"
other_instance_tags         = ["ssh"]

network_interfaces = [{
  network    = "projects/pid-gcp-tlz-gke01-d0cc/global/networks/vpc-gcp-tlz-gke-sbx-devqa"
  subnetwork = "projects/pid-gcp-tlz-gke01-d0cc/regions/us-east4/subnetworks/gke-sbx-01"
  nat        = false
  addresses  = null
  alias_ips  = null
}]
# using default boot disk, btw
boot_disk = {
  image = "projects/debian-cloud/global/images/family/debian-10"
  type  = "pd-ssd"
  size  = 10
}

########### create MIG  #################################################
name     = "test-mig"
location = "us-east4-a" # if regional then it should be "us-east4" and 'regional' set to true

##### optional values #####
# additional deployments, like
additional_versions = {
  canary = {
    instance_template = "projects/pid-gcp-tlz-gke01-d0cc/global/instanceTemplates/existing-canary-instance-template"
    target_type       = "fixed"
    target_size       = 1
  }
}

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
firewall_networks       = ["vpc-gcp-tlz-gke-sbx-devqa"]
include_default_backend = true
ssl_certificates        = ["projects/pid-gcp-tlz-gke01-d0cc/global/sslCertificates/test-ssl-cert"]