deployer_project_id = "pid-gcp-tlz-pavan-5231"
images_exempted = ["gcr.io/pid-gcp-tlz-pavan-5231/whitelisted-app"]
cluster_admission_rules = [
  {
    cluster = "us-east4.testlz-gke-cluster"
    evaluation_mode = "ALWAYS_ALLOW"  # not recommended instead use break-glass feature of k8s
  }
]
default_evaluation_mode = "ALWAYS_DENY"
attestor_names = ["projects/pid-gcp-tlz-gke-att-77d1/attestors/testlz-demo-common-attestor"]