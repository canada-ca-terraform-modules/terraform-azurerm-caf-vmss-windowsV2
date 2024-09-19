resource "azurerm_lb" "loadbalancer" {
  # Conditional creation of the load balancer if a load balancer configuration is provided for the VMSS
  count = try(var.vmss.lb, null) != null ? 1 : 0

  # Name and location settings for the load balancer
  name                = "${local.vmss_name}-lb"
  location            = var.location
  resource_group_name = local.resource_group_name

  edge_zone = try(var.vmss.lb.edge_zone, null)

  # Frontend IP configuration - defines how the load balancer is exposed on the network
  dynamic "frontend_ip_configuration" {
    for_each = try(var.vmss.lb.frontend_ip_configuration, {})

    content {
      name                                               = "${local.vmss_name}-${frontend_ip_configuration.key}-lbfe"
      zones                                              = try(frontend_ip_configuration.value.zones, null)
      subnet_id                                          = var.subnets[frontend_ip_configuration.value.subnet_name].id
      gateway_load_balancer_frontend_ip_configuration_id = try(frontend_ip_configuration.value.gateway_load_balancer_frontend_ip_configuration_id, null)
      private_ip_address                                 = try(frontend_ip_configuration.value.private_ip_address_allocation, "Static") == "Static" ? frontend_ip_configuration.value.private_ip_address : null
      private_ip_address_allocation                      = try(frontend_ip_configuration.value.private_ip_address_allocation, "Static")
      private_ip_address_version                         = try(frontend_ip_configuration.value.private_ip_address_version, "IPv4")
      public_ip_address_id                               = try(frontend_ip_configuration.value.public_ip_address_id, null)
      public_ip_prefix_id                                = try(frontend_ip_configuration.value.public_ip_prefix_id, null)
    }
  }

  sku      = try(var.vmss.lb.sku, "Standard")
  sku_tier = try(var.vmss.lb.sku_tier, null)
  tags     = merge(var.tags, try(var.vmss.lb.tags, {}))
}

resource "azurerm_lb_probe" "loadbalancer-lbhp" {
  for_each = try(var.vmss.lb.probes, {})

  name                = "${local.vmss_name}-${each.key}-lbhp"
  loadbalancer_id     = azurerm_lb.loadbalancer[0].id
  protocol            = try(each.value["protocol"], "Tcp")
  port                = each.value.port
  probe_threshold     = try(each.value["probe_threshold"], null)
  request_path        = try(each.value["request_path"], null)
  interval_in_seconds = try(each.value["interval_in_seconds"], 5)
  number_of_probes    = try(each.value["number_of_probes"], 2)
}

resource "azurerm_lb_backend_address_pool" "loadbalancer-lbbp" {
  count = try(var.vmss.lb, null) != null ? 1 : 0

  name             = "${local.vmss_name}-HA-lbbp"
  loadbalancer_id  = azurerm_lb.loadbalancer[0].id
  synchronous_mode = try(var.vmss.lb.synchronous_mode, null)
  dynamic "tunnel_interface" {
    for_each = try(var.vmss.lb.tunnel_interfaces, {})
    content {
      identifier = tunnel_interface.value.identifier
      type       = tunnel_interface.value.type
      protocol   = tunnel_interface.value.protocol
      port       = tunnel_interface.value.port
    }
  }
  virtual_network_id = try(var.vmss.lb.virtual_network_id, null)
}

resource "azurerm_lb_rule" "loadbalancer-lbr" {
  for_each = try(var.vmss.lb.rules, {})

  name                           = "${local.vmss_name}-${each.key}-lbr"
  loadbalancer_id                = azurerm_lb.loadbalancer[0].id
  frontend_ip_configuration_name = "${local.vmss_name}-${each.value.frontend_ip_configuration_name}-lbfe"
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.loadbalancer-lbbp[0].id]
  probe_id                       = try(each.value.probe_name, "") == "" ? null : azurerm_lb_probe.loadbalancer-lbhp["${each.value.probe_name}"].id
  enable_floating_ip             = try(each.value.enable_floating_ip, null)
  idle_timeout_in_minutes        = try(each.value.idle_timeout_in_minutes, 4)
  load_distribution              = try(each.value.load_distribution, null)
  disable_outbound_snat          = try(each.value.disable_outbound_snat, null)
  enable_tcp_reset               = try(each.value.enable_tcp_reset, null)
}
