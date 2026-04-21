variable "org_prefix" {
  description = "Global prefix for resources to ensure uniqueness"
  default     = "gcp"
}

variable "automation_project_id" {
  description = "The ID of the Google Cloud project that will contain the Jenkins GKE cluster"
  type        = string
}

variable "master_service_account_id" {
  description = "The master LZ automation service account id, to be used by workload identity"
  type        = string
}

variable "groups_service_account_id" {
  description = "The G Suite Groups automation service account id, to be used by workload identity"
  type        = string
}

variable "jenkins_ip_address_name" {
  description = "Resource name for the Jenkins global static IP address"
  type        = string
}

variable "labels" {
  description = "Any additional labels that should be included in the LZ resources"
  type        = map(string)
  default     = {}
}

variable "gke_region" {
  description = "Default region for Jenkins GKE cluster. This will be used in VPC subnet and GKE creation"
}

variable "gke_node_zones" {
  description = "Zones in which Jenkins GKE nodes will run"
}

variable "gke_autoscaling_config" {
  description = "Jenkins GKE autoscaling configuration."
  type = object({
    min_node_count = number
    max_node_count = number
  })
  default = {
    min_node_count = 1
    max_node_count = 3
  }
}

variable "gke_master_cidr" {
  description = "IP range for GKE master nodes. This range must be non-overlapping with other subnet ranges in the VPC or peered VPCs."
  default     = "192.168.1.0/28"
}

variable "gke_ip_cidr" {
  description = "IP range for primary (non-aliased) GKE IPs"
  default     = "10.0.0.0/24"
}

variable "gke_pod_cidr" {
  description = "IP range for Jenkins GKE pod IPs"
  default     = "172.16.0.0/20"
}

variable "gke_service_cidr" {
  description = "IP range for Jenkins GKE service IPs"
  default     = "192.168.0.0/24"
}

variable "gke_machine_type" {
  description = "Machine type for default Jenkins node pool"
  default     = "n1-standard-2"
}

variable "gke_pods_per_node" {
  description = "Max pods per node on default Jenkins node pool"
  default     = 64
}

variable "gke_enable_private_endpoint" {
  description = "If true, create a private cluster with no client access to the public endpoint."
  default     = true
}

variable "gke_master_authorized_ranges" {
  description = "External Ip address ranges that can access the Kubernetes cluster master through HTTPS."
  default     = {}
}

variable "cloud_nat" {
  description = "Configure Cloud NAT for private GKE nodes to access external resources. Filter if not null, one of ['ERRORS_ONLY', 'TRANSLATIONS_ONLY', 'ALL']"
  type = object({
    enabled = bool
    filter  = string
  })
  default = {
    enabled = true
    filter  = null
  }
}

variable "master_workload_identity" {
  description = "The Kubernetes namespace and service account that will be bound to workload identity of the master Google Cloud TF service account"
  type = object({
    namespace = string
    name      = string
  })
  default = {
    namespace = "lz-automation"
    name      = "lz-automation-master-tf"
  }
}

variable "groups_workload_identity" {
  description = "The Kubernetes namespace and service account that will be bound to workload identity of the master Google Cloud TF service account"
  type = object({
    namespace = string
    name      = string
  })
  default = {
    namespace = "lz-automation"
    name      = "lz-automation-groups-tf"
  }
}

variable "create_kube_bindings" {
  description = "(POST-APPLY) If true, use active kube-context to provision cluster resources and workload identity binding."
  default     = false
}

variable "iap_client_brand" {
  description = "Google OAuth brand for IAP"
  type        = string
  default     = null
}

variable "iap_client_display_name" {
  description = "Display name for Jenkins IAP login page"
  default     = "Jenkins LZ Automation"
}
