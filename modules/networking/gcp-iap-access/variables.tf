variable "project_id" {
  description = "(Required) The project ID in which the IAP should be enabled"
  type        = string
}

//variable "members" {
//  description = "(Optional) List of users, groups, or service accounts that are allowed access the IAP tunnel. The GCP account deploying this code is automatically appended to this list.  Entries should have appropriate 'user:', 'group:', or 'serviceAccount:' prefixes."
//  type        = list(string)
//  default     = []
//}

variable "network" {
  description = "(Required) Self link to the network in which FW rules are defined to allow IAP traffic"
  type        = string
}

variable "base_priority" {
  description = "(Optional) Sets the base priority floor value for the created firewall rules."
  type        = number
  default     = 1000
}

variable "mig_access" {
  description = "(Optional) Access object to create access list for Managed Instance Group. Example of mig_name being 'https://www.googleapis.com/compute/v1/projects/pid-gcp-tlz-pavan-5231/regions/us-east4/instanceGroupManagers/suricata-igm'"
  type = object({
    mig_name = string
    members  = list(string)
  })
  default = null
}

variable "vm_access" {
  description = "(Optional) Access object to create access list for list of VM instances, in key value pair format. Example instance being 'projects/pid-gcp-tlz-pavan-5231/zones/us-east4-c/instances/suricata-igm-7558'"
  type        = map(list(string))
  default     = null
}

variable "target_tags" {
  description = "(Optional) List of Tags used in VM instances. If neither targetServiceAccounts nor targetTags are specified, the firewall rule applies to all instances on the specified network"
  type        = list(string)
  default     = null
}

variable "target_service_accounts" {
  description = "(Optional) List of SA used in creating VM instances. If neither targetServiceAccounts nor targetTags are specified, the firewall rule applies to all instances on the specified network"
  type        = list(string)
  default     = null
}
