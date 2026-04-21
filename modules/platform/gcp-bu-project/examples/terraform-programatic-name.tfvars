# Fixed for this LZ and/or your organisations
billing_account       = "02B4Y9-XD0F20-D12FXB"
automation_project_id = "pid-gcp-exbu-ops"
unit_code             = "exbu"

# Specific settings for this project
parent_folder = "folders/1097115547496"
environment   = "dev"

# Specify project name
geo_location       = "us"
region             = "e"
business_region    = "na"
project_descriptor = "loadtest"
# No entropy on project name.
randomize_project_id = false
## Will result in project name of pid-gcp-exbu-loadtest

# Standard labels per your organisations labeling standards
additional_labels = {
  costcenter         = "12345"
  dataclassification = "dc1-p3"
  eol_date           = "perm"
  service_id         = "tbd"
}

# Optional IAM roles on this project
iam_role_members = {
  "roles/editor"              = ["group:myapp-dev@example.com", "group:myapp-support@example.com"]
  "roles/appengine.appViewer" = ["group:myapp-support@example.com"]
}
