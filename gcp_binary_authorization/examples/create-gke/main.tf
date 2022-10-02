# This example for deploying in Binary Authorisation in multi project mode
# refer to https://cloud.google.com/binary-authorization/docs/multi-project-setup-cli for the details on the steps

# deployer project hosts GKE, Bin auth default policy and creating attestations in their CI/CD pipeline
data "google_project" "deployer" {
  project_id = "pid-gcp-tlz-pavan-5231"  # deployer project
}

locals {
  gke_location = "us-east4"
  gke_zones = ["us-east4-a"]
  gke_cluster_name = "testlz-gke-cluster"
}

# Create GKE cluster
# GKE cluster
resource "google_container_cluster" "primary" {
  project = data.google_project.deployer.name
  name     = local.gke_cluster_name
  location = local.gke_location
  node_locations = local.gke_zones

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  enable_binary_authorization = true

  network    = "test-default"
  subnetwork = "gke-subnet"
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  project = data.google_project.deployer.name
  name       = "${google_container_cluster.primary.name}-node-pool"
  location   = local.gke_location
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = data.google_project.deployer.name
    }

    # preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", local.gke_cluster_name]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
