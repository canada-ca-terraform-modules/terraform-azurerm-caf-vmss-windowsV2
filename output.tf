output "vmss_windows" {
  value = azurerm_windows_virtual_machine_scale_set.vmss_windows
}

output "loadbalancer" {
  value = azurerm_lb.loadbalancer
}