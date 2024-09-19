locals {
  vmss_windows_regex           = "/[//\"'\\[\\]:|<>+=;,?*@&]/" # Can't include those characters in windows_virtual_machine name: \/"'[]:|<>+=;,?*@&
  env_4                = substr(var.env, 0, 4)
  serverType_3         = "SWG"
  postfix_3            = substr(var.vmss.postfix, 0, 3)
  userDefinedString_54 = substr(var.userDefinedString, 0, 54 - length(local.postfix_3))
  vmss_name            = try(var.vmss.custom_name, replace("${local.env_4}${local.serverType_3}-${local.userDefinedString_54}${local.postfix_3}", local.vmss_windows_regex, ""))
}