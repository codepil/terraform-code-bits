locals {
  env        = "qa"
  project_id = "pid-gcp-tlz-pavan-5231"
}

module "vpc" {
  source = "../.."

  name                          = "private-network"
  project_id                    = local.project_id
  enable_private_access_routing = true
  environment                   = local.env
  create_nat                    = true

  subnet_regions = ["us-east4"]

}