deployer_project_id = "pid-gcp-tlz-gke01-d0cc"
images_exempted = ["gcr.io/pid-gcp-tlz-gke01-d0cc/test-repo/good-dockerfile-image"]
cluster_admission_rules = [
  {
    cluster = "us-east4.test-cluster"
    evaluation_mode = "REQUIRE_ATTESTATION"
  }
]
default_evaluation_mode = "ALWAYS_DENY"
attestor_names = ["projects/pid-gcp-tlz-gke-att-77d1/attestors/testlz-demo-common-attestor"]