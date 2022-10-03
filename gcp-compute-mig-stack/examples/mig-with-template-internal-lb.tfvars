project_id  = "pid-gcp-tlz-gke01-d0cc"
region      = "us-east1"
vpc_name    = "image-vpc"
subnet_name = "subnet-for-packer-vms"

######## Instance template, and it's service account #############
instance_service_account_id = "syslog-collector-instance-sa"
instance_name               = "syslog-collector-instance-template"
zones                       = ["us-east1-c", "us-east1-b"]
instance_tag                = "syslog-collector"
other_instance_tags         = ["ssh"]
instance_type               = "e2-medium"
startup_script_path         = "examples/example_syslog_collector.sh"

network_interfaces = [{
  network    = "projects/pid-gcp-tlz-gke01-d0cc/global/networks/image-vpc"
  subnetwork = "projects/pid-gcp-tlz-gke01-d0cc/regions/us-east1/subnetworks/subnet-for-packer-vms"
  nat        = false
  addresses  = null
  alias_ips  = null
}]

# gcloud compute images list --uri --standard-images
# Disk size should be greater than base image size ( > 20GB )
# to use RHEL 7 base image, use "projects/rhel-cloud/global/images/rhel-7-v20210721"
# Using RHEL8 LZ gold image
boot_disk = {
  image = "projects/pid-gcp-tlz-gke01-d0cc/global/images/rhel-8-v2021072216-golden"
  type  = "pd-ssd"
  size  = 30
}

########### MIG  section #################################################
name     = "syslog-collector-mig"
location = "us-east1-c"
# syslog forwarder can use either TCP or UDP protocols, hence create LB for both
named_ports = {
  "tcp" = 514
  "udp" = 514
}

# Auto scaling based on the CPU utilisation
autoscaler_config = {
  max_replicas                      = 3
  min_replicas                      = 1
  cooldown_period                   = 30
  cpu_utilization_target            = 0.65
  load_balancing_utilization_target = null
  metric                            = null
}

# Consumed by MIG autoscaling health checks
health_check_config = {
  type    = "tcp"
  check   = { port = 514 }
  config  = {}
  logging = true
}
# No external health check policies to be defined

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

######## ILB with MIG created above as a default backend ######################
# syslog forwarding client is expected to have a network tag mentioned below, and use IP addresses of one of the ILB created here.
lb_type         = "INTERNAL"
lb_name_prefix  = "syslog-collector-ilb"
ilb_source_tags = ["syslog-forwarder"]