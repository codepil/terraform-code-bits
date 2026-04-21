# terraform-code-bits

A collection of reusable Terraform modules for Google Cloud Platform (GCP), organized by domain.

---

## Structure

```
modules/
├── networking/
│   ├── gcp-network/                      # VPC, subnets, DNS, Cloud NAT, subnet generation
│   ├── gcp-network-intrusion-detection/  # Suricata-based IDS with log export
│   ├── gcp-proxyvm/                      # Proxy VM provisioning
│   └── gcp-iap-access/                   # Identity-Aware Proxy access
├── compute/
│   ├── gcp-compute-mig-stack/            # Managed Instance Group with LB options
│   ├── gcp-syslog-collector/             # Syslog collector VM
│   └── gcp-logicmonitor-collector/       # LogicMonitor monitoring agent
├── kubernetes/
│   ├── gcp-k8s-sbx/                      # GKE sandbox cluster
│   ├── gcp-gke-namespace/                # Kubernetes namespace on GKE
│   └── gcp-lz-jenkins-gke/              # Jenkins on GKE in a landing zone
├── security/
│   ├── gcp-kms-key/                      # KMS key management
│   ├── gcp-kms-keyring/                  # KMS keyring management
│   └── gcp-binary-authorization/         # Binary Authorization (attestor, key, policy sub-modules)
└── platform/
    ├── gcp-bu-project/                   # Business Unit project provisioning
    ├── gcp-bu-lz-stack/                  # Full Landing Zone stack for a BU
    ├── gcp-container-registry/           # Container Registry setup
    ├── gcp-scheduler-job/                # Cloud Scheduler job
    └── gcp-storage-notification/         # GCS bucket event notifications
```

---

## How to Use

Each module is self-contained with `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, and an `examples/` directory with real `.tfvars` files. Reference a module from your Terraform root:

```hcl
module "network" {
  source = "git::https://github.com/your-org/terraform-code-bits//modules/networking/gcp-network"
  # ...variables
}
```

---

## Why It's Useful

- **Copy-paste ready** — Every module ships with working examples in `examples/`, so you can get started without reading all the variables.
- **Landing Zone patterns** — `gcp-bu-project` and `gcp-bu-lz-stack` encode opinionated GCP landing zone conventions (project naming, org hierarchy, IAM).
- **Security-focused building blocks** — Modules for IDS (`gcp-network-intrusion-detection`), Binary Authorization, and IAP cover GCP security controls that are otherwise tedious to wire up from scratch.
- **GKE ecosystem coverage** — From cluster (`gcp-k8s-sbx`) to namespace to Jenkins CI, the GKE modules cover the full workload lifecycle.
- **Sub-module composition** — Modules like `gcp-network` include internal sub-modules (Cloud NAT, subnet generation) and `gcp-binary-authorization` is split into `attestor`, `key`, and `policy` sub-modules for fine-grained reuse.

---

## Terraform Patterns Reference

See [terraform-patterns.md](terraform-patterns.md) for advanced patterns used across these modules, including:

- `count` vs `for_each` — when to use each and state gotchas
- `locals` — naming, tag merging, and list-to-map transforms
- `lifecycle` meta-arguments — `prevent_destroy`, `ignore_changes`, `create_before_destroy`
- Data sources — reading existing resources and plan vs apply timing
- `dynamic` blocks — generating variable nested blocks in reusable modules
- `moved` blocks — renaming and restructuring resources without destroy/recreate
- `terraform import` (1.5+) — adopting existing resources into state
- Role assignment scope patterns — subscription, resource group, and resource-level
- Private endpoint pattern — the three-resource pattern for private connectivity
