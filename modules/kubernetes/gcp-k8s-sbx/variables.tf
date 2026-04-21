variable "project_id" {
  type        = string
  description = "The ID of the Google Cloud project that will contain the GKE sandbox cluster"
}

variable "gke_vpc_name" {
  type        = string
  description = "Name of the VPC network to be created for hosting GKE cluster"
  default     = "gke-default-vpc"
}

variable "gke_subnet_name" {
  type        = string
  description = "Name of the sub network to be created"
  default     = "gke-default-subnet"
}

variable "gke_cluster_name" {
  type        = string
  description = "Name of the GKE cluster"
  default     = "gke-default-cluster"
}

variable "labels" {
  description = "Any additional labels that should be included in the LZ resources"
  type        = map(string)
  default     = {}
}

variable "gke_region" {
  type        = string
  description = "Default region for GKE cluster. This will be used in VPC subnet and GKE creation"
}

variable "gke_node_zones" {
  type        = list(string)
  description = "Zones in which GKE nodes will run"
}

variable "gke_master_authorized_ranges" {
  description = "IP address ranges that can access the Kubernetes cluster master through HTTPS."
  default     = {
    internal-vms = "10.0.0.0/8"
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
  description = "IP range for GKE pod IPs"
  default     = "172.16.0.0/20"
}

variable "gke_service_cidr" {
  description = "IP range for GKE service IPs"
  default     = "192.168.0.0/24"
}

variable "gke_machine_type" {
  description = "Machine type for default node pool"
  default     = "n1-standard-2"
}

variable "gke_pods_per_node" {
  description = "Max pods per node on default node pool"
  default     = 64
}

variable "gke_autoscaling_config" {
  description = "GKE autoscaling configuration."
  type = object({
    min_node_count = number
    max_node_count = number
  })
  default = {
    min_node_count = 1
    max_node_count = 3
  }
}

variable "gke_service_account_name" {
  type        = string
  description = "Name of the service account identity which to be created to manage GKE cluster"
  default     = "sa-gke-default"
}

variable "vm_name" {
  description = "Instances base name."
  type        = string
  default     = "proxyvm-default"
}

variable "vm_region" {
  description = "Compute region."
  type        = string
}

variable "vm_zones" {
  description = "Compute zone, instance will cycle through the list, defaults to the 'b' zone in the region."
  type        = list(string)
  default     = []
}

variable "members" {
  description = "List of users, groups, or service accounts that are allowed access to the proxy VM using the IAP tunnel. The GCP account deploying this code is automatically appended to this list.  Entries should have appropriate 'user:', 'group:', or 'serviceAccount:' prefixes."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Instance network tags."
  type        = list(string)
  default     = []
}

variable "instance_type" {
  description = "Instance type."
  type        = string
  default     = "f1-micro"
}

variable "boot_disk_image" {
  description = "Boot disk image.  May be specific image or image family"
  type        = string
  default     = "projects/debian-cloud/global/images/family/debian-10"
}

variable "boot_disk_size" {
  description = "Boot disk size in GB"
  type        = string
  default     = "20"
}

variable "instance_count" {
  description = "The number of proxy VMs to create."
  type        = number
  default     = 1
}


