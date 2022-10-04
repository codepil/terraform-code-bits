# Fixed for this LZ, and/or respective organisation
billing_account       = "01B4Y9-XD0F20-D12FXB"
automation_project_id = "pid-gcp-exbu-ops"
unit_code             = "exbu"

# Specific settings for this project
parent_folder = "folders/1097111255496"
environment   = "dev"

# Specify project name
project_name = "pid-gcp-exbu-res01"
# Add entropy to project name, so will be named pid-gcp-exbu-res01-####
randomize_project_id = true

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
