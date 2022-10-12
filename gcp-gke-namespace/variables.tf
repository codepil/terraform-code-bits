variable "project_id" {
  description = "Project where cluster got deployed and namespace to be created"
  type        = string
}

variable "cluster" {
  description = "Cluster where namespace to be created"
  type        = string
}

variable "location" {
  description = "cluster location - could be either zone/region name"
  type        = string
}

variable "nsname" {
  description = "namespace name"
  type        = map(map(map((string))))
  default     = {}
}
