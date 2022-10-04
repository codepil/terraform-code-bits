# Global automation project used to store Terraform state and SA keys
# (there is rarely a need to change this)
global_automation_project_id = "pid-gcp-lzds-res01"

# Name of this Landing Zone's operating business unit
unit_name = "Test LZ"

# Short code for this Landing Zone's operating business unit
unit_code = "tlz"

# Billing account used for projects created in this Landing Zone
billing_account_id = "01EC5A-7Y1F56-1F746Z"

# Parent Folder Node ID
root_node = "folders/256190011348"

unit_iam_members = {
  "roles/viewer" = [
    "user:bijjalap@example.com",
    "user:vijay.patil1@example.com",
  ]
  "roles/browser" = [
    "user:bijjalap@example.com",
    "user:vijay.patil1@example.com",
  ]
  "roles/iam.securityReviewer" = [
    "user:bijjalap@example.com",
    "user:vijay.patil1@example.com",
  ]
}

environments_iam_members = {
  ops = {
    "roles/serviceusage.serviceUsageAdmin" = ["user:bijjalap@example.com"]
  }
  devqa  = {}
  cde    = {}
  noncde = {}
}

