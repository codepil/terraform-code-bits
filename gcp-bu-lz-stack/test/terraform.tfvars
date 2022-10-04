
root_node               = "folders/2701112037167"
unit_name               = "BU 2"
organization_id         = "155946218325"
automation_project_name = "prj-gcp-jtq-res02"
automation_project_id   = "pid-gcp-jtq-res02"
billing_account_id      = "10XC5A-76YF56-8FZ463"

unit_iam_members = { "roles/owner" = ["user:bijjalap@example.com"] }
# bu_policy_boolean = {
#   "constraints/compute.disableSerialPortAccess"                        = true
#   "constraints/compute.constraints/compute.skipDefaultNetworkCreation" = true
# }
# bu_policy_list = {
#   "constraints/compute.storageResourceUseRestrictions" = {
#     inherit_from_parent = null
#     suggested_value     = null
#     status              = true
#     values              = ["under:folders/170112057167"]
#   }
#   "constraints/iam.allowedPolicyMemberDomains" = {
#     inherit_from_parent = null
#     suggested_value     = null
#     status              = true
#     values              = ["1234", "5678"]
#   }
# }

environments = {
  "dev"      = "Development"
  "qa"       = "My QA"
  "prod-cde" = "Production CDE"
}
environments_iam_members = {
  "dev" = {
    "roles/editor" = ["user:bijjalap@example.com"]
    "roles/owner"  = ["user:bijjalap@example.com"]
  }
  "qa" = {
    "roles/viewer" = ["user:bijjalap@example.com"]
  }
}
#environments_policy_boolean = {
#  dev = {
#    "constraints/compute.disableSerialPortAccess"                        = true
#    "constraints/compute.constraints/compute.skipDefaultNetworkCreation" = true
#  }
#  qa = {
#    "constraints/sql.restrictPublicIp" = true
#  }
#}
#environments_policy_list = {
#  dev = {
#    "constraints/compute.storageResourceUseRestrictions" = {
#      inherit_from_parent = null
#      suggested_value     = null
#      status              = true
#      values              = ["under:folders/170112057167"]
#    }
#    "constraints/iam.allowedPolicyMemberDomains" = {
#      inherit_from_parent = null
#      suggested_value     = null
#      status              = true
#      values              = ["1234", "5678"]
#    }
#  }
#}

#bucket_prefix        = "bkt-gcp-mybu-tf01"
service_account_keys = true

labels = {
  costcenter         = "12345"
  dataclassification = "dc1-p3"
  eol_date           = "perm"
  lifecycle          = "non-production"
  service_id         = "tbd"
}

##########changes made###########
unit_name    = "Example BU 3"
prefix       =  gcp
short_name   =  exbu3

