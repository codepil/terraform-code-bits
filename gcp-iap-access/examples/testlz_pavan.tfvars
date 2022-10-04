project_id = "pid-gcp-tlz-pavan-5231"
network    = "projects/pid-gcp-tlz-pavan-5231/global/networks/test-default"

# either of target_service_accounts or target_tags is sufficient
target_service_accounts = ["suricata-ids@pid-gcp-tlz-pavan-5231.iam.gserviceaccount.com"]
target_tags = ["iap-proxyvm1"]

# list of VMs, with access members
vm_access = {
  "projects/pid-gcp-tlz-pavan-5231/zones/us-east4-b/instances/proxyvm1-1" = [
    "user:bijjalap@example.com"
  ]
}

# MIG entry. only 1 MIG entry supported currently
mig_access = {
  mig_name = "https://www.googleapis.com/compute/v1/projects/pid-gcp-tlz-pavan-5231/regions/us-east4/instanceGroupManagers/suricata-igm"
  members = [
    "user:bijjalap@example.com"
  ]
}

