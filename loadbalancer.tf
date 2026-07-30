module "load_balancer" {
  count  = try(var.vmss.lb, null) != null ? 1 : 0
  source = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-load_balancer.git?ref=v2.0.0"

  location          = var.location
  subnets           = var.subnets
  resource_groups   = var.resource_groups
  userDefinedString = var.userDefinedString
  tags              = var.tags
  env               = var.env
  load_balancer     = merge(var.vmss.lb, { postfix = var.vmss.postfix, resource_group_name = var.vmss.resource_group_name, custom_name = local.vmss_name })
}
