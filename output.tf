output "vmss_windows" {
  value = azurerm_windows_virtual_machine_scale_set.vmss_windows
  description = "VMSS Windows object"
}

output "loadbalancer" {
  value = azurerm_lb.loadbalancer
  description = "Load Balancer object"
}