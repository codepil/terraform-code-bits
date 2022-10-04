# gcp-kms-keyring

This module creates a Key ring in GCP, and assigns
IAM members to specified roles as an optional entity in managing key ring.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.7 |
| google | >= 2.13 |

## Providers

| Name | Version |
|------|---------|
| google | >= 2.13 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_kms_key_ring.key_ring](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_key_ring) | resource |
| [google_kms_key_ring_iam_member.iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_key_ring_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| key\_ring\_name | The name of the key ring to be created. | `string` | n/a | yes |
| project\_id | The project ID in which the resources should be created. | `string` | n/a | yes |
| location | The location of the key ring to be created. Default is "global". | `string` | `"global"` | no |
| role\_mappings | A list maps of the accounts and roles to be bound to this kms key ring. If this is empty, no keyring-specific roles will be assigned. Example: [ { account="service1@pid.iam.google.com", role="roles/cloudkms.admin"}] | `list(object({ account = string, role = string }))` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| self\_link | n/a |
