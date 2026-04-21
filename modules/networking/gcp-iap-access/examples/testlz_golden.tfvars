project_id = "pid-gcp-tlz-golden-6d78"
network    = "projects/pid-gcp-tlz-golden-6d78/global/networks/image-vpc"

# either of target_service_accounts or target_tags is sufficient
target_service_accounts = ["suricata-ids@pid-gcp-tlz-golden-6d78.iam.gserviceaccount.com"]

# MIG entry. only 1 MIG entry supported currently
mig_access = {
  mig_name = "https://www.googleapis.com/compute/v1/projects/pid-gcp-tlz-golden-6d78/regions/us-east1/instanceGroupManagers/suricata-igm"
  members = [
    "user:bijjalap@example.com"
  ]
}

