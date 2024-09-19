variable "vmss_windowsV2" {
  type = any
}

module "vmss_windowsV2" {
  for_each = var.vmss_windowsV2
  source   = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-vmss-windowsV2?ref=v1.0.2"

  location          = var.location
  subnets           = local.subnets
  resource_groups   = local.resource_groups_L1
  userDefinedString = each.key
  tags              = var.tags
  env               = var.env
  group             = var.group
  project           = var.project
  vmss              = each.value
  custom_data       = try(each.value.custom_data, false) != false ? base64encode(file("${path.cwd}/${each.value.custom_data}")) : null
  user_data         = try(each.value.user_data, false) != false ? base64encode(file("${path.cwd}/${each.value.user_data}")) : null
}