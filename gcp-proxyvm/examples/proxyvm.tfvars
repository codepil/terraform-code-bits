project_id = "pid-gcp-tlz-pavan-5231"
region     = "us-east4"

########### Proxy Instance(s) ################

zones          = ["us-east4-b"]
name           = "proxyvm1"
instance_count = 1
network        = "projects/pid-gcp-tlz-pavan-5231/global/networks/test-default"
subnetwork     = "projects/pid-gcp-tlz-pavan-5231/regions/us-east4/subnetworks/gke-subnet"

boot_disk_size = "100"

############### IAP tunnel IAM member ###############
# The service account deploying this code is automatically added to the members list
# below is additional list of users who are provisioned with IAP tunnel
members = ["user:bijjalap@example.com", "serviceAccount:pid-gcp-tlz-pavan-5231@pid-gcp-tlz-lz-ops.iam.gserviceaccount.com"]

enable_scheduler_permissions = true