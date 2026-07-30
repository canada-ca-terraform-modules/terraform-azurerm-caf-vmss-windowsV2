locals {
  # If resource_group was an ID, then parse the ID for the name, if not, then search in the provided resource_groups object
  resource_group_name = strcontains(var.vmss.resource_group_name, "/resourceGroups/") ? regex("[^/]+$", var.vmss.resource_group_name) : var.resource_groups[var.vmss.resource_group_name].name

  # Use TF generated password IF: no admin_password is provided by the caller.
  # Use user provided password IF: admin_password is explicitly set.
  vm-admin-password = try(var.vmss.admin_password, "") == "" ? random_password.vm-admin-password[0].result : var.vmss.admin_password
}
