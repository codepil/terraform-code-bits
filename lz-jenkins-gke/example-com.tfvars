org_prefix                = "gcp"
automation_project_id     = "pid-gcp-lzds-res01"
master_service_account_id = "act-lz-automation-master"
groups_service_account_id = "act-lz-group-automation"
jenkins_ip_address_name   = "adr-gcp-inf-web-jenkins"
labels                    = { purpose = "lz-automation" }
gke_region                = "us-east4"
gke_node_zones            = ["us-east4-a", "us-east4-b", "us-east4-c"]
gke_machine_type          = "n1-standard-2"
gke_autoscaling_config = {
  min_node_count = 1
  max_node_count = 3
}
gke_enable_private_endpoint = false
iap_client_brand            = null
