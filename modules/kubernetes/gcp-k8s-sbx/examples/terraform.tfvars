project_id        = "your_project_id"
labels            = { purpose = "registry-scanner" }

########### GKE cluster ################

gke_region        = "us-east4"
gke_vpc_name      = "vpc-registry-scanner-gke"
gke_subnet_name   = "subnet-registry-scanner-01"

gke_cluster_name  = "gke-registry-scanner-01"
gke_node_zones    = ["us-east4-a", "us-east4-b", "us-east4-c"]
gke_machine_type  = "e2-standard-2"
gke_autoscaling_config = {
  min_node_count  = 1
  max_node_count  = 4
}
gke_service_account_name = "sa-gke-default"

########### Proxy Instance(s) ################
instance_count    = 1
vm_name           = "proxyvm-gke"
vm_region         = "us-east4"
vm_zones          = ["us-east4-a"]

boot_disk_image   = "projects/debian-cloud/global/images/debian-10-buster-v20201112"
boot_disk_size    = "100"

############### IAP tunnel accessors's member ###############
# The service account deploying this code is automatically added to the members list
members           = ["serviceAccount:your_project_id@pid-gcp-tlz-lz-ops.iam.gserviceaccount.com"]

