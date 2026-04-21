# gcp-kms-keyring

This module creates a Cryptographic keys, and assigns
IAM members to specified roles in using and managing the key.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.7 |
| google | >= 3.65.0 |

## Providers

| Name | Version |
|------|---------|
| google | >= 3.65.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_kms_crypto_key.crypto_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key) | resource |
| [google_kms_crypto_key_iam_binding.owners](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_binding) | resource |
| [google_kms_crypto_key_iam_member.iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| key\_name | (Required) The name of the crypto key to be created. | `string` | n/a | yes |
| key\_ring | (Required) The KeyRing self\_link that this key belongs to. | `string` | n/a | yes |
| project\_id | (Required) The project ID in which the resources should be created. | `string` | n/a | yes |
| purpose | (Required) The Crypto key purpose. See https://cloud.google.com/kms/docs/reference/rest/v1/projects.locations.keyRings.cryptoKeys#CryptoKeyPurpose for possible inputs | `string` | n/a | yes |
| algorithm | (Optional) The algorithm to use when creating a version. See https://cloud.google.com/kms/docs/reference/rest/v1/CryptoKeyVersionAlgorithm for possible inputs. If not set it defaults to Your company recommended value. | `string` | `null` | no |
| iam\_role\_members | Map of roles containing list of IAM members to be granted access.  See `use_iam_binding` on how this is applied. | `map(list(string))` | `{}` | no |
| labels | (Optional) A map of key:value pairs to apply as labels to assign to the crypto key. | `map(string)` | `{}` | no |
| protection\_level | (Optional) The protection level to use when creating a version. Possible values are SOFTWARE and HSM. | `string` | `"SOFTWARE"` | no |
| rotation\_period | (Optional) The rotation period of the key. The rotation period has the format of a decimal number with up to 9 fractional digits, followed by the letter s (seconds). It must be greater than a day (ie, 86400). Defaults to 90 days | `string` | `"7776000s"` | no |
| use\_iam\_binding | Flag to indicate how IAM roles are granted to members: use of authoritative binding (true), use additive (false).  Note, authoritative method will overwrite any IAM changes made out of band from this code.  Additive will leave existing members unchanged, but provide less enforcement of IAM as code. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| key | Self link of crypto key created |
