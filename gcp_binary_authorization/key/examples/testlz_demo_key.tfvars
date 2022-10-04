key_project_id = "pid-gcp-tlz-gke-att-77d1"
key_ring_name = "attestor-key-ring"
location = "global"
attestor_key_name = "attesting-key-demo"
attestor_project_number = 109280866996 # for "pid-gcp-tlz-gke-att-77d1"
deployer_project_numbers = [541092539069, 336976643645] # for "pid-gcp-tlz-gke01-d0cc", pid-gcp-tlz-pavan-5231
# added Automation Service Account since I will be using project-infrastructure Jenkins pipeline to create attestor, and my user credentials to sign image digest from command line.
key_users = ["user:pavan.bijjala@example.com", "serviceAccount:pid-gcp-tlz-gke-att-77d1@pid-gcp-tlz-lz-ops.iam.gserviceaccount.com"]