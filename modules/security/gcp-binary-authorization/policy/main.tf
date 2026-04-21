/*
* # gcp-binary-authorization/policy
* Binary Authorization is a Google Cloud managed service that works closely with GKE to enforce deploy-time security controls
* to ensure that only trusted container images are deployed.
*
* This module creates a default policy to the Binary Authorisation, on a given project.
*
* Below resources/configurations are created by the module,
* * Default global auth policy
* * Cluster specific auth policy, if any
* * Whitelisting of images & registries
*
* Refer to [default policy rule](https://cloud.google.com/binary-authorization/docs/configuring-policy-cli#default-rule) for available parameters.
* The globalPolicyEvaluationMode line declares that this policy extends the global policy defined by Google. This allows all official GKE containers to run by default.
* Additionally, the policy declares a defaultAdmissionRule DENY_ALL that states that all other pods will be rejected. The admission rule includes an enforcementMode line, which states that all pods that are not conformant to this rule should be blocked from running on the cluster.
*
* ## Pre-requisites
* * Deployer Project should have enabled Binary Authorisation APIs ("binaryauthorization.googleapis.com", "containerregistry.googleapis.com", "artifactregistry.googleapis.com", "container.googleapis.com" ).
* * Google Kubernetes Engine(GKE) cluster crated with "Binary Authorization" enabled
* * Given Landing Zone is already have an common Attestor, if not use [this](https://github.com/codepil/terraform-code-bits/gcp-binary-authorization-attestor/-/tree/main) TF to create one on respective landing zone project.
*
*
*/

resource "google_binary_authorization_policy" "policy" {
  project     = var.deployer_project_id
  description = "Binary Auth policy for project ${var.deployer_project_id} (Terraform managed)"

  default_admission_rule {
    evaluation_mode         = var.default_evaluation_mode
    enforcement_mode        = "ENFORCED_BLOCK_AND_AUDIT_LOG"
    require_attestations_by = var.default_evaluation_mode == "REQUIRE_ATTESTATION"? var.attestor_names :null
  }

  global_policy_evaluation_mode = "ENABLE"

  dynamic "cluster_admission_rules" {
    for_each = var.cluster_admission_rules
    content {
      cluster = cluster_admission_rules.value.cluster
      evaluation_mode = cluster_admission_rules.value.evaluation_mode
      enforcement_mode = "ENFORCED_BLOCK_AND_AUDIT_LOG"
      require_attestations_by = cluster_admission_rules.value.evaluation_mode == "REQUIRE_ATTESTATION"? var.attestor_names :null
    }
  }

  dynamic "admission_whitelist_patterns" {
    for_each = var.images_exempted
    content {
      name_pattern = admission_whitelist_patterns.value
    }
  }

}

