locals {
  name-regex                = "/[^0-9A-Za-z-]/" # Anti-pattern to match all characters not in: 0-9 a-z A-Z -
  group_4                   = substr(var.group, 0, 4)
  project_4                 = substr(var.project, 0, 4)
  userDefinedString-replace = replace("${local.group_4}-${local.project_4}", "_", "-")
  kv_sha                    = substr(sha1(var.resource_groups["Keyvault"].id), 0, 8)
  name-kv-16                = substr("${local.env_4}CKV-${local.userDefinedString-replace}", 0, 16)
  name-kv-21                = substr("${local.name-kv-16}-${local.kv_sha}", 0, 21)
  kv_name                   = replace("${local.name-kv-21}-kv", local.name-regex, "")
  kv_resource_group_name    = try(var.vmss.key_vault.resource_group_name, "Keyvault")
}

# Need to get info about the subscription key vault. If password_overwrite is true, then don't bother since we  won't use it
data "azurerm_key_vault" "key_vault" {
  count               = try(var.vmss.admin_password, "") == "" ? 1 : 0
  name                = try(var.vmss.key_vault.name, local.kv_name)
  resource_group_name = strcontains(local.kv_resource_group_name, "/resourceGroups/") ? regex("[^\\/]+$", local.kv_resource_group_name) : var.resource_groups[local.kv_resource_group_name].name
}

# Generate a password if it will be necessary. Since it it only an inital password, ignore all changes to it
resource "random_password" "vm-admin-password" {
  count            = try(var.vmss.admin_password, "") == "" ? 1 : 0
  length           = 16
  special          = true
  override_special = "!#$%&*"
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1

  lifecycle {
    ignore_changes = all
  }
}

# Creates a secret in the subscription keyvault if a generated password is necessary. Since it will be only an inital password, ignore all changes to it
resource "azurerm_key_vault_secret" "vm-admin-password" {
  count        = try(var.vmss.admin_password, "") == "" ? 1 : 0
  name         = "${local.vmss_name}-vm-admin-password"
  value        = random_password.vm-admin-password[0].result
  key_vault_id = data.azurerm_key_vault.key_vault[0].id
  content_type = "password"

  lifecycle {
    ignore_changes = all
  }
}
