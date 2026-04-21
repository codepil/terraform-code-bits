# Advanced Terraform Patterns

Reference for patterns that go beyond basic resource authoring. Load this when writing complex modules, refactoring, or handling non-trivial data flow.

---

## count vs for_each

**Decision rule:** If instances are distinguished by a meaningful key (name, ID, purpose) → `for_each`. If they are truly interchangeable (N identical things) → `count`.

### count

```hcl
# Good: N identical things, numeric index is fine
resource "azurerm_role_assignment" "team_reader" {
  count                = length(var.team_member_object_ids)
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Reader"
  principal_id         = var.team_member_object_ids[count.index]
}

# Conditional resource (most common use of count)
resource "azurerm_dns_zone" "main" {
  count               = var.domain_name != "" ? 1 : 0
  name                = var.domain_name
  resource_group_name = var.resource_group_name
}
# Reference: azurerm_dns_zone.main[0].id
```

**State gotcha:** Removing an element from the middle of a list renumbers all subsequent instances, causing Terraform to destroy and recreate them. If order stability matters, use `for_each` instead.

### for_each

```hcl
# Good: each instance has a stable, meaningful key
resource "azurerm_managed_disk" "data" {
  for_each             = var.disks  # map(object({size_gb = number, sku = string}))
  name                 = "disk-${each.key}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  storage_account_type = each.value.sku
  disk_size_gb         = each.value.size_gb
}
# Reference: azurerm_managed_disk.data["logs"].id

# Converting a list to a set for for_each
resource "azurerm_key_vault_secret" "creds" {
  for_each     = toset(var.secret_names)
  name         = each.key
  value        = "placeholder"
  key_vault_id = var.key_vault_id
}
```

**Sensitive value gotcha:** Cannot use sensitive values as `for_each` keys — Terraform evaluates keys at plan time before any apply.

**Cannot mix:** A single resource block cannot have both `count` and `for_each`.

**Switching between them** is a breaking state change — use `moved` blocks to migrate without destroy/recreate.

---

## locals

Use locals to name complex expressions used more than once, or to make configuration self-documenting.

```hcl
locals {
  # Naming pattern — used across many resources
  name_prefix = "${var.project_name}-${var.environment}"

  # Merging tag maps consistently
  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  })

  # Derived boolean from variable
  enable_dns = var.domain_name != ""

  # Transforming a list into a map for for_each
  identity_map = {
    for id in var.managed_identity_names :
    id => "id-${id}-${var.environment}"
  }
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.common_tags
}
```

**When NOT to use locals:** Single-use inline expressions are clearer than a local with one reference. Locals that wrap simple attribute references (`local.rg_name = azurerm_resource_group.main.name`) add indirection with no value.

---

## lifecycle meta-arguments

```hcl
resource "azurerm_key_vault" "main" {
  # ...

  lifecycle {
    # Blocks accidental destruction — terraform destroy or removal from config
    # still requires manual `terraform state rm` to decouple safely
    prevent_destroy = true

    # Ignore externally managed attributes (e.g., AKS writes its own tags)
    ignore_changes = [tags["kubernetes.io/cluster"]]

    # Ignore ALL attribute drift — use only when truly relinquishing management
    # ignore_changes = [all]

    # Replace this resource whenever a dependency changes
    # replace_triggered_by = [azurerm_subnet.main.id]
  }
}

# create_before_destroy: creates the replacement before destroying the old instance
# Use when a resource cannot be updated in-place and you need continuity
resource "azurerm_subnet" "apps" {
  lifecycle {
    create_before_destroy = true
  }
}
```

**prevent_destroy gotcha:** Removing `prevent_destroy = true` from config and running `terraform apply` destroys the resource. To safely decouple: `terraform state rm <resource_address>`.

**ignore_changes gotcha:** Applied during updates only, not creation. Use specific attribute paths rather than `all` unless you intend Terraform to stop managing the resource's configuration entirely.

**create_before_destroy propagation:** Terraform implicitly propagates this behaviour to all dependencies of the resource — which can trigger unexpected replacements upstream.

---

## data sources

Data sources read existing Azure resources without creating or managing them. They do not create state entries.

```hcl
# Current authenticated client — used in this repo for pipeline identity
data "azurerm_client_config" "current" {}
# data.azurerm_client_config.current.object_id    (pipeline's Object ID)
# data.azurerm_client_config.current.tenant_id
# data.azurerm_client_config.current.subscription_id

# Current subscription details
data "azurerm_subscription" "current" {}
# data.azurerm_subscription.current.id            (subscription resource ID)
# data.azurerm_subscription.current.subscription_id

# Read an existing resource not managed by this Terraform
data "azurerm_resource_group" "shared" {
  name = "rg-shared-services"
}

# Read an existing Key Vault (e.g., managed by another repo)
data "azurerm_key_vault" "external" {
  name                = "kv-shared-prod-abc123"
  resource_group_name = data.azurerm_resource_group.shared.name
}

# Read an existing subnet (e.g., from a hub VNet)
data "azurerm_subnet" "hub" {
  name                 = "snet-gateway"
  virtual_network_name = "vnet-hub-prod"
  resource_group_name  = "rg-hub-networking"
}
```

**depends_on with data sources:** When a data source depends on a resource Terraform is also creating, add explicit `depends_on` to force correct ordering:

```hcl
data "azurerm_kubernetes_cluster" "aks" {
  name                = azurerm_kubernetes_cluster.main.name
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_kubernetes_cluster.main]
}
```

**Plan vs apply timing:** Data sources are read at plan time when possible. If they reference apply-time values, the read is deferred — plan output shows `(known after apply)` for downstream attributes.

---

## dynamic blocks

Use dynamic blocks in reusable modules to generate a variable number of nested configuration blocks from a collection input.

```hcl
# In a module: generate NSG rules dynamically from a variable
variable "security_rules" {
  type = list(object({
    name                   = string
    priority               = number
    direction              = string
    access                 = string
    protocol               = string
    source_address_prefix  = string
    destination_port_range = string
  }))
  default = []
}

resource "azurerm_network_security_group" "main" {
  name                = "nsg-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = var.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_port_range     = security_rule.value.destination_port_range
      source_port_range          = "*"
      destination_address_prefix = "*"
    }
  }
}
```

**Overuse warning:** If most of a resource block is dynamic, the abstraction is likely wrong — consider letting callers define the resource directly.

**Cannot use for meta-arguments:** `lifecycle`, `provisioner`, and `provider` blocks cannot be generated with `dynamic`.

---

## moved blocks

Use `moved` to rename or restructure resources without triggering destroy/recreate. Required when:
- Renaming a resource identifier
- Moving a resource into a module
- Adding `for_each` or `count` to an existing single resource

```hcl
# Rename a resource
moved {
  from = azurerm_subnet.data
  to   = azurerm_subnet.aks_nodes
}

# Move a resource into a module
moved {
  from = azurerm_key_vault.main
  to   = module.keyvault.azurerm_key_vault.main
}

# Convert single resource to for_each
# Before: resource "azurerm_role_assignment" "reader" { ... }
# After:  resource "azurerm_role_assignment" "reader" { for_each = toset(var.ids) }
moved {
  from = azurerm_role_assignment.reader
  to   = azurerm_role_assignment.reader["somekey"]
}
```

**Keep moved blocks permanently** in module code — removing one is a breaking change for anyone who already applied the old address. They can be removed only after confirming all users have applied the migration.

---

## terraform import (Terraform 1.5+)

Adopt existing Azure resources into Terraform state without recreating them. Use the import block (1.5+) over the legacy CLI command.

### Workflow

```hcl
# Step 1: Write import block (e.g., imports.tf — delete after apply)
import {
  id = "/subscriptions/92587c31-827a-4b7d-870a-f29c9f9103b2/resourceGroups/rg-procurement-dev/providers/Microsoft.Network/virtualNetworks/vnet-procurement-dev"
  to = module.networking.azurerm_virtual_network.main
}
```

```bash
# Step 2: Optionally generate config
terraform plan -generate-config-out=generated.tf
# Review and clean up generated.tf — it may contain deprecated arguments

# Step 3: Apply import
terraform plan    # Should show 0 destructive changes
terraform apply   # Imports resource into state
```

### Finding Azure resource IDs

```bash
# Resource group
az group show --name rg-procurement-dev --query id -o tsv

# VNet
az network vnet show --name vnet-procurement-dev --resource-group rg-procurement-dev --query id -o tsv

# Key Vault
az keyvault show --name kv-proc-dev-264443e2 --query id -o tsv

# Role assignments (returns full resource IDs)
az role assignment list --scope /subscriptions/<sub-id>/resourceGroups/rg-procurement-dev --query "[].id" -o tsv
```

---

## Role assignment scope patterns

```hcl
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

# Subscription scope
resource "azurerm_role_assignment" "sub_reader" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = var.principal_id
}

# Resource group scope (most common in this repo)
resource "azurerm_role_assignment" "rg_contributor" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id         = var.principal_id
}

# Specific resource scope
resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.managed_identity_principal_id
}

# AcrPull for AKS kubelet (pattern in acr module)
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = var.aks_kubelet_identity_object_id
}
```

**principal_id is the Object ID** — not the Application ID. For managed identities use `.principal_id`. For users/service principals use the Object ID from Entra ID.

**New SP timing:** Set `skip_service_principal_aad_check = true` when assigning a role to a freshly created service principal to avoid AAD replication-lag failures.

---

## Private endpoint pattern

Repeated for PostgreSQL and blob storage in this repo. Three resources are always required together:

```hcl
# 1. The private endpoint itself
resource "azurerm_private_endpoint" "storage" {
  name                = "pe-${var.storage_account_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id  # dedicated subnet — no service endpoint conflicts

  private_service_connection {
    name                           = "psc-${var.storage_account_name}"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}

# 2. Private DNS zone for the service
resource "azurerm_private_dns_zone" "storage" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
}

# 3. Link DNS zone to the VNet so resolution works
resource "azurerm_private_dns_zone_virtual_network_link" "storage" {
  name                  = "pdnsl-storage-${var.environment}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.storage.name
  virtual_network_id    = var.vnet_id
}
```

**DNS zone names by service:**

| Service | subresource_names | DNS zone |
|---|---|---|
| Blob Storage | `["blob"]` | `privatelink.blob.core.windows.net` |
| Key Vault | `["vault"]` | `privatelink.vaultcore.azure.net` |
| PostgreSQL Flexible | `["postgresqlServer"]` | `privatelink.postgres.database.azure.com` |
| ACR | `["registry"]` | `privatelink.azurecr.io` |
| AKS API server | `["management"]` | `privatelink.{region}.azmk8s.io` |
