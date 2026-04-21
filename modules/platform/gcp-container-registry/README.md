# gcp-container-registry

This module creates a container registry in GCP, and assigns
IAM members to specified roles on the underlying bucket behind
the container registry.

Requires the following APIs:
* containerregistry.googleapis.com

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.24 |

## Providers

| Name | Version |
|------|---------|
| google | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | Project id of the project in which to create the registry. | `string` | n/a | yes |
| iam\_role\_members | Map of member list, keyed by role, used to assign roles using authoritative binding to the backend storage bucket behind the registry.  NOTE: these roles will be granted in additive manor, so-as not to cause issue with GCP's own permission grants as part of GCR. | `map(list(string))` | `{}` | no |
| location | Location of the registry. Can be US, EU, ASIA or empty. Note: empty string defaults to `null` now, but may change in future. | `string` | `null` | no |
| use\_iam\_binding | Flag to indicate how IAM roles are granted to members: use of authoritative binding (true), use additive (false).  Note, authoritative method will overwrite any IAM changes made out of band from this code.  Additive will leave existing members unchanged, but provide less enforcement of IAM as code. | `bool` | `true` | no |
| gcr\_scan\_member | IAM member identity allowed to scan the registry from Twistlock/Prisma console. It defaults to centrally created service account, for which credentials already created in Prisma console. | `string` | `"serviceAccount:act-twistlock@pid-gcp-sec-scan01.iam.gserviceaccount.com"`| no |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_id | ID(name) of the GCS bucket created for GCR. |
| bucket\_self\_link | Self\_link of the GCS bucket created for GCR. |

