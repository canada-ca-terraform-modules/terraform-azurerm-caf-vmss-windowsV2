locals {
  # If resource_group was an ID, then parse the ID for the name, if not, then search in the provided resource_groups object
  resource_group_name = strcontains(var.vmss.resource_group_name, "/resourceGroups/") ? regex("[^\\/]+$", var.vmss.resource_group_name) :  var.resource_groups[var.vmss.resource_group_name].name

  # Use TF generated passwor IF: RBAC authorization is supported on the target KV AND password_overwrite is set to false AND disabled_password_authentication is set to false
  # Use user provided password IF: RBAC authorization is NOT supported on the target KV OR password_overwrite is set to true AND disable_password_authentication is set to false
  # If disable_password_authentication is set to true, then no password is set. In this case, a ssh key is required. 
  vm-admin-password = try(var.vmss.admin_password, "") == "" ? random_password.vm-admin-password[0].result : var.vmss.admin_password
  
  # This list is used to organize the nics given to the module, used to determine which NIC will be the primary one. (At index 0)
  nic_indices = {for k, v in var.vmss.nic : k => index(keys(var.vmss.nic), k)}
}