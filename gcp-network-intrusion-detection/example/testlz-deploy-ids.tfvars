project = "pid-gcp-tlz-pavan-5231"
network = "projects/pid-gcp-tlz-pavan-5231/global/networks/test-default"
subnet  = "projects/pid-gcp-tlz-pavan-5231/regions/us-east4/subnetworks/gke-subnet"
region  = "us-east4"

# mirroring it's own network, not usually the case
mirroring_policies = {
  "gke1" = {
    project_id    = "pid-gcp-tlz-pavan-5231"
    vpc_name      = "test-default"
    subnets       = ["gke-subnet"] # should be in the same region as <region>
    instance_tags = []
    instances     = []
  }
}
# Source IP range of a traffic, either could be from multiple subnets within or from external IPs
traffic_source_ranges = ["0.0.0.0/0"]

gcs_bucket          = "sec-qa-ids-configurations"  # GCS bucket from Security LZ QA env
#gcs_bucket          = "tlz-dev-ids-configurations"
config_dir          = "testlz"
signature_file_name = "etpro.rules.tar.gz"

source_image_url = "pid-gcp-ssvc-os-images/gold-ids-ubuntu-1804-lts"  # family name

labels = {
  component = "suricate-ids"
  owner     = "test-lz-mvp"
}

autoscaler_config = {
  max_replicas                      = 3
  min_replicas                      = 1
  cooldown_period                   = 90 # to start suricate and update rules
  cpu_utilization_target            = 0.65
  load_balancing_utilization_target = null
  metric                            = null
}

# refer to modules/create-service-account
ids_service_account_email = "suricata-ids@pid-gcp-tlz-pavan-5231.iam.gserviceaccount.com"