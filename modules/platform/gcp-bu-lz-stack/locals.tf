/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  static_labels = {
    unit_code             = var.unit_code
    automation_project_id = var.global_automation_project_id
    businessregion        = var.business_region
    country               = var.country_code
    tier                  = "gcp-project"
  }

  labels = merge(var.labels, local.static_labels)

  ops_folder_id = google_folder.environment["ops"].id

  environments = {
    devqa  = "${upper(var.unit_code)} Dev-QA",
    noncde = "${upper(var.unit_code)} Non-CDE",
    cde    = "${upper(var.unit_code)} CDE",
    ops    = "${upper(var.unit_code)} Operations"
  }

  environments_noops = {
    for key, value in local.environments : key => value if key != "ops"
  }

  environments_chs = merge(
    { shared = "${var.unit_name} Shared" },
    { for key, value in local.environments : key => value if key != "ops" }
  )

  # Default project names/IDs for each environment
  automation_project_name = "pid-go${var.country_code}g${var.business_region}p-${var.unit_code}-lz-ops"
  shared_vpc_hosts = {
    devqa  = "pid-go${var.country_code}g${var.business_region}d-${var.unit_code}-svpc-devqa"
    noncde = "pid-go${var.country_code}g${var.business_region}g-${var.unit_code}-svpc-noncde"
    cde    = "pid-go${var.country_code}g${var.business_region}p-${var.unit_code}-svpc-cde"
    shared = "pid-go${var.country_code}g${var.business_region}p-${var.unit_code}-svpc-shared"
  }

  conhub_spokes = {
    devqa  = "pid-go${var.country_code}g${var.business_region}d-${var.unit_code}-chs-devqa"
    noncde = "pid-go${var.country_code}g${var.business_region}g-${var.unit_code}-chs-noncde"
    cde    = "pid-go${var.country_code}g${var.business_region}p-${var.unit_code}-chs-cde"
    shared = "pid-go${var.country_code}g${var.business_region}p-${var.unit_code}-chs-shared"
  }

  ##############################################################################
  # Unit's root LZ folder IAM bindings (authoritative).
  # Currently only sourced from var.unit_iam_members
  ##############################################################################

  default_group_root_folder_owner   = "group:gcp-f-${var.unit_code}-lz-owners@${var.domain}"
  default_group_root_folder_sec_eng = "group:gcp-f-${var.unit_code}-cde-security-engineering@${var.domain}"

  x_default_root_folder_roles = {
    "roles/appengine.appViewer" = [
      local.default_group_root_folder_sec_eng,
    ],
    "roles/browser" = [
      local.default_group_root_folder_owner,
      local.default_group_root_folder_sec_eng,
    ],
    "roles/cloudasset.viewer" = [
      local.default_group_root_folder_sec_eng,
    ],
    "roles/cloudtrace.user" = [
      local.default_group_root_folder_sec_eng,
    ],
    "roles/compute.viewer" = [
      local.default_group_root_folder_sec_eng,
    ],
    "roles/errorreporting.viewer" = [
      local.default_group_root_folder_sec_eng,
    ],
    "roles/resourcemanager.projectIamAdmin" = [
      local.default_group_root_folder_owner,
    ],
    "roles/iam.securityReviewer" = [
      local.default_group_root_folder_sec_eng,
      local.default_group_root_folder_owner,
    ],
    "roles/iam.serviceAccountUser" = [
      local.default_group_root_folder_sec_eng,
    ],
  }

  x_all_unit_folder_roles = distinct(concat(
    keys(var.unit_iam_members),
    keys(local.x_default_root_folder_roles)
  ))

  all_unit_folder_iam_bindings = {
    for role in local.x_all_unit_folder_roles : role => distinct(concat(
      lookup(var.unit_iam_members, role, []),
      lookup(local.x_default_root_folder_roles, role, [])
    ))
  }

  ##############################################################################
  # IAM members for this LZ's local automation project (non-authoritative)
  ##############################################################################
  environment_automation_iam_members = {
    for pair in setproduct(keys(local.environments_noops), toset([
      # Create dedicated Terraform service accounts for new LZ projects and configuring workload identity
      "roles/iam.serviceAccountAdmin",
      # Create and grant access to dedicated TF state buckets for new LZ projects
      "roles/storage.admin",
      # When enabling an API on a project in this BU, it will need to be enabled on the automation project as well
      "roles/serviceusage.serviceUsageAdmin",
      # Required for Terraform resource validations while creating BU project
      "roles/viewer"
    ])) :
    "${pair.0}-${pair.1}" => { member = "serviceAccount:${google_service_account.environment[pair.0].email}", role = pair.1 }
  }

  ##############################################################################
  # IAM members for each of the LZ's SVPC host projects (non-authoritative)
  ##############################################################################
  environment_svpc_iam_members = {
    for pair in setproduct(keys(local.shared_vpc_hosts), toset([
      # Create dedicated Terraform service accounts for new LZ projects and configuring workload identity
      "roles/editor",
      # Create and manage Cloud KMS keyrings and keys
      "roles/cloudkms.admin",
      # Create and grant access to dedicated TF state buckets for new LZ projects
      "roles/resourcemanager.projectIamAdmin",
      # Manage network configurations, including peering and private access service networking
      "roles/compute.networkAdmin",
    ])) :
    "${pair.0}-${pair.1}" => {
      environment = pair.0
      member      = module.env_svpc_automation_service_accounts[pair.0].iam_email,
      role        = pair.1
    }
  }

  ##############################################################################
  # Environment folder authoritative IAM bindings, built from the following sources:
  # - environment folder master service account roles
  # - shared VPC host automation service account roles
  # - user-provided custom IAM members (`environments_iam_members` variable)
  ##############################################################################

  # Env-folder IAM binding groups
  default_group_env_folder_devqa_support      = "group:gcp-f-${var.unit_code}-devqa-support@${var.domain}"
  default_group_env_folder_devqa_support_pri  = "group:gcp-f-${var.unit_code}-devqa-support-pri@${var.domain}"
  default_group_env_folder_noncde_support     = "group:gcp-f-${var.unit_code}-noncde-support@${var.domain}"
  default_group_env_folder_noncde_support_pri = "group:gcp-f-${var.unit_code}-noncde-support-pri@${var.domain}"
  default_group_env_folder_cde_support        = "group:gcp-f-${var.unit_code}-cde-support@${var.domain}"
  default_group_env_folder_cde_support_pri    = "group:gcp-f-${var.unit_code}-cde-support-pri@${var.domain}"
  default_group_env_folder_ops_support        = "group:gcp-f-${var.unit_code}-ops-support@${var.domain}"
  default_group_env_folder_ops_support_pri    = "group:gcp-f-${var.unit_code}-ops-support-pri@${var.domain}"

  x_default_group_env_folder_bindings = {
    devqa = {
      "roles/viewer" : [
        local.default_group_env_folder_devqa_support_pri,
      ],
      "roles/appengine.appViewer" : [
        local.default_group_env_folder_devqa_support,
        local.default_group_env_folder_devqa_support_pri,
      ],
      "roles/storage.objectViewer" : [
        local.default_group_env_folder_devqa_support_pri,
      ],
      "roles/cloudasset.viewer" : [
        local.default_group_env_folder_devqa_support,
      ],
      "roles/cloudtrace.user" : [
        local.default_group_env_folder_devqa_support,
      ],
      "roles/compute.viewer" : [
        local.default_group_env_folder_devqa_support,
      ],
      "roles/errorreporting.viewer" : [
        local.default_group_env_folder_devqa_support,
      ],
      "roles/iam.securityReviewer" : [
        local.default_group_env_folder_devqa_support,
      ],
      "roles/logging.viewer" : [
        local.default_group_env_folder_devqa_support,
      ]
    },
    noncde = {
      "roles/viewer" : [
        local.default_group_env_folder_noncde_support_pri,
      ],
      "roles/appengine.appViewer" : [
        local.default_group_env_folder_noncde_support,
        local.default_group_env_folder_noncde_support_pri,
      ],
      "roles/storage.objectViewer" : [
        local.default_group_env_folder_noncde_support_pri,
      ],
      "roles/cloudasset.viewer" : [
        local.default_group_env_folder_noncde_support,
      ],
      "roles/cloudtrace.user" : [
        local.default_group_env_folder_noncde_support,
      ],
      "roles/compute.viewer" : [
        local.default_group_env_folder_noncde_support,
      ],
      "roles/errorreporting.viewer" : [
        local.default_group_env_folder_noncde_support,
      ],
      "roles/iam.securityReviewer" : [
        local.default_group_env_folder_noncde_support,
      ],
      "roles/logging.viewer" : [
        local.default_group_env_folder_noncde_support,
      ]
    },
    cde = {
      "roles/viewer" : [
        local.default_group_env_folder_cde_support_pri,
      ],
      "roles/appengine.appViewer" : [
        local.default_group_env_folder_cde_support,
        local.default_group_env_folder_cde_support_pri,
      ],
      "roles/storage.objectViewer" : [
        local.default_group_env_folder_cde_support_pri,
      ],
      "roles/cloudasset.viewer" : [
        local.default_group_env_folder_cde_support,
      ],
      "roles/cloudtrace.user" : [
        local.default_group_env_folder_cde_support,
      ],
      "roles/compute.viewer" : [
        local.default_group_env_folder_cde_support,
      ],
      "roles/errorreporting.viewer" : [
        local.default_group_env_folder_cde_support,
      ],
      "roles/iam.securityReviewer" : [
        local.default_group_env_folder_cde_support,
      ],
      "roles/logging.viewer" : [
        local.default_group_env_folder_cde_support,
      ]
    }
    ops = {
      "roles/viewer" : [
        local.default_group_env_folder_ops_support_pri,
      ],
      "roles/appengine.appViewer" : [
        local.default_group_env_folder_ops_support,
        local.default_group_env_folder_ops_support_pri,
      ],
      "roles/storage.objectViewer" : [
        local.default_group_env_folder_ops_support_pri,
      ],
      "roles/cloudasset.viewer" : [
        local.default_group_env_folder_ops_support,
      ],
      "roles/cloudtrace.user" : [
        local.default_group_env_folder_ops_support,
      ],
      "roles/compute.viewer" : [
        local.default_group_env_folder_ops_support,
      ],
      "roles/errorreporting.viewer" : [
        local.default_group_env_folder_ops_support,
      ],
      "roles/iam.securityReviewer" : [
        local.default_group_env_folder_ops_support,
      ],
      "roles/logging.viewer" : [
        local.default_group_env_folder_ops_support,
      ]
    }
  }

  # Build { <env> : { <role> : [ members ] } } of folder service account roles
  x_environment_folder_service_account_iam_members = {
    for env, svc_acct in google_service_account.environment : env => {
      for role in var.environment_folder_service_account_roles :
      role => ["serviceAccount:${svc_acct.email}"]
    }
  }

  # Build { <env> : { <role> : [ members ] } } of Shared VPC service account roles
  x_environment_folder_svpc_iam_members = {
    for env in keys(local.environments) : env => {
      "roles/compute.xpnAdmin" = [
        for sa_env, svc_acct in module.env_svpc_automation_service_accounts :
        svc_acct.iam_email if(
          # All SVPC host projects live under the Operations folder
          env == "ops" ||
          # The SVPC service projects live under their respective environment folder
          env == sa_env ||
          # The 'shared' SVPC service projects will live in the CDE environment folder
        (sa_env == "shared" && env == "cde"))
      ]
    }
  }

  # Build { <env> : { <role> : [ members ] } } of custom iam members from tfvars
  x_environment_folder_custom_iam_members = {
    for env, roles in var.environments_iam_members : env => roles
  }

  # Build { <env> : [roles] } of all folder IAM roles for each environment
  x_environment_folder_iam_roles = {
    for env in keys(local.environments) : env => distinct(concat(
      keys(local.x_environment_folder_service_account_iam_members[env]),
      keys(local.x_environment_folder_svpc_iam_members[env]),
      keys(local.x_environment_folder_custom_iam_members[env]),
      keys(local.x_default_group_env_folder_bindings[env]),
    ))
  }

  # Build { <env-role> : { folder, role, [members] } } for authoritative IAM bindings
  all_environment_folder_iam_bindings = flatten([
    for env, roles in local.x_environment_folder_iam_roles : [
      for role in roles : {
        env    = env
        folder = google_folder.environment[env].name
        role   = role
        members = distinct(concat(
          lookup(local.x_environment_folder_service_account_iam_members[env], role, []),
          lookup(local.x_environment_folder_svpc_iam_members[env], role, []),
          lookup(local.x_environment_folder_custom_iam_members[env], role, []),
          lookup(local.x_default_group_env_folder_bindings[env], role, []),
        ))
      }
    ]
  ])

  # Combinded list of delegated roles and SVPC environment
  all_conhub_delegate_roles = setproduct(
    keys(local.environments_chs),
    var.lz_delegated_conhub_roles,
  )

  ##############################################################################
  # Organization policies
  ##############################################################################

  environments_policy_boolean_tuples = flatten([
    for environment, constraints in var.environments_policy_boolean : [
      for constraint, value in constraints :
      { environment = environment, constraint = constraint, constraint_setting = value }
    ]
  ])
  environments_policy_boolean_pairs = { for tuple in local.environments_policy_boolean_tuples :
    "${tuple.environment}-${tuple.constraint}" => tuple
  }
  environments_policy_list_tuples = flatten([
    for environment, constraints in var.environments_policy_list : [
      for constraint, value in constraints :
      { environment = environment, constraint = constraint, constraint_setting = value }
    ]
  ])
  environments_policy_list_pairs = { for tuple in local.environments_policy_list_tuples :
    "${tuple.environment}-${tuple.constraint}" => tuple
  }

  unit_trusted_images_projects = concat(
    var.trusted_images_projects,
    ["projects/${module.images_project.project_id}"],
  )

  images_project_name = "pid-go${var.country_code}gggp-${var.unit_code}-lz-images"

  ##############################################################################
  # Kubernetes/workload identity
  ##############################################################################

  kubernetes_sa_metadata = { for key, value in local.environments : key => kubernetes_service_account.lz_folder_sa[key].metadata.0 }

  # Aggregate all services that may touch automation project through workload identity automation and make a list for enablement
  automation_project_services = compact(distinct(concat(var.automation_project_services, var.images_project_services, var.shared_vpc_host_project_services)))
}
