variable "region_cidrs" {
  description = "Map of regional CIDRs in which to create subnets. Should map 1:1 with regions variable.  ie: {us-east1=\"100.112.0.0/17\",us-central1=\"100.112.128.0/17\"}"
  type        = map(string)
}

variable "environment" {
  description = "Lifecycle of the subnets being generated. Whatever is passed will be injected in to the subnet name as it's lifecycle"
  type        = string
}

variable "subnet_attributes" {
  description = "Map of additional attributes to merge into all subnets"
  type        = map(string)
  default = {
    subnet_flow_logs          = "true"
    subnet_flow_logs_sampling = 0.5
    subnet_flow_logs_interval = "INTERVAL_5_MIN"
  }
}

variable "subnet_offsets" {
  description = "Map of subnet offsets and masks to be used against region_cidrs to calculate regional subnet CIDRS. If not provided, a default mapping based on best practices will be used instead.  Should be a map of subnet name suffixes pointing to map of strings containing 'offset' and 'mask' keys."
  type        = map(map(string))
  default     = {}
}

variable "subnet_map_fields" {
  description = "Map of keys used in each subnet map.  Only needs changing if you need to change the key names in the output."
  type        = map(string)
  default = {
    cidr_key   = "subnet_ip"     # ip_cidr_range
    name_key   = "subnet_name"   # name
    region_key = "subnet_region" # region
  }
}

variable "region_secondary_cidrs" {
  description = "Map of regional CIDRs in which to create the secondary ranges.  Map keys should be same or subset of the subnet_regions."
  type        = map(string)
  default     = {}
}

variable "secondary_offsets" {
  description = "Map of secondary range offsets and masks to be used in conjunction with region_secondary_cidrs to calculate regional subnet secondary range CIDRS and secondary names.  If not provided, a default mapping based on best practices will be used instead.   Should be a map of subnet name suffixes pointing to map of secondary range name suffices, pointing to map of strings containing 'offset' and 'mask' keys"
  type        = map(map(map(string)))
  default     = {}
}

variable "secondary_map_fields" {
  description = "Map of keys used in each secondary range map.  Only needs changing if you need to change the key names in the output."
  type        = map(string)
  default = {
    name_key = "range_name"
    cidr_key = "ip_cidr_range"
  }
}
