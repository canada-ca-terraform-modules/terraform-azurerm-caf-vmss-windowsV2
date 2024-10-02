output "vmss_windows" {
  value       = azurerm_windows_virtual_machine_scale_set.vmss_windows
  description = "VMSS Windows object"
}

output "loaddbalancer" {
  description = "The availability_set object"
  value       = module.load_balancer
}