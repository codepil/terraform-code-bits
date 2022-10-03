project_id          = "pid-gcp-tlz-gke01-d0cc"
region              = "us-east1"
vpc_name            = "image-vpc"
subnet_name         = "subnet-for-packer-vms"
collectors_per_zone = 1
# number of zones
zones                  = ["us-east1-c"]
other_vm_instance_tags = ["ssh"]
# size of collector, as per
collector_instance_type = "e2-standard-2"
boot_disk = {
  image = "projects/pid-gcp-tlz-gke01-d0cc/global/images/windows-2019-v2021060910-golden"
  type  = "pd-ssd"
  size  = 50
}
collector_name_prefix = "logicmonitor-collector"
collector_login_users = ["user:pavan.bijjala@test.com"]

labels = {
  costcenter         = "12345"
  dataclassification = "dc3"
  eol_date           = "temp"
  lifecycle          = "dev"
  service_id         = "tbd"
}

