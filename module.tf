resource "azurerm_windows_virtual_machine_scale_set" "vmss_windows" {
  name                                              = "${local.vmss_name}-vmss"
  location                                          = var.location
  resource_group_name                               = local.resource_group_name
  admin_username                                    = try(var.vmss.admin_username, "azureadmin")
  admin_password                                    = local.vm-admin-password
  instances                                         = try(var.vmss.instances, 0)
  capacity_reservation_group_id                     = try(var.vmss.capacity_reservation_group_id, null)
  computer_name_prefix                              = try(var.vmss.computer_name_prefix, "vmsswin-")
  custom_data                                       = var.custom_data
  do_not_run_extensions_on_overprovisioned_machines = try(var.vmss.do_not_run_extensions_on_overprovisioned_machines, false)
  edge_zone                                         = try(var.vmss.edge_zone, null)
  enable_automatic_updates                          = try(var.vmss.enable_automatic_updates, null)
  encryption_at_host_enabled                        = try(var.vmss.encryption_at_host_enabled, false)
  extension_operations_enabled                      = try(var.vmss.extension_operations_enabled, null)
  extensions_time_budget                            = try(var.vmss.extensions_time_budget, null)
  eviction_policy                                   = try(var.vmss.eviction_policy, null)
  health_probe_id                                   = try(var.vmss.health_probe_id, null)
  host_group_id                                     = try(var.vmss.host_group_id, null)
  license_type                                      = try(var.vmss.license_type, null)
  max_bid_price                                     = try(var.vmss.max_bid_price, null)
  overprovision                                     = try(var.vmss.overprovision, null)
  platform_fault_domain_count                       = try(var.vmss.platform_fault_domain_count, null)
  priority                                          = try(var.vmss.priority, null)
  provision_vm_agent                                = try(var.vmss.provision_vm_agent, null)
  proximity_placement_group_id                      = try(var.vmss.proximity_placement_group_id, null)
  secure_boot_enabled                               = try(var.vmss.secure_boot_enabled, null)
  single_placement_group                            = try(var.vmss.single_placement_group, null)
  sku                                               = var.vmss.sku
  source_image_id                                   = try(var.vmss.source_image_id, null)
  timezone                                          = try(var.vmss.timezone, null)
  tags                                              = merge(var.tags, try(var.vmss.tags, {}))
  upgrade_mode                                      = try(var.vmss.upgrade_mode, null)
  user_data                                         = var.user_data
  vtpm_enabled                                      = try(var.vmss.vtpm_enabled, null)
  zone_balance                                      = try(var.vmss.zone_balance, null)
  zones                                             = try(var.vmss.zones, null)

  dynamic "additional_capabilities" {
    for_each = try(var.vmss.additional_capabilities, null) != null ? [1] : []
    content {
      ultra_ssd_enabled = try(var.vmss.additional_capabilities.ultra_ssd_enabled, false)
    }
  }

  dynamic "additional_unattend_content" {
    for_each = try(var.vmss.additional_unattend_content, {})
    content {
      content = additional_unattend_content.value.content
      setting = additional_unattend_content.value.setting
    }
  }

  dynamic "automatic_os_upgrade_policy" {
    for_each = try(var.vmss.automatic_os_upgrade_policy, {})
    content {
      disable_automatic_rollback  = try(automatic_os_upgrade_policy.value.disable_automatic_rollback, null)
      enable_automatic_os_upgrade = try(automatic_os_upgrade_policy.value.enable_automatic_os_upgrade, null)
    }
  }

  dynamic "automatic_instance_repair" {
    for_each = try(var.vmss.automatic_instance_repair, {})
    content {
      enabled      = try(automatic_instance_repair.value.enabled, null)
      grace_period = try(automatic_instance_repair.value.grace_period, null)
    }
  }

  dynamic "boot_diagnostics" {
    for_each = try(var.vmss.boot_diagnostic, false) != false ? [1] : []
    content {
      storage_account_uri = try(var.vmss.boot_diagnostic.use_managed_storage_account, true) ? null : module.boot_diagnostic_storage[0].storage-account-object.primary_blob_endpoint
    }
  }

  dynamic "data_disk" {
    for_each = try(var.vmss.data_disk, {})
    content {
      name                           = "${local.vmss_name}-datadisk${each.value.lun + 1}"
      caching                        = try(data_disk.value.caching, "ReadWrite")
      create_option                  = try(data_disk.value.create_option, "Empty")
      disk_size_gb                   = try(data_disk.value.disk_size_gb, 256)
      disk_encryption_set_id         = try(data_disk.value.disk_encryption_set_id, null)
      lun                            = data_disk.value.lun
      storage_account_type           = try(data_disk.value.storage_account_type, "Standard_LRS")
      ultra_ssd_disk_iops_read_write = try(data_disk.value.ultra_ssd_disk_iops_read_write, null)
      ultra_ssd_disk_mbps_read_write = try(data_disk.value.ultra_ssd_disk_mbps_read_write, null)
      write_accelerator_enabled      = try(data_disk.value.write_accelerator_enabled, false)
    }
  }
  dynamic "extension" {
    for_each = try(var.vmss.extension, {})
    content {
      name                       = extension.key
      publisher                  = extension.value.publisher
      type                       = extension.value.type
      type_handler_version       = extension.value.type_handler_version
      auto_upgrade_minor_version = try(extension.value.auto_upgrade_minor_version, true)
      automatic_upgrade_enabled  = try(extension.value.automatic_upgrade_enabled, true)
      force_update_tag           = try(extension.value.force_update_tag, null)
      protected_settings         = try(extension.value.protected_settings, null)
      dynamic "protected_settings_from_key_vault" {
        for_each = try(extension.value.protected_settings_from_key_vault, {})
        content {
          secret_url      = protected_settings_from_key_vault.value.secret_url
          source_vault_id = rotected_settings_from_key_vault.value.source_vault_id
        }
      }
      provision_after_extensions = try(extension.value.provision_after_extensions, null)
      settings                   = try(extension.value.settings, null)
    }
  }

  dynamic "gallery_application" {
    for_each = try(var.vmss.gallery_application, {})
    content {
      version_id             = gallery_application.value.version_id
      configuration_blob_uri = try(gallery_application.value.configuration_blob_uri, null)
      order                  = try(gallery_application.value.order, null)
      tag                    = try(gallery_application.value.tag, null)
    }
  }

  # If boot diagnostic is enabled, then the VM needs a SystemAssigned identity, other acts like all other dynamic blocks
  dynamic "identity" {
    for_each = try(var.vmss.identity, null) != null || try(var.vmss.boot_diagnostic, false) == true ? [1] : []
    content {
      type         = try(var.vmss.identity.type, "SystemAssigned")
      identity_ids = try(var.vmss.identity.type, "SystemAssigned") == "UserAssigned" ? try(var.vmss.identity.identity_ids, [azurerm_user_assigned_identity.user_assigned_identity_vmss_windows[0].id]) : []
    }
  }

  dynamic "network_interface" {
    for_each = var.vmss.nic
    content {
      name                          = "${local.vmss_name}-${network_interface.key}"
      dns_servers                   = try(network_interface.value.dns_servers, null)
      enable_accelerated_networking = try(network_interface.value.enable_accelerated_networking, false)
      enable_ip_forwarding          = try(network_interface.value.enable_ip_forwarding, false)
      primary                       = try(network_interface.value.primary, true)

      dynamic "ip_configuration" {
        for_each = var.vmss.nic[network_interface.key].ip_configuration
        content {
          name                                         = "${local.vmss_name}-ipconfig-${ip_configuration.key}"
          primary                                      = try(ip_configuration.value.primary, true)
          subnet_id                                    = strcontains(ip_configuration.value.subnet, "/resourceGroups/") ? ip_configuration.value.subnet : var.subnets[ip_configuration.value.subnet].id
          application_gateway_backend_address_pool_ids = try(ip_configuration.value.application_gateway_backend_address_pool_ids, [])
          application_security_group_ids               = try(ip_configuration.value.application_security_group_ids, [])
          load_balancer_backend_address_pool_ids       = try(var.vmss.lb, null) != null ? [module.load_balancer[0].loadbalancer_backend_address_pool.id] : []
          load_balancer_inbound_nat_rules_ids          = try(ip_configuration.value.load_balancer_inbound_nat_rules_ids, [])
          dynamic "public_ip_address" {
            for_each = try(ip_configuration.value.public_ip_address, null) != null ? [1] : []
            content {
              name                    = "${local.vmss_name}-pip-${ip_configuration.key}"
              domain_name_label       = try(public_ip_address.value.domain_name_label, null)
              idle_timeout_in_minutes = try(public_ip_address.value.idle_timeout_in_minutes, null)
              dynamic "ip_tag" {
                for_each = try(public_ip_address.value.ip_tags, {})
                content {
                  tag  = ip_tags.value.tag
                  type = ip_tags.value.type
                }
              }
              public_ip_prefix_id = try(public_ip_address.value.public_ip_prefix_id, null)
              version             = try(public_ip_address.value.version, null)
            }

          }
          version = try(ip_configuration.value.version, null)
        }
      }
    }
  }

  os_disk {
    caching              = try(var.vmss.os_disk.caching, "ReadWrite")
    storage_account_type = try(var.vmss.os_disk.storage_account_type, "Standard_LRS")
    dynamic "diff_disk_settings" {
      for_each = try(var.vmss.os_disk.diff_disk_settings, {})
      content {
        option    = try(diff_disk_settings.value.option, "Local")
        placement = try(diff_disk_settings.value.placement, "CacheDisk")
      }
    }
    disk_encryption_set_id           = try(var.vmss.os_disk.disk_encryption_set_id, null)
    disk_size_gb                     = try(var.vmss.os_disk.disk_size_gb, null)
    secure_vm_disk_encryption_set_id = try(var.vmss.os_disk.secure_vm_disk_encryption_set_id, null)
    security_encryption_type         = try(var.vmss.os_disk.security_encryption_type, null)
    write_accelerator_enabled        = try(var.vmss.os_disk.write_accelerator_enabled, false)
  }

  dynamic "plan" {
    for_each = try(var.vmss.plan, {})
    content {
      name      = plan.value.name
      product   = plan.value.product
      publisher = plan.value.publisher
    }
  }

  dynamic "rolling_upgrade_policy" {
    for_each = try(var.vmss.rolling_upgrade_policy, {})
    content {
      cross_zone_upgrades_enabled             = try(rolling_upgrade_policy.value.cross_zone_upgrades_enabled, null)
      max_batch_instance_percent              = try(rolling_upgrade_policy.value.max_batch_instance_percent, null)
      max_unhealthy_instance_percent          = try(rolling_upgrade_policy.value.max_unhealthy_instance_percent, null)
      max_unhealthy_upgraded_instance_percent = try(rolling_upgrade_policy.value.max_unhealthy_upgraded_instance_percent, null)
      pause_time_between_batches              = try(rolling_upgrade_policy.value.pause_time_between_batches, null)
      prioritize_unhealthy_instances_enabled  = try(rolling_upgrade_policy.value.prioritize_unhealthy_instances_enabled, null)
      maximum_surge_instances_enabled         = try(rolling_upgrade_policy.value.maximum_surge_instances_enabled, null)
    }
  }

  dynamic "scale_in" {
    for_each = try(var.vmss.scale_in, false) != false ? [1] : []
    content {
      rule                   = try(scale_in.value.rule, null)
      force_deletion_enabled = try(scale_in.value.force_deletion_enabled, null)
    }
  }

  dynamic "secret" {
    for_each = try(var.vmss.secret, {})
    content {
      dynamic "certificate" {
        for_each = try(secret.value.certificate, {})
        content {
          store = certificate.value.store
          url   = certificate.value.url
        }
      }
      key_vault_id = secret.value.key_vault_id
    }
  }

  source_image_reference {
    publisher = var.vmss.source_image_reference.publisher
    offer     = var.vmss.source_image_reference.offer
    sku       = var.vmss.source_image_reference.sku
    version   = var.vmss.source_image_reference.version
  }

  dynamic "spot_restore" {
    for_each = try(var.vmss.spot_restore, {})
    content {
      enabled = try(spot_restore.value.enabled, null)
      timeout = try(spot_restore.value.timeout, null)
    }
  }

  dynamic "termination_notification" {
    for_each = try(var.vmss.termination_notification, {})
    content {
      enabled = termination_notification.value.enabled
      timeout = try(termination_notification.value.timeout, null)
    }
  }

  dynamic "winrm_listener" {
    for_each = try(var.vmss.winrm_listener, {})
    content {
      protocol        = winrm_listener.value.protocol
      certificate_url = try(winrm_listener.value.certificate_url, null)
    }
  }

  lifecycle {
    ignore_changes = [tags, instances] # ignore changes made to tags by App Services
  }
}
