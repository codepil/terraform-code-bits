/**
* # Google Kubernetes Engine (GKE)
*
* This building block is designed to create a GKE cluster deployment with private access, on its dedicated VPC network.
*
* Control plane access is controlled through Proxy VM instance is created with, Identity Aware Proxy tunnel,
* and firewall rule to allow SSH inbound.
*
*/

module "gke_vpc" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric/modules/net-vpc"
  project_id = var.project_id
  name       = var.gke_vpc_name
  subnets = [
    {
      ip_cidr_range = var.gke_ip_cidr
      name          = var.gke_subnet_name
      region        = var.gke_region
      secondary_ip_range = {
        pods     = var.gke_pod_cidr
        services = var.gke_service_cidr
      }
    }
  ]
}

module "gke_service_account" {
  source       = "github.com/terraform-google-modules/cloud-foundation-fabric/modules/iam-service-account"
  project_id   = var.project_id
  name         = var.gke_service_account_name
  generate_key = false
  iam_project_roles = {
    (var.project_id) = [
      "roles/logging.logWriter",
      "roles/monitoring.metricWriter",
    ]
  }
}

module "gke_sbx_cluster" {
  source                    = "github.com/terraform-google-modules/cloud-foundation-fabric/modules/gke-cluster"
  project_id                = var.project_id
  name                      = var.gke_cluster_name
  location                  = var.gke_region
  node_locations            = var.gke_node_zones
  network                   = module.gke_vpc.name
  subnetwork                = module.gke_vpc.subnets["${var.gke_region}/${var.gke_subnet_name}"].name
  secondary_range_pods      = "pods"
  secondary_range_services  = "services"
  default_max_pods_per_node = var.gke_pods_per_node
  master_authorized_ranges  = var.gke_master_authorized_ranges

  private_cluster_config = {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = var.gke_master_cidr
    master_global_access    = false
  }

  labels                = local.labels
  enable_shielded_nodes = true
  workload_identity     = true
}

module "gke_default_pool" {
  source                      = "github.com/terraform-google-modules/cloud-foundation-fabric/modules/gke-nodepool"
  project_id                  = var.project_id
  cluster_name                = module.gke_sbx_cluster.name
  location                    = var.gke_region
  name                        = "gke-sbx-default-pool"
  initial_node_count          = 1
  max_pods_per_node           = var.gke_pods_per_node
  autoscaling_config          = var.gke_autoscaling_config
  node_labels                 = local.labels
  node_service_account        = module.gke_service_account.email
  node_machine_type           = var.gke_machine_type
  node_service_account_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
}

module "proxyvm" {
  source = "../gcp-proxyvm"
  project_id         = var.project_id
  name               = var.vm_name
  region             = var.vm_region
  zones              = var.vm_zones
  tags               = var.tags
  network            = "projects/${var.project_id}/global/networks/${module.gke_vpc.name}"
  subnetwork         = "projects/${var.project_id}/regions/${var.gke_region}/subnetworks/${var.gke_subnet_name}"

  instance_type      = var.instance_type
  boot_disk_image    = var.boot_disk_image
  boot_disk_size     = var.boot_disk_size

  instance_count     = var.instance_count
  members            = var.members
}


