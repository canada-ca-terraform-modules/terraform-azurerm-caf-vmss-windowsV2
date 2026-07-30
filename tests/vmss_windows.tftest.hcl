mock_provider "azurerm" {}
mock_provider "http" {}
mock_provider "null" {}
mock_provider "random" {}

variables {
  env               = "DevA"
  group             = "Test"
  project           = "Proj"
  userDefinedString = "myapp"
  location          = "canadacentral"
  tags              = {}
  resource_groups = {
    "MyRG"     = { name = "DevA-Test-Proj-MyRG-rg", id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/DevA-Test-Proj-MyRG-rg" }
    "Keyvault" = { name = "DevA-Test-Proj-Keyvault-rg", id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/DevA-Test-Proj-Keyvault-rg" }
  }
  subnets = {
    "subnet1" = { id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/net-rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet1" }
  }
}

run "naming_convention" {
  command = plan

  variables {
    vmss = {
      postfix             = "001"
      resource_group_name = "MyRG"
      sku                 = "Standard_D2s_v3"
      admin_password      = "P@55w0rd1234!"
      source_image_reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-g2"
        version   = "latest"
      }
      os_disk = {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
      }
      nic = {
        nic1 = {
          ip_configuration = {
            ipc1 = {
              subnet = "subnet1"
            }
          }
        }
      }
    }
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.vmss_windows.name == "DevASWG-myapp001-vmss"
    error_message = "VMSS name must follow {env4}{SWG}-{userDefinedString}{postfix3} convention"
  }
}

run "default_values" {
  command = plan

  variables {
    vmss = {
      postfix             = "001"
      resource_group_name = "MyRG"
      sku                 = "Standard_D2s_v3"
      admin_password      = "P@55w0rd1234!"
      source_image_reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-g2"
        version   = "latest"
      }
      os_disk = {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
      }
      nic = {
        nic1 = {
          ip_configuration = {
            ipc1 = {
              subnet = "subnet1"
            }
          }
        }
      }
    }
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.vmss_windows.instances == 0
    error_message = "Default instances must be 0"
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.vmss_windows.admin_username == "azureadmin"
    error_message = "Default admin_username must be azureadmin"
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.vmss_windows.license_type == "Windows_Server"
    error_message = "Default license_type must be Windows_Server"
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.vmss_windows.computer_name_prefix == "vmsswin-"
    error_message = "Default computer_name_prefix must be vmsswin-"
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.vmss_windows.resilient_vm_creation_enabled == null
    error_message = "resilient_vm_creation_enabled must default to null"
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.vmss_windows.resilient_vm_deletion_enabled == null
    error_message = "resilient_vm_deletion_enabled must default to null"
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.vmss_windows.encryption_at_host_enabled == true
    error_message = "encryption_at_host_enabled must default to true (secure default) when not explicitly set"
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.vmss_windows.automatic_updates_enabled == null
    error_message = "automatic_updates_enabled must default to null when not explicitly set"
  }
}

run "v5_network_interface_renamed_args" {
  command = plan

  variables {
    vmss = {
      postfix             = "001"
      resource_group_name = "MyRG"
      sku                 = "Standard_D2s_v3"
      admin_password      = "P@55w0rd1234!"
      source_image_reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-g2"
        version   = "latest"
      }
      os_disk = {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
      }
      nic = {
        nic1 = {
          # Use new v5 field names
          accelerated_networking_enabled = true
          ip_forwarding_enabled          = false
          ip_configuration = {
            ipc1 = {
              subnet = "subnet1"
            }
          }
        }
      }
    }
  }

  assert {
    condition     = one(azurerm_windows_virtual_machine_scale_set.vmss_windows.network_interface).accelerated_networking_enabled == true
    error_message = "accelerated_networking_enabled must be true"
  }
}

run "v5_legacy_network_interface_args" {
  command = plan

  variables {
    vmss = {
      postfix             = "001"
      resource_group_name = "MyRG"
      sku                 = "Standard_D2s_v3"
      admin_password      = "P@55w0rd1234!"
      source_image_reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-g2"
        version   = "latest"
      }
      os_disk = {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
      }
      nic = {
        nic1 = {
          # Use old v4 field names — must still work
          enable_accelerated_networking = true
          ip_configuration = {
            ipc1 = {
              subnet = "subnet1"
            }
          }
        }
      }
    }
  }

  assert {
    condition     = one(azurerm_windows_virtual_machine_scale_set.vmss_windows.network_interface).accelerated_networking_enabled == true
    error_message = "Old v4 enable_accelerated_networking must map to v5 accelerated_networking_enabled"
  }
}

run "v5_network_interface_new_args" {
  command = plan

  variables {
    vmss = {
      postfix             = "001"
      resource_group_name = "MyRG"
      sku                 = "Standard_D2s_v3"
      admin_password      = "P@55w0rd1234!"
      source_image_reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-g2"
        version   = "latest"
      }
      os_disk = {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
      }
      nic = {
        nic1 = {
          auxiliary_mode = "AcceleratedConnections"
          auxiliary_sku  = "A1"
          ip_configuration = {
            ipc1 = {
              subnet = "subnet1"
            }
          }
        }
      }
    }
  }

  assert {
    condition     = one(azurerm_windows_virtual_machine_scale_set.vmss_windows.network_interface).auxiliary_mode == "AcceleratedConnections"
    error_message = "auxiliary_mode must be set"
  }

  assert {
    condition     = one(azurerm_windows_virtual_machine_scale_set.vmss_windows.network_interface).auxiliary_sku == "A1"
    error_message = "auxiliary_sku must be set"
  }
}

run "v5_automatic_updates_renamed_arg" {
  command = plan

  variables {
    vmss = {
      postfix                   = "001"
      resource_group_name       = "MyRG"
      sku                       = "Standard_D2s_v3"
      admin_password            = "P@55w0rd1234!"
      automatic_updates_enabled = false
      source_image_reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-g2"
        version   = "latest"
      }
      os_disk = {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
      }
      nic = {
        nic1 = {
          ip_configuration = {
            ipc1 = {
              subnet = "subnet1"
            }
          }
        }
      }
    }
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.vmss_windows.automatic_updates_enabled == false
    error_message = "automatic_updates_enabled must be false"
  }
}

run "v5_legacy_automatic_updates_arg" {
  command = plan

  variables {
    vmss = {
      postfix                  = "001"
      resource_group_name      = "MyRG"
      sku                      = "Standard_D2s_v3"
      admin_password           = "P@55w0rd1234!"
      enable_automatic_updates = false
      source_image_reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-g2"
        version   = "latest"
      }
      os_disk = {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
      }
      nic = {
        nic1 = {
          ip_configuration = {
            ipc1 = {
              subnet = "subnet1"
            }
          }
        }
      }
    }
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.vmss_windows.automatic_updates_enabled == false
    error_message = "Old v4 enable_automatic_updates must map to v5 automatic_updates_enabled"
  }
}

run "v5_resilient_args" {
  command = plan

  variables {
    vmss = {
      postfix                       = "001"
      resource_group_name           = "MyRG"
      sku                           = "Standard_D2s_v3"
      admin_password                = "P@55w0rd1234!"
      resilient_vm_creation_enabled = true
      resilient_vm_deletion_enabled = true
      source_image_reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-g2"
        version   = "latest"
      }
      os_disk = {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
      }
      nic = {
        nic1 = {
          ip_configuration = {
            ipc1 = {
              subnet = "subnet1"
            }
          }
        }
      }
    }
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.vmss_windows.resilient_vm_creation_enabled == true
    error_message = "resilient_vm_creation_enabled must be true"
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.vmss_windows.resilient_vm_deletion_enabled == true
    error_message = "resilient_vm_deletion_enabled must be true"
  }
}

run "v5_automatic_os_upgrade_policy_renamed_args" {
  command = plan

  variables {
    vmss = {
      postfix             = "001"
      resource_group_name = "MyRG"
      sku                 = "Standard_D2s_v3"
      admin_password      = "P@55w0rd1234!"
      upgrade_mode        = "Automatic"
      automatic_os_upgrade_policy = {
        policy1 = {
          automatic_rollback_enabled   = false
          automatic_os_upgrade_enabled = true
        }
      }
      source_image_reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-g2"
        version   = "latest"
      }
      os_disk = {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
      }
      nic = {
        nic1 = {
          ip_configuration = {
            ipc1 = {
              subnet = "subnet1"
            }
          }
        }
      }
    }
  }

  assert {
    condition     = one(azurerm_windows_virtual_machine_scale_set.vmss_windows.automatic_os_upgrade_policy).automatic_rollback_enabled == false
    error_message = "automatic_rollback_enabled must be false"
  }

  assert {
    condition     = one(azurerm_windows_virtual_machine_scale_set.vmss_windows.automatic_os_upgrade_policy).automatic_os_upgrade_enabled == true
    error_message = "automatic_os_upgrade_enabled must be true"
  }
}

run "v5_legacy_automatic_os_upgrade_policy_args" {
  command = plan

  variables {
    vmss = {
      postfix             = "001"
      resource_group_name = "MyRG"
      sku                 = "Standard_D2s_v3"
      admin_password      = "P@55w0rd1234!"
      upgrade_mode        = "Automatic"
      automatic_os_upgrade_policy = {
        policy1 = {
          # v4 field names — must still work
          disable_automatic_rollback  = false
          enable_automatic_os_upgrade = true
        }
      }
      source_image_reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-g2"
        version   = "latest"
      }
      os_disk = {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
      }
      nic = {
        nic1 = {
          ip_configuration = {
            ipc1 = {
              subnet = "subnet1"
            }
          }
        }
      }
    }
  }

  assert {
    condition     = one(azurerm_windows_virtual_machine_scale_set.vmss_windows.automatic_os_upgrade_policy).automatic_rollback_enabled == true
    error_message = "Old v4 disable_automatic_rollback=false must map to v5 automatic_rollback_enabled=true"
  }

  assert {
    condition     = one(azurerm_windows_virtual_machine_scale_set.vmss_windows.automatic_os_upgrade_policy).automatic_os_upgrade_enabled == true
    error_message = "Old v4 enable_automatic_os_upgrade must map to v5 automatic_os_upgrade_enabled"
  }
}

run "v5_automatic_instance_repair_action" {
  command = plan

  variables {
    vmss = {
      postfix             = "001"
      resource_group_name = "MyRG"
      sku                 = "Standard_D2s_v3"
      admin_password      = "P@55w0rd1234!"
      health_probe_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/net-rg/providers/Microsoft.Network/loadBalancers/lb/probes/probe1"
      automatic_instance_repair = {
        repair1 = {
          enabled = true
          action  = "Replace"
        }
      }
      source_image_reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-g2"
        version   = "latest"
      }
      os_disk = {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
      }
      nic = {
        nic1 = {
          ip_configuration = {
            ipc1 = {
              subnet = "subnet1"
            }
          }
        }
      }
    }
  }

  assert {
    condition     = one(azurerm_windows_virtual_machine_scale_set.vmss_windows.automatic_instance_repair).action == "Replace"
    error_message = "automatic_instance_repair.action must be Replace"
  }
}

run "v5_data_disk_renamed_args" {
  command = plan

  variables {
    vmss = {
      postfix             = "001"
      resource_group_name = "MyRG"
      sku                 = "Standard_D2s_v3"
      admin_password      = "P@55w0rd1234!"
      source_image_reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-g2"
        version   = "latest"
      }
      os_disk = {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
      }
      data_disk = {
        disk1 = {
          lun                  = 0
          storage_account_type = "UltraSSD_LRS"
          disk_iops_read_write = 125
          disk_mbps_read_write = 25
        }
      }
      nic = {
        nic1 = {
          ip_configuration = {
            ipc1 = {
              subnet = "subnet1"
            }
          }
        }
      }
    }
  }

  assert {
    condition     = one(azurerm_windows_virtual_machine_scale_set.vmss_windows.data_disk).disk_iops_read_write == 125
    error_message = "disk_iops_read_write must be 125"
  }

  assert {
    condition     = one(azurerm_windows_virtual_machine_scale_set.vmss_windows.data_disk).disk_mbps_read_write == 25
    error_message = "disk_mbps_read_write must be 25"
  }
}

run "v5_legacy_data_disk_args" {
  command = plan

  variables {
    vmss = {
      postfix             = "001"
      resource_group_name = "MyRG"
      sku                 = "Standard_D2s_v3"
      admin_password      = "P@55w0rd1234!"
      source_image_reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-g2"
        version   = "latest"
      }
      os_disk = {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
      }
      data_disk = {
        disk1 = {
          lun                  = 0
          storage_account_type = "UltraSSD_LRS"
          # v4 field names — must still work
          ultra_ssd_disk_iops_read_write = 125
          ultra_ssd_disk_mbps_read_write = 25
        }
      }
      nic = {
        nic1 = {
          ip_configuration = {
            ipc1 = {
              subnet = "subnet1"
            }
          }
        }
      }
    }
  }

  assert {
    condition     = one(azurerm_windows_virtual_machine_scale_set.vmss_windows.data_disk).disk_iops_read_write == 125
    error_message = "Old v4 ultra_ssd_disk_iops_read_write must map to v5 disk_iops_read_write"
  }

  assert {
    condition     = one(azurerm_windows_virtual_machine_scale_set.vmss_windows.data_disk).disk_mbps_read_write == 25
    error_message = "Old v4 ultra_ssd_disk_mbps_read_write must map to v5 disk_mbps_read_write"
  }
}

run "scale_in_args" {
  command = plan

  variables {
    vmss = {
      postfix             = "001"
      resource_group_name = "MyRG"
      sku                 = "Standard_D2s_v3"
      admin_password      = "P@55w0rd1234!"
      scale_in = {
        rule                   = "OldestVM"
        force_deletion_enabled = true
      }
      source_image_reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-g2"
        version   = "latest"
      }
      os_disk = {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
      }
      nic = {
        nic1 = {
          ip_configuration = {
            ipc1 = {
              subnet = "subnet1"
            }
          }
        }
      }
    }
  }

  assert {
    condition     = one(azurerm_windows_virtual_machine_scale_set.vmss_windows.scale_in).rule == "OldestVM"
    error_message = "scale_in.rule must be OldestVM (bug fix: was previously always null)"
  }

  assert {
    condition     = one(azurerm_windows_virtual_machine_scale_set.vmss_windows.scale_in).force_deletion_enabled == true
    error_message = "scale_in.force_deletion_enabled must be true (bug fix: was previously always null)"
  }
}
