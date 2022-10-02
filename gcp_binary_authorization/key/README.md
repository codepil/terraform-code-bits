# gcp-binary-authorization/key
Creates attestation key, and adds cryptoOperator IAM role to Deployer and Attestor project's SA responsible for Binary Authorisation.

## Pre-requisites
* Keys project should have Cloud KMS APIs ("cloudkms.googleapis.com") enabled
* Refer to [README](../README.md) for overall solution's requirements

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

| Name | Source | Version |
|------|--------|---------|
| attestor-key | git::https://github.com/codepil/terraform-code-bits/gcp-kms-key.git?ref=v1.0.0 |  |
| key-ring | git::https://github.com/codepil/terraform-code-bits/gcp-kms-keyring.git?ref=v1.0.0 |  |

## Resources

| Name | Type |
|------|------|
| [google_kms_key_ring.attestor_key_ring](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_key_ring) | data source |
| [google_project.key_project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| attestor\_key\_name | (Required) Name of attestor key | `string` | n/a | yes |
| attestor\_project\_number | (Required) The Attestor project number in which the Binary authorisation resources should be created. | `number` | n/a | yes |
| deployer\_project\_numbers | (Required) List of deployer project numbers. The deployer projects are the one that hosts Google Kubernetes Engine (GKE) clusters. | `list(number)` | n/a | yes |
| key\_project\_id | (Required) The key project ID in which the crypto key is to be created. | `string` | n/a | yes |
| key\_ring\_name | (Optional) Name of Keyring. If Keyring by given name is not present in the key\_project\_id then new Keyring shall be created with that name. | `string` | `"attestor-key-ring"` | no |
| key\_users | (Optional) List of users or SAs that would require to have cryptoOperator role provisioned as part this module. Deployment automation SAs which creates Attestors are to be part of this list. | `list(string)` | `[]` | no |
| location | (Optional) Location of Keyring to be created or fetched. | `string` | `"global"` | no |

## Outputs

| Name | Description |
|------|-------------|
| key | Crypto key ID |
| key-ring | Keyring self\_link |
