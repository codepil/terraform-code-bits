locals {
  static_labels = {
    lifecycle          = "operations"
    dataclassification = "dc3-p3"
  }
  labels = merge(var.labels, local.static_labels)
}

################################################################################
#  VPC Networking                                                              #
################################################################################
module "lz_automation_vpc" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric/modules/net-vpc"
  project_id = var.automation_project_id
  name       = "lz-automation"
  subnets = [
    {
      ip_cidr_range = var.gke_ip_cidr
      name          = "jenkins-gke"
      region        = var.gke_region
      secondary_ip_range = {
        pods     = var.gke_pod_cidr
        services = var.gke_service_cidr
      }
    }
  ]
}

module "gke_node_nat" {
  count          = var.cloud_nat.enabled ? 1 : 0
  source         = "github.com/terraform-google-modules/cloud-foundation-fabric/modules/net-cloudnat"
  project_id     = var.automation_project_id
  region         = var.gke_region
  name           = "gke-jenkins-nat"
  router_network = module.lz_automation_vpc.name
  logging_filter = var.cloud_nat.filter
}

resource "google_compute_global_address" "jenkins_elb" {
  project     = var.automation_project_id
  name        = var.jenkins_ip_address_name
  description = "LZ Jenkins HTTPS LB"
}

################################################################################
#  Project IAM                                                                 #
################################################################################

# Service account used by GKE nodes
module "lz_gke_service_account" {
  source        = "github.com/terraform-google-modules/cloud-foundation-fabric/modules/iam-service-accounts"
  project_id    = var.automation_project_id
  names         = ["gke-jenkins-default"]
  generate_keys = false
  iam_project_roles = {
    (var.automation_project_id) = [
      "roles/logging.logWriter",
      "roles/monitoring.metricWriter",
    ]
  }
}

################################################################################
#   GKE Cluster                                                                #
################################################################################

module "jenkins_gke" {
  source                    = "github.com/terraform-google-modules/cloud-foundation-fabric/modules/gke-cluster"
  project_id                = var.automation_project_id
  name                      = "lz-automation-tools"
  location                  = var.gke_region
  node_locations            = var.gke_node_zones
  network                   = module.lz_automation_vpc.name
  subnetwork                = module.lz_automation_vpc.subnets["${var.gke_region}/jenkins-gke"].name
  secondary_range_pods      = "pods"
  secondary_range_services  = "services"
  default_max_pods_per_node = var.gke_pods_per_node
  master_authorized_ranges  = var.gke_master_authorized_ranges
  private_cluster_config = {
    enable_private_nodes    = true
    enable_private_endpoint = var.gke_enable_private_endpoint
    master_ipv4_cidr_block  = var.gke_master_cidr
  }
  labels                = local.labels
  enable_shielded_nodes = true
  workload_identity     = true
}

module "jenkins_default_pool" {
  source                      = "github.com/terraform-google-modules/cloud-foundation-fabric/modules/gke-nodepool"
  project_id                  = var.automation_project_id
  cluster_name                = module.jenkins_gke.name
  location                    = var.gke_region
  name                        = "jenkins-default-pool"
  initial_node_count          = 1
  max_pods_per_node           = var.gke_pods_per_node
  autoscaling_config          = var.gke_autoscaling_config
  node_config_labels          = local.labels
  node_config_service_account = module.lz_gke_service_account.email
  node_config_machine_type    = var.gke_machine_type
  node_config_oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
}

################################################################################
#   Kubernetes-internal resources                                              #
################################################################################

provider "kubernetes" {
  # load_config_file = "false"
}

data "google_service_account" "lz_automation_master" {
  project    = var.automation_project_id
  account_id = var.master_service_account_id
}

data "google_service_account" "lz_groups" {
  project    = var.automation_project_id
  account_id = var.groups_service_account_id
}

resource "kubernetes_namespace" "jenkins" {
  count = var.create_kube_bindings ? 1 : 0
  metadata {
    name = "jenkins"
  }
}

resource "kubernetes_namespace" "lz_master_ns" {
  count = var.create_kube_bindings ? 1 : 0
  metadata {
    name = var.master_workload_identity.namespace
  }
}

resource "kubernetes_service_account" "lz_master_sa" {
  count = var.create_kube_bindings ? 1 : 0
  metadata {
    namespace = kubernetes_namespace.lz_master_ns.0.metadata.0.name
    name      = var.master_workload_identity.name
    annotations = {
      "iam.gke.io/gcp-service-account" : data.google_service_account.lz_automation_master.email
    }
    labels = local.labels
  }
  automount_service_account_token = true
}

# Master LZ automation workload identity
resource "google_service_account_iam_member" "lz_master_wi" {
  count              = var.create_kube_bindings ? 1 : 0
  service_account_id = "projects/${var.automation_project_id}/serviceAccounts/${data.google_service_account.lz_automation_master.email}"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.automation_project_id}.svc.id.goog[${var.master_workload_identity.namespace}/${var.master_workload_identity.name}]"
}

resource "kubernetes_cluster_role_binding" "lz_master_rbac" {
  count = var.create_kube_bindings ? 1 : 0
  metadata {
    name = "lz-automation-master"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    namespace = "lz-automation"
    name      = "lz-automation-master-tf"
  }
}

# G Suite group automation workload identity
resource "kubernetes_service_account" "lz_groups_sa" {
  count = var.create_kube_bindings ? 1 : 0
  metadata {
    namespace = kubernetes_namespace.lz_master_ns.0.metadata.0.name
    name      = var.groups_workload_identity.name
    annotations = {
      "iam.gke.io/gcp-service-account" : data.google_service_account.lz_groups.email
    }
    labels = local.labels
  }
  automount_service_account_token = true
}

resource "google_service_account_iam_member" "lz_groups_wi" {
  count              = var.create_kube_bindings ? 1 : 0
  service_account_id = "projects/${var.automation_project_id}/serviceAccounts/${data.google_service_account.lz_groups.email}"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.automation_project_id}.svc.id.goog[${var.groups_workload_identity.namespace}/${var.groups_workload_identity.name}]"
}

################################################################################
#   IAP and Ingress                                                            #
################################################################################

resource "google_iap_client" "jenkins_client" {
  count        = var.iap_client_brand == null ? 0 : 1
  display_name = var.iap_client_display_name
  brand        = var.iap_client_brand
}

resource "kubernetes_secret" "jenkins_iap_client" {
  count = var.iap_client_brand != null && var.create_kube_bindings ? 1 : 0
  metadata {
    namespace = kubernetes_namespace.jenkins.0.metadata.0.name
    name      = "jenkins-iap-client"
  }

  data = {
    client_id     = google_iap_client.jenkins_client.0.client_id
    client_secret = google_iap_client.jenkins_client.0.secret
  }
}

resource "google_iap_web_iam_member" "member" {
  project = var.automation_project_id
  role    = "roles/iap.httpsResourceAccessor"
  member  = "domain:example.com"
}
