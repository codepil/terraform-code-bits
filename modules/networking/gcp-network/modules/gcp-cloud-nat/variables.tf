variable "project_id" {
  description = "The GCP project ID in which to deploy the VPC and its subnets."
  type        = string
}

variable "network" {
  description = "Network that this cloud NAT should be setup within. Specify the full path/selflink"
  type        = string
}

variable "region" {
  description = "Region that this cloud NAT should be setup within.  This should align with the subnets to which this will provide NAT services."
  type        = string
}

variable "nat_name" {
  description = "Name to use for the Cloud Nat resource."
  type        = string
}
variable "router_name" {
  description = "Name to use for the auto-created cloud router resource."
  type        = string
  default     = ""
}

variable "number_nat_addresses" {
  description = "The number of external static IP addresses to configure for Cloud NAT.  If \"existing_nat_addresses\" is specified, this is ignored."
  type        = number
  default     = 1
}
variable "existing_nat_addresses" {
  description = "List of google_compute_address resource selflinks for the reserved IP addresses to use.  This overrides number_nat_addresses and no new IPs would be reserved."
  type        = list(string)
  default     = []
}
/*
variable "labels" {
  type        = map(string)
  description = "Map of key:value pairs to apply as labels to the bucket resource. These will be merged with project level labels, project level labels being overwritten if there are duplicate keys."
}
*/
