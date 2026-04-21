# gcp-binary-authorization/attestor
Binary Authorization is a Google Cloud managed service that works closely with GKE to enforce deploy-time security controls
to ensure that only trusted container images are deployed.

This module creates an attestor to the Binary Authorisation, on a given project.

Below resources/configurations are created by the module,
* Attestor
* Container analysis note
* IAM binding

A Container Analysis Note is used to represent a single attestor, and Occurrences are created and associated with each container that attestor has approved.
The Binary Authorization API uses the concepts of "attestors" and "attestations", but these are implemented using corresponding Notes and Occurrences in the Container Analysis API.

![Analogy](https://codelabs.developers.google.com/codelabs/cloud-binauthz-intro/img/63a701bd0057ea17.png)

## Pre-requisites
* Refer to [README](../README.md) for overall solution and attestor requirements

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
| [google_binary_authorization_attestor.attestor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/binary_authorization_attestor) | resource |
| [google_binary_authorization_attestor_iam_binding.verifier_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/binary_authorization_attestor_iam_binding) | resource |
| [google_container_analysis_note.build-note](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_analysis_note) | resource |
| [google_kms_crypto_key_version.version](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_crypto_key_version) | data source |
| [google_project.attestor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| attestor\_name\_prefix | (Required) Attestor names prefix | `string` | n/a | yes |
| attestor\_project\_id | (Required) The Attestor project ID in which the Binary authorisation resources should be created. | `string` | n/a | yes |
| crypto\_key\_id | (Required) ID of crypto key to be used in signing images. | `string` | n/a | yes |
| deployer\_project\_numbers | (Required) The list of Deployer project numbers. The deployer project manages the Google Kubernetes Engine (GKE) clusters. | `list(number)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| attestor | Created Attestor details |
| note | Created Container analysis note details |
