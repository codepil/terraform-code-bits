project_id          = "pid-gcp-tlz-gke01-d0cc"
region              = "us-east1"
vpc_name            = "image-vpc"
subnet_name         = "subnet-for-packer-vms"
zones               = ["us-east1-c", "us-east1-b"]
other_instance_tags = ["ssh"]
instance_type       = "e2-medium"

# gcloud compute images list --uri --standard-images
# Disk size should be greater than base image size ( > 20GB )
# to use RHEL 7 base image, use "projects/rhel-cloud/global/images/rhel-7-v20210721"
# Using RHEL8 LZ gold image
boot_disk = {
  image = "projects/pid-gcp-tlz-gke01-d0cc/global/images/rhel-8-v2021072216-golden"
  type  = "pd-ssd"
  size  = 30
}
name = "syslog-collector"

######## ILB with MIG created above ######################
# syslog forwarding client is expected to have a network tag mentioned below.
lb_source_tags = ["syslog-forwarder"]