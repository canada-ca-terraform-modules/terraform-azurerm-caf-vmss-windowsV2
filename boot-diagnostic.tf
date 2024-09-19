# A storage account is needed to store the boot diagnostic logs
module "boot_diagnostic_storage" {
  source = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-storage_accountV2.git?ref=v1.0.3"
  count = try(var.vmss.boot_diagnostic.use_managed_storage_account, true) ? 0 : (try(var.vmss.boot_diagnostic, false) ? (try(var.vmss.boot_diagnostic.storage_account_resource_id, "") == "" ? 1 : 0) : 0)

  userDefinedString    = "${var.userDefinedString}-logs"
  location             = var.location
  env                  = var.env
  resource_groups      = var.resource_groups
  subnets              = var.subnets
  private_dns_zone_ids = null
  tags                 = var.tags
  storage_account = {
    resource_group            = var.vmss.resource_group_name
    account_tier              = "Standard"
    account_replication_type  = "GRS"
    private_endpoint = {
      "${var.userDefinedString}-logs" = {
        resource_group = var.vmss.resource_group_name
        subnet = var.vmss.nic.nic1.ip_configuration.ipc1.subnet
        subresource_names = ["blob"]
      }
    }
  }
}

# Create a user assigned identity for the VM if one is not provided
resource "azurerm_user_assigned_identity" "user_assigned_identity_vmss_windows" {
  count = try(var.vmss.boot_diagnostic.use_managed_storage_account, true) ? 0 : (try(var.vmss.identity.type, "UserAssigned") == "UserAssigned" ? (try(var.vmss.identity.identity_ids, []) == [] ? 1 : 0) : 0)

  location            = var.location
  name                = "${local.vmss_name}-vmss-uai"
  resource_group_name = local.resource_group_name
}

# The VMSS user_assigned_identity_vmss_windows needs the Storage Blob Data Contributor to be able to access the SA to dump its logs
resource "azurerm_role_assignment" "vmss_contributor" {
  count = try(var.vmss.boot_diagnostic.use_managed_storage_account, true) ? 0 : (try(var.vmss.boot_diagnostic, false) ? 1 : 0)

  scope = try(var.vmss.boot_diagnostic.storage_account_resource_id, "") == "" ? module.boot_diagnostic_storage[0].id : var.vmss.boot_diagnostic.storage_account_resource_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id = try(var.vmss.identity.identity_ids, []) == [] ? azurerm_user_assigned_identity.user_assigned_identity_vmss_windows[0].principal_id : var.vmss.identity.identity_ids[0]
}