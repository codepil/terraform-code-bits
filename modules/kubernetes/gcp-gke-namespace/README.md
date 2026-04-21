# GKE namespace module

This module can be used to create GKE  namespace  


# Requirements

orachestration's serviceaccounts should be granted with Kubernetes Engine Admin role.

# Usage

Example

```hcl
module "namespace" {
  source     = "./module"
  project_id    = var.project_id
  location      = var.location
  cluster       = var.cluster
  nsname        = {
    "prod"         = {
      "annotation" = {
      "name"     = "prod-namespace"
      }
      "labels"     = {
        "env"      = "prod"
        "dept"     = "sales"
      }
    }
 }
}
```


<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---: |:---:|:---:|
|project\_id | Project where cluster got deployed and namespace to be created | `string` | yes | n/a |
|location | cluster location - could be either zone/region name. | `string` | no | n/a|
|name | GKE Cluster where namespace to be created | `string` | yes | n/a|
|nsname | Map keyed by namespace|map(map(map(string))) | no| {}|
## Outputs

| name | description | sensitive |
|---|---|:---:|
|cluster\_name | GKE cluster name| |
|endpoint      | Cluster endpoint| |
|namespace\_self\_link | namespace's self link | |

<!-- END TFDOC -->
