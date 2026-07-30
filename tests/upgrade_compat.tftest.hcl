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

# Step 1: simulate currently-deployed resource with pre-upgrade (v4) field names
run "baseline_apply" {
  command = apply

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
          # v4 field names
          enable_accelerated_networking = false
          enable_ip_forwarding          = false
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
    error_message = "Baseline apply: unexpected resource name"
  }
}

# Step 2: plan upgraded config (v5 new args) against baseline state — must produce no replacement
run "upgrade_plan_no_replacement" {
  command = plan

  variables {
    vmss = {
      postfix                       = "001"
      resource_group_name           = "MyRG"
      sku                           = "Standard_D2s_v3"
      admin_password                = "P@55w0rd1234!"
      resilient_vm_creation_enabled = false
      resilient_vm_deletion_enabled = false
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
          # v5 new field names
          accelerated_networking_enabled = false
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
    condition     = azurerm_windows_virtual_machine_scale_set.vmss_windows.name == "DevASWG-myapp001-vmss"
    error_message = "Upgrade plan: resource name must not change"
  }
}
