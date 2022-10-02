# gcp-binary-authorization/policy
Binary Authorization is a Google Cloud managed service that works closely with GKE to enforce deploy-time security controls
to ensure that only trusted container images are deployed.

This module creates a default policy to the Binary Authorisation, on a given project.

Below resources/configurations are created by the module,
* Default global auth policy
* Cluster specific auth policy, if any
* Whitelisting of images & registries

Refer to [default policy rule](https://cloud.google.com/binary-authorization/docs/configuring-policy-cli#default-rule) for available parameters.
The globalPolicyEvaluationMode line declares that this policy extends the global policy defined by Google. This allows all official GKE containers to run by default.
Additionally, the policy declares a defaultAdmissionRule DENY\_ALL that states that all other pods will be rejected. The admission rule includes an enforcementMode line, which states that all pods that are not conformant to this rule should be blocked from running on the cluster.

## Pre-requisites
* Deployer Project should have enabled Binary Authorisation APIs ("binaryauthorization.googleapis.com", "containerregistry.googleapis.com", "artifactregistry.googleapis.com", "container.googleapis.com" ).
* Google Kubernetes Engine(GKE) cluster crated with "Binary Authorization" enabled
* Given Landing Zone is already have an common Attestor, if not use [this](https://github.com/codepil/terraform-code-bits/gcp-binary-authorization-attestor/-/tree/main) TF to create one on respective landing zone project.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.7 |
| google | >= 3.65.0 |
| google-beta | >= 3.65.0 |

## Providers

| Name | Version |
|------|---------|
| google | >= 3.65.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_binary_authorization_policy.policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/binary_authorization_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| attestor\_names | (Required) List of attestor names, in the format [projects/<attestor\_project\_id>/attestors/<attestor\_name>,] | `list(string)` | n/a | yes |
| deployer\_project\_id | (Required) The deployer project ID. The deployer project manages the Google Kubernetes Engine (GKE) clusters, where you deploy images. | `string` | n/a | yes |
| cluster\_admission\_rules | (Optional) List of cluster specific admission rules. Cluster is name/id of the GKE cluster & possible values of evaluation\_mode are ALWAYS\_ALLOW, REQUIRE\_ATTESTATION, and ALWAYS\_DENY | <pre>list(object({<br>    cluster = string<br>    evaluation_mode = string<br>  }))</pre> | `[]` | no |
| default\_evaluation\_mode | (Optional) Default admission rule. Possible values are ALWAYS\_ALLOW, REQUIRE\_ATTESTATION, and ALWAYS\_DENY. Default admission rule is global to all clusters. | `string` | `"ALWAYS_DENY"` | no |
| images\_exempted | (Optional) List of an image names or pattern to whitelist, in the form registry/path/to/image. This supports a trailing * as a wildcard. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| policy | Details of policy created |
