module "load_balancer" {
  count = try(var.vmss.lb, null) != null ? 1 : 0
  source   = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-load_balancer.git?ref=v1.0.2"

  location          = var.location
  subnets           = var.subnets
  resource_groups   = var.resource_groups
  userDefinedString = var.userDefinedString
  tags              = var.tags
  env               = var.env
  group             = var.group
  project           = var.project
  load_balancer     = merge(var.vmss.lb, { postfix = var.vmss.postfix, resource_group_name = var.vmss.resource_group_name, custom_name = local.vmss_name })
  custom_data       = try(var.vmss.lb.custom_data, false) != false ? base64encode(file("${path.cwd}/${var.vmss.lb.custom_data}")) : null
  user_data         = try(var.vmss.lb.user_data, false) != false ? base64encode(file("${path.cwd}/${var.vmss.lb.user_data}")) : null
}