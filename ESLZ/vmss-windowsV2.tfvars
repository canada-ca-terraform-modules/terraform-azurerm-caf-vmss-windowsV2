vmss_windowsV2 = {
  devops = {
    # custom_name = "some-custom-name" # Optional. ONLY use if you really really really don't want to use the auto generated name
    userDefinedString    = "devops" # Max 55 chars
    postfix              = "01"
    computer_name_prefix = "vmsswin-" # (Optional) The prefix which should be used for the name of the Virtual Machines in this Scale Set. Default: "vmsswin-"
    resource_group_name  = "Management"

    admin_username = "azureadmin"
    # admin_password = "Canada123!" # Optional: Only set the password if a generated password cannot be created. See README for details

    # Optional: Uncomment this if you want to enable boot diagnostics for VMSS VMs
    boot_diagnostic = {                  # (Optional) Enable Boot Diagnostics for the VMSS? Default to false
      use_managed_storage_account = true # (Optional) Should the Boot Diagnostics use a Managed Disk instead of a storageaccount? Default to true
      storage_account_resource_id = ""   # (Optional) The resource ID of the Storage Account to use for Boot Diagnostics. Default: Create storage account for vmss boot diagnostic and serial console.
    }

    instances = 0 # (Optional) The number of Virtual Machines in the Scale Set. Defaults to 0.

    # At least one nic is required. If more than one is present, the first nic in the list will be the primary one.
    nic = {
      nic1 = {
        ip_configuration = {
          ipc1 = {
            primary = true  # (Optional) Is this IP Configuration the primary one? Default to true
            subnet  = "MAZ" # (Required) The name or the resource id of the Subnet which should be used for this IP Configuration
            # application_gateway_backend_address_pool_ids = [] # (Optional) A list of Backend Address Pools ID's from a Application Gateway which this Virtual Machine Scale Set should be connected to.
            # application_security_group_ids               = [] # (Optional) A list of Application Security Group ID's which this Virtual Machine Scale Set should be connected to.

            # (Optional) A public_ip_address block as defined below.
            # public_ip_address = {
            #   domain_name_label       = "" #(Optional) The Prefix which should be used for the Domain Name Label for each Virtual Machine Instance. Azure concatenates the Domain Name Label and Virtual Machine Index to create a unique Domain Name Label for each Virtual Machine.
            #   idle_timeout_in_minutes = 4  # (Optional) The Idle Timeout in Minutes for the Public IP Address. Possible values are in the range 4 to 32.

            #   # (Optional) One or more ip_tag blocks as defined above. Changing this forces a new resource to be created.
            #   # ip_tag = {
            #   #   it1 = {
            #   #     tag  = "SQL"             # (Required) The IP Tag associated with the Public IP, such as SQL or Storage. Changing this forces a new resource to be created.
            #   #     type = "FirstPartyUsage" # (Required) The Type of IP Tag, such as FirstPartyUsage. Changing this forces a new resource to be created.
            #   #   }
            #   # }

            #   public_ip_prefix_id = ""     # (Optional) The ID of the Public IP Address Prefix from where Public IP Addresses should be allocated. Changing this forces a new resource to be created.
            #   version             = "IPv4" # (Optional) The Internet Protocol Version which should be used for this public IP address. Possible values are IPv4 and IPv6. Defaults to IPv4. Changing this forces a new resource to be created.
            # }

            version = "IPv4" # (Optional) The IP Version to use. Possible values are "IPv4" and "IPv6". Default to "IPv4"
          }
        }
        # dns_servers                   = ["1.1.1.1"] # (Optional) A list of IP Addresses of DNS Servers which should be assigned to the Network Interface.
        enable_accelerated_networking = false # (Optional) Enable Accelerated Networking? Default to false
        enable_ip_forwarding          = false # (Optional) Enable IP Forwarding? Default to false
        primary                       = true  # (Optional) Is this Network Interface the primary one? Default to true
      }
    }

    # Only one OS disk is accepted. Default size is 128Gb. 
    os_disk = {
      storage_account_type = "StandardSSD_LRS" # (Required) The Type of Storage Account which should back this the Internal OS Disk. Possible values include Standard_LRS, StandardSSD_LRS, StandardSSD_ZRS, Premium_LRS and Premium_ZRS. Changing this forces a new resource to be created.
      caching              = "ReadWrite"       # (Required) The Type of Caching which should be used for the Internal OS Disk. Possible values are None, ReadOnly and ReadWrite.
      # (Optional) The following diff_disk_settings block is optional. Uncomment and configure to use it to specify the diff disk settings
      # diff_disk_settings = {
      #   dds1 = {
      #     option    = "Local"     #  (Required) Specifies the Ephemeral Disk Settings for the OS Disk. At this time the only possible value is Local. Changing this forces a new resource to be created.
      #     placement = "CacheDisk" # (Optional) Specifies where to store the Ephemeral Disk. Possible values are CacheDisk and ResourceDisk. Defaults to CacheDisk. Changing this forces a new resource to be created.
      #   }
      # }
      # disk_encryption_set_id           = ""                 # (Optional) The ID of the Disk Encryption Set which should be used to encrypt this OS Disk. Conflicts with secure_vm_disk_encryption_set_id. Changing this forces a new resource to be created.
      disk_size_gb = 256 # (Optional) The Size of the Internal OS Disk in GB, if you wish to vary from the size used in the image this Virtual Machine Scale Set is sourced from.
      # secure_vm_disk_encryption_set_id = ""                 # (Optional) The ID of the Disk Encryption Set which should be used to Encrypt the OS Disk when the Virtual Machine Scale Set is Confidential VMSS. Conflicts with disk_encryption_set_id. Changing this forces a new resource to be created.
      # security_encryption_type         = "VMGuestStateOnly" # (Optional) Encryption Type when the Virtual Machine Scale Set is Confidential VMSS. Possible values are VMGuestStateOnly and DiskWithVMGuestState. Changing this forces a new resource to be created.
      # write_accelerator_enabled        = false              # (Optional) Should Write Accelerator be Enabled for this OS Disk? Defaults to false.
    }

    sku = "Standard_D2s_v3" # (Required) The Virtual Machine SKU for the Scale Set, such as Standard_F2.

    source_image_reference = {
      publisher = "MicrosoftWindowsServer" # (Required) Specifies the publisher of the image used to create the virtual machines. Changing this forces a new resource to be created.
      offer     = "WindowsServer"          # (Required) Specifies the offer of the image used to create the virtual machines. Changing this forces a new resource to be created.
      sku       = "2022-datacenter-g2"     # (Required) Specifies the SKU of the image used to create the virtual machines.
      version   = "latest"                 # (Required) Specifies the version of the image used to create the virtual machines.
    }

    # Optional: Uncomment and configure the next block to use it to configure a LB in front of the VMSS
    # lb = {
    #   #
    #   # azurerm_lb section
    #   #
    #   # edge_zone = "" # (Optional) Specifies the Edge Zone within the Azure Region where this Load Balancer should exist. Changing this forces a new Load Balancer to be created.

    #   frontend_ip_configuration = {
    #     feipc1 = {
    #       subnet                                             = "MAZ"         # (Required) The name or the resource id of the Subnet which should be used for this IP Configuration
    #       # private_ip_address                                 = "10.10.10.10" # (Optional) Private IP Address to assign to the Load Balancer. The last one and first four IPs in any range are reserved and cannot be manually assigned.
    #       private_ip_address_allocation                      = "Dynamic"     # (Optional) The allocation method for the Private IP Address used by this Load Balancer. Possible values as Dynamic and Static.
    #       # private_ip_address_version                         = "IPv4"        # (Optional) The version of IP that the Private IP Address is. Possible values are IPv4 or IPv6.
    #       # public_ip_address_id                               = ""            # (Optional) The ID of a Public IP Address which should be associated with the Load Balancer.
    #       # public_ip_prefix_id                                = ""            # (Optional) The ID of a Public IP Prefix which should be associated with the Load Balancer. Public IP Prefix can only be used with outbound rules.
    #       # zones                                              = [""]          # (Optional) Specifies a list of Availability Zones in which the IP Address for this Load Balancer should be located.
    #       # gateway_load_balancer_frontend_ip_configuration_id = ""            # (Optional) The Frontend IP Configuration ID of a Gateway SKU Load Balancer.
    #       # Optional: Uncomment the following tag block if you want to add custom tags to the VMSS
    #       # tags = {
    #       #   some = "a"
    #       #   new  = "b"
    #       #   tag  = "c"
    #       # }
    #     }
    #   }

    #   # sku      = "Standard" # Optional. Default to Standard
    #   # sku_tier = "Regional" # (Optional) sku_tier - (Optional) The SKU tier of this Load Balancer. Possible values are Global and Regional. Defaults to Regional. Changing this forces a new resource to be created.

    #   #
    #   # azurerm_lb_backend_address_pool section
    #   #
    #   # synchronous_mode = "Automatic" # (Optional) The backend address synchronous mode for the Backend Address Pool. Possible values are Automatic and Manual. This is required with virtual_network_id. Changing this forces a new resource to be created.
    #   # tunnel_interface = {
    #   #   ti1 = {
    #   #     identifier = ""     # (Required) The unique identifier of this Gateway Load Balancer Tunnel Interface.
    #   #     type       = "None" # (Required) The traffic type of this Gateway Load Balancer Tunnel Interface. Possible values are None, Internal and External.
    #   #     protocol   = "None" # (Required) The protocol used for this Gateway Load Balancer Tunnel Interface. Possible values are None, Native and VXLAN.
    #   #     port       = 2345   # (Required) The port number that this Gateway Load Balancer Tunnel Interface listens to.
    #   #   }
    #   # }
    #   # virtual_network_id = "" # (Optional) The ID of the Virtual Network within which the Backend Address Pool should exist.

    #   #
    #   # azurerm_lb_probe section
    #   #
    #   probes = {
    #     tcp443 = {
    #       protocol        = "Tcp" # (Optional) Specifies the protocol of the end point. Possible values are Http, Https or Tcp. If TCP is specified, a received ACK is required for the probe to be successful. If HTTP is specified, a 200 OK response from the specified URI is required for the probe to be successful. Defaults to Tcp.
    #       port            = 443   # (Required) Port on which the Probe queries the backend endpoint. Possible values range from 1 to 65535, inclusive.
    #       probe_threshold = 1     # (Optional) The number of consecutive successful or failed probes that allow or deny traffic to this endpoint. Possible values range from 1 to 100. The default value is 1.
    #       # request_path        = ""    # (Optional) The URI used for requesting health status from the backend endpoint. Required if protocol is set to Http or Https. Otherwise, it is not allowed.
    #       # interval_in_seconds = 15    # (Optional) The interval, in seconds between probes to the backend endpoint for health status. The default value is 15, the minimum value is 5.
    #     }
    #     tcp80 = {
    #       protocol        = "Tcp" # (Optional) Specifies the protocol of the end point. Possible values are Http, Https or Tcp. If TCP is specified, a received ACK is required for the probe to be successful. If HTTP is specified, a 200 OK response from the specified URI is required for the probe to be successful. Defaults to Tcp.
    #       port            = 80   # (Required) Port on which the Probe queries the backend endpoint. Possible values range from 1 to 65535, inclusive.
    #       probe_threshold = 1     # (Optional) The number of consecutive successful or failed probes that allow or deny traffic to this endpoint. Possible values range from 1 to 100. The default value is 1.
    #       # request_path        = ""    # (Optional) The URI used for requesting health status from the backend endpoint. Required if protocol is set to Http or Https. Otherwise, it is not allowed.
    #       # interval_in_seconds = 15    # (Optional) The interval, in seconds between probes to the backend endpoint for health status. The default value is 15, the minimum value is 5.
    #     }
    #   }

    #   #
    #   # azurerm_lb_rule section
    #   #
    #   rules = {
    #     tcp443 = {
    #       protocol                       = "Tcp"    # (Required) The transport protocol for the external endpoint. Possible values are Tcp, Udp or All.
    #       frontend_port                  = 443      # (Required) The port for the external endpoint. Port numbers for each Rule must be unique within the Load Balancer. Possible values range between 0 and 65534, inclusive. A port of 0 means "Any Port".
    #       backend_port                   = 443      # (Required) The port used for internal connections on the endpoint. Possible values range between 0 and 65535, inclusive. A port of 0 means "Any Port".
    #       probe_name                     = "tcp443" # (Optional) The name of a Probe defined above
    #       enable_floating_ip             = true     # (Optional) Are the Floating IPs enabled for this Load Balancer Rule? A "floating” IP is reassigned to a secondary server in case the primary server fails. Required to configure a SQL AlwaysOn Availability Group. Defaults to false.
    #       frontend_ip_configuration_name = "feipc1" # (Requires) The name of the Frontend IP Configuration to associate with the Load Balancer Rule.
    #       # idle_timeout_in_minutes        = 4                  # (Optional) Specifies the idle timeout in minutes for TCP connections. Valid values are between 4 and 100 minutes. Defaults to 4 minutes.
    #       load_distribution = "SourceIPProtocol" #(Optional) Specifies the load balancing distribution type to be used by the Load Balancer. Possible values are: Default – The load balancer is configured to use a 5 tuple hash to map traffic to available servers. SourceIP – The load balancer is configured to use a 2 tuple hash to map traffic to available servers. SourceIPProtocol – The load balancer is configured to use a 3 tuple hash to map traffic to available servers. Also known as Session Persistence, where in the Azure portal the options are called None, Client IP and Client IP and Protocol respectively. Defaults to Default.
    #       # disable_outbound_snat          = false              # (Optional) Should outbound SNAT be disabled for this Load Balancer Rule? Defaults to false.
    #       # enable_tcp_reset               = true               # (Optional) Is TCP Reset enabled for this Load Balancer Rule
    #     },
    #     tcp80 = {
    #       protocol                       = "Tcp"    # (Required) The transport protocol for the external endpoint. Possible values are Tcp, Udp or All.
    #       frontend_port                  = 80       # (Required) The port for the external endpoint. Port numbers for each Rule must be unique within the Load Balancer. Possible values range between 0 and 65534, inclusive. A port of 0 means "Any Port".
    #       backend_port                   = 80       # (Required) The port used for internal connections on the endpoint. Possible values range between 0 and 65535, inclusive. A port of 0 means "Any Port".
    #       probe_name                     = "tcp80"  # (Optional) The name of a Probe defined above
    #       enable_floating_ip             = true     # (Optional) Are the Floating IPs enabled for this Load Balancer Rule? A "floating” IP is reassigned to a secondary server in case the primary server fails. Required to configure a SQL AlwaysOn Availability Group. Defaults to false.
    #       frontend_ip_configuration_name = "feipc1" # (Requires) The name of the Frontend IP Configuration to associate with the Load Balancer Rule.
    #       # idle_timeout_in_minutes        = 4                  # (Optional) Specifies the idle timeout in minutes for TCP connections. Valid values are between 4 and 100 minutes. Defaults to 4 minutes.
    #       load_distribution = "SourceIPProtocol" #(Optional) Specifies the load balancing distribution type to be used by the Load Balancer. Possible values are: Default – The load balancer is configured to use a 5 tuple hash to map traffic to available servers. SourceIP – The load balancer is configured to use a 2 tuple hash to map traffic to available servers. SourceIPProtocol – The load balancer is configured to use a 3 tuple hash to map traffic to available servers. Also known as Session Persistence, where in the Azure portal the options are called None, Client IP and Client IP and Protocol respectively. Defaults to Default.
    #       # disable_outbound_snat          = false              # (Optional) Should outbound SNAT be disabled for this Load Balancer Rule? Defaults to false.
    #       # enable_tcp_reset               = true               # (Optional) Is TCP Reset enabled for this Load Balancer Rule
    #     }
    #   }
    # }

    # Optional: Uncomment and configure data disks for the VM. Can create more than one data disks.
    # data_disks = {
    #   disk1 = {
    #     # caching                        = "ReadWrite"    # (Optional) The type of Caching which should be used for this Data Disk. Possible values are None, ReadOnly and ReadWrite.
    #     # create_option                  = "Empty"        # (Optional) The create option which should be used for this Data Disk. Possible values are Empty and FromImage. Defaults to Empty. (FromImage should only be used if the source image includes data disks).
    #     # disk_size_gb                   = 256            # (Optional) The size of the Data Disk which should be created. Default to 256
    #     # disk_encryption_set_id         = ""             # (Optional) The ID of the Disk Encryption Set which should be used to encrypt this Data Disk. Changing this forces a new resource to be created.
    #     lun                            = 0              # (Required) The Logical Unit Number of the Data Disk, which must be unique within the Virtual Machine.
    #     # storage_account_type           = "Standard_LRS" # (Optional) The Type of Storage Account which should back this Data Disk. Possible values include Standard_LRS, StandardSSD_LRS, StandardSSD_ZRS, Premium_LRS, PremiumV2_LRS, Premium_ZRS and UltraSSD_LRS. Default to Standard_LRS
    #     # ultra_ssd_disk_iops_read_write = ""             # (Optional) Specifies the Read-Write IOPS for this Data Disk. Only settable when storage_account_type is PremiumV2_LRS or UltraSSD_LRS.
    #     # ultra_ssd_disk_mbps_read_write = ""             # (Optional) Specifies the bandwidth in MB per second for this Data Disk. Only settable when storage_account_type is PremiumV2_LRS or UltraSSD_LRS.
    #     # write_accelerator_enabled      = ""             # (Optional) Should Write Accelerator be enabled for this Data Disk? Defaults to false.
    #   }
    # }

    # Optional: Uncomment this if you want to set additional capabilities other than the default below
    # additional_capabilities = {
    #   ultra_ssd_enabled   = false
    # }

    # Optional: Uncomment this if you want to set additional unattend content
    # additional_unattend_content  = [{
    #   content = "" # (Required) The XML formatted content that is added to the unattend.xml file for the specified path and component. Changing this forces a new resource to be created.
    #   setting = "" # (Required) The name of the setting to which the content applies. Possible values are AutoLogon and FirstLogonCommands. Changing this forces a new resource to be created.
    # }]

    # Optional: Uncomment if you need to configure automatic os upgrade policy
    # automatic_os_upgrade_policy = [{
    #   disable_automatic_rollback  = false # (Required) Should automatic rollbacks be disabled?
    #   enable_automatic_os_upgrade = true  # (Required) Should OS Upgrades automatically be applied to Scale Set instances in a rolling fashion when a newer version of the OS Image becomes available?
    # }]

    # Optional: Uncomment if you need to configure automatic instance repair
    # automatic_instance_repair = [{
    #   enabled      = true    # (Required) Should the automatic instance repair be enabled on this Virtual Machine Scale Set?
    #   grace_period = "PT30M" # (Optional) Amount of time for which automatic repairs will be delayed. The grace period starts right after the VM is found unhealthy. Possible values are between 10 and 90 minutes. The time duration should be specified in ISO 8601 format (e.g. PT10M to PT90M).
    # }]
    # capacity_reservation_group_id                     = ""                                            # (Optional) Specifies the ID of the Capacity Reservation Group which the Virtual Machine Scale Set should be allocated to. Changing this forces a new resource to be created.
    # custom_data                                       = "post_install_scripts/ubuntu/post_install.sh" # Optional: Set this value with the relative path to the file from your CWD.
    # do_not_run_extensions_on_overprovisioned_machines = false                                         # (Optional) Do not run extensions on overprovisioned machines? Default to false
    # edge_zone                                         = false                                         # (Optional) Specifies the Edge Zone within the Azure Region where this windows Virtual Machine Scale Set should exist. Changing this forces a new windows Virtual Machine Scale Set to be created. Default to null
    # enable_automatic_updates                          = true                                          # (Optional) Are automatic updates enabled for this Virtual Machine? Defaults to true.
    # encryption_at_host_enabled                        = false                                         # (Optional) Should all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host? Default to null

    # Optional: Uncomment this if you want to deploy extensions on the VMSS
    # extension = {
    #   ext_name = {                            # (Required) The name for the Virtual Machine Scale Set Extension.
    #     publisher                  = ""       # (Required) Specifies the Publisher of the Extension.
    #     type                       = ""       # (Required) Specifies the Type of the Extension.
    #     type_handler_version       = ""       # (Required) Specifies the version of the extension to use, available versions can be found using the Azure CLI.
    #     auto_upgrade_minor_version = true     # (Optional) Should the latest version of the Extension be used at Deployment Time, if one is available? This won't auto-update the extension on existing installation. Defaults to true.
    #     automatic_upgrade_enabled  = true     # (Optional) Should the Extension be automatically updated whenever the Publisher releases a new version of this VM Extension? Defaults to true.
    #     force_update_tag           = ""       # (Optional) A value which, when different to the previous value can be used to force-run the Extension even if the Extension Configuration hasn't changed. Defaults to null.
    #     protected_settings         = ""       # (Optional) A JSON String which specifies Sensitive Settings (such as Passwords) for the Extension. Defaults to null.
    #     # protected_settings_from_key_vault = { # protected_settings_from_key_vault = "" # (Optional) A protected_settings_from_key_vault block as defined below. protected_settings_from_key_vault cannot be used with protected_settings
    #     #   # psfkv1 = {
    #     #   #   secret_url      = "url" # (Required) The URL to the Key Vault Secret which stores the protected settings."
    #     #   #   source_vault_id = ""    # (Required) The ID of the source Key Vault.
    #     #   # }
    #     # }
    #     provision_after_extensions = ["", ""] # (Optional) An ordered list of Extension names which this should be provisioned after.
    #     settings                   = ""       # (Optional) A JSON String which specifies Settings for the Extension.
    #   }
    # }

    # extension_operations_enabled = true         # (Optional) Should extension operations be allowed on the Virtual Machine Scale Set? Possible values are true or false. Defaults to true. Changing this forces a new windows Virtual Machine Scale Set to be created.
    # extensions_time_budget       = "PT1H30M"    # (Optional) Specifies the duration allocated for all extensions to start. The time duration should be between 15 minutes and 120 minutes (inclusive) and should be specified in ISO 8601 format. Defaults to PT1H30M.
    # eviction_policy              = "Deallocate" # (Optional) Specifies the eviction policy for Virtual Machines in this Scale Set. Possible values are Deallocate and Delete. Changing this forces a new resource to be created.

    # Optional: Uncomment this if you want to deploy a gallery application on the VMSS
    # gallery_application = {
    #   ga1 = {
    #     version_id             = "" # (Required) Specifies the Gallery Application Version resource ID. Changing this forces a new resource to be created.
    #     configuration_blob_uri = "" # (Optional) Specifies the URI to an Azure Blob that will replace the default configuration for the package if provided. Changing this forces a new resource to be created.
    #     order                  = "" # (Optional) Specifies the order in which the packages have to be installed. Possible values are between 0 and 2147483647. Defaults to 0. Changing this forces a new resource to be created.
    #     tag                    = "" # (Optional) Specifies a passthrough value for more generic context. This field can be any valid string value. Changing this forces a new resource to be created.
    #   }
    # }

    # health_probe_id = "" # (Optional) The ID of a Load Balancer Probe which should be used to determine the health of an instance. This is Required and can only be specified when upgrade_mode is set to Automatic or Rolling.
    # host_group_id   = "" # (Optional) Specifies the ID of the dedicated host group that the virtual machine scale set resides in. Changing this forces a new resource to be created.

    # Optional: Uncomment this if you want to set a user assigned identity for the VM. 
    # Note that if boot_diagnostic is Enabled then a UserAssigned identity is automatically created and assigned to the VMSS. 
    # identity = {
    #   type         = "UserAssigned" # (Optional) The Type of Identity which should be used for this Virtual Machine Scale Set. Only UserAssigned should be used for VMSS. Default to UserAssigned
    #   identity_ids = []             # (Optional) A list of User Assigned Identity ID's which should be associated with this Virtual Machine Scale Set. Default to [] and new UserAssigned identity is created.
    # }

    # The next block is optional. Uncomment and configure to use it to specify the key vault to use for the VMSS admin password
    # key_vault = {
    #   name                = "devCKV-Mana-Dev-kv" # (Optional) The name of the Key Vault resource to use. Default to a generated name
    #   resource_group_name = "Management"         # (Optional) The name of the Resource Group where the Key Vault is located. Default to the Resource Group "Keyvault"
    # }

    # license_type  = "Windows_Server" # (Optional) Specifies the type of on-premise license (also known as Azure Hybrid Use Benefit) which should be used for this Virtual Machine Scale Set. Possible values are None, Windows_Client and Windows_Server.
    # max_bid_price = ""               # (Optional) The maximum price you're willing to pay for each Virtual Machine in this Scale Set, in US Dollars; which must be greater than the current spot price. If this bid price falls below the current spot price the Virtual Machines in the Scale Set will be evicted using the eviction_policy. Defaults to -1, which means that each Virtual Machine in this Scale Set should not be evicted for price reasons.

    # Optional: Uncomment this if you want to set a plan for the VMSS
    # plan = [{
    #   name      = "" # (Required) Specifies the name of the image from the marketplace. Changing this forces a new resource to be created.
    #   product   = "" # (Required) Specifies the publisher of the image. Changing this forces a new resource to be created.
    #   publisher = "" # (Required) Specifies the product of the image from the marketplace. Changing this forces a new resource to be created.
    # }]

    # platform_fault_domain_count  = 1         # (Optional) Specifies the number of fault domains that are used by this windows Virtual Machine Scale Set. Changing this forces a new resource to be created.
    # priority                     = "Regular" # (Optional) The Priority of this Virtual Machine Scale Set. Possible values are Regular and Spot. Defaults to Regular. Changing this value forces a new resource.
    # provision_vm_agent           = true      # (Optional) Should the Azure VM Agent be provisioned on each Virtual Machine in the Scale Set? Defaults to true. Changing this value forces a new resource to be created.
    # proximity_placement_group_id = ""        # (Optional) The ID of the Proximity Placement Group in which the Virtual Machine Scale Set should be assigned to. Changing this forces a new resource to be created.

    # Optional: Uncomment this if you want to set a rolling upgrade policy for the VMSS
    # rolling_upgrade_policy = [{
    #   cross_zone_upgrades_enabled             = "" # (Optional) Should the Virtual Machine Scale Set ignore the Azure Zone boundaries when constructing upgrade batches? Possible values are true or false.
    #   max_batch_instance_percent              = "" # (Required) The maximum percent of total virtual machine instances that will be upgraded simultaneously by the rolling upgrade in one batch. As this is a maximum, unhealthy instances in previous or future batches can cause the percentage of instances in a batch to decrease to ensure higher reliability.
    #   max_unhealthy_instance_percent          = "" # (Required) The maximum percentage of the total virtual machine instances in the scale set that can be simultaneously unhealthy, either as a result of being upgraded, or by being found in an unhealthy state by the virtual machine health checks before the rolling upgrade aborts. This constraint will be checked prior to starting any batch.
    #   max_unhealthy_upgraded_instance_percent = "" # (Required) The maximum percentage of upgraded virtual machine instances that can be found to be in an unhealthy state. This check will happen after each batch is upgraded. If this percentage is ever exceeded, the rolling update aborts.
    #   pause_time_between_batches              = "" # (Required) The wait time between completing the update for all virtual machines in one batch and starting the next batch. The time duration should be specified in ISO 8601 format.
    #   prioritize_unhealthy_instances_enabled  = "" # (Optional) Upgrade all unhealthy instances in a scale set before any healthy instances. Possible values are true or false.
    #   maximum_surge_instances_enabled         = "" # (Optional) Create new virtual machines to upgrade the scale set, rather than updating the existing virtual machines. Existing virtual machines will be deleted once the new virtual machines are created for each batch. Possible values are true or false.
    # }]

    # Optional: Uncomment this if you want to set a scale in policy for the VMSS
    # scale_in = [{
    #   rule                   = "Default" # (Optional) The scale-in policy rule that decides which virtual machines are chosen for removal when a Virtual Machine Scale Set is scaled in. Possible values for the scale-in policy rules are Default, NewestVM and OldestVM, defaults to Default. For more information about scale in policy, please refer to this doc.
    #   force_deletion_enabled = false     # (Optional) Should the virtual machines chosen for removal be force deleted when the virtual machine scale set is being scaled-in? Possible values are true or false. Defaults to false.
    # }]

    # Optional: Uncomment this if you want to set secrets for the VMSS
    # secret = {
    #   certificate = { # (Required) One or more certificate blocks as defined above.
    #     cert1 = {
    #       store = "" # (Required) The certificate store on the Virtual Machine where the certificate should be added.
    #       url   = "" # (Required) The Secret URL of a Key Vault Certificate.
    #     }
    #   }
    #   key_vault_id = "" # (Required) The ID of the Key Vault from which all Secrets should be sourced.
    # }

    # secure_boot_enabled    = false # (Optional) Specifies whether secure boot should be enabled on the virtual machine. Changing this forces a new resource to be created.
    # single_placement_group = true  # (Optional) Should this Virtual Machine Scale Set be limited to a Single Placement Group, which means the number of instances will be capped at 100 Virtual Machines. Defaults to true.
    # source_image_id        = ""    # (Optional) The ID of an Image which each Virtual Machine in this Scale Set should be based on. Possible Image ID types include Image ID, Shared Image ID, Shared Image Version ID, Community Gallery Image ID, Community Gallery Image Version ID, Shared Gallery Image ID and Shared Gallery Image Version ID.

    # Optional: Uncomment this if you want to set a spot restore policy for the VMSS
    # spot_restore = [{
    #   enabled = true   # (Optional) Should the Spot-Try-Restore feature be enabled? The Spot-Try-Restore feature will attempt to automatically restore the evicted Spot Virtual Machine Scale Set VM instances opportunistically based on capacity availability and pricing constraints. Possible values are true or false. Defaults to false. Changing this forces a new resource to be created.
    #   timeout = "PT1H" # (Optional) The length of time that the Virtual Machine Scale Set should attempt to restore the Spot VM instances which have been evicted. The time duration should be between 15 minutes and 120 minutes (inclusive). The time duration should be specified in the ISO 8601 format. Defaults to PT1H. Changing this forces a new resource to be created.
    # }]

    # Optional: Uncomment this if you want to set a termination notification for the VMSS
    # termination_notification  = [{
    #   enabled = true   # (Required) Should the termination notification be enabled on this Virtual Machine Scale Set?
    #   timeout = "PT5M" # (Optional) Length of time (in minutes, between 5 and 15) a notification to be sent to the VM on the instance metadata server till the VM gets deleted. The time duration should be specified in ISO 8601 format. Defaults to PT5M.
    # }]

    # upgrade_mode = "Manual" # (Optional) Specifies how Upgrades (e.g. changing the Image/SKU) should be performed to Virtual Machine Instances. Possible values are Automatic, Manual and Rolling. Defaults to Manual. Changing this forces a new resource to be created.
    # single_placement_group = false # (Optional) Should this Virtual Machine Scale Set be limited to a Single Placement Group, which means the number of instances will be capped at 100 Virtual Machines. Defaults to true.
    # overprovision          = false # (Optional) Should Azure over-provision Virtual Machines in this Scale Set? This means that multiple Virtual Machines will be provisioned and Azure will keep the instances which become available first - which improves provisioning success rates and improves deployment time. You're not billed for these over-provisioned VM's and they don't count towards the Subscription Quota. Defaults to true.

    # Optional: Uncomment this if you want to add custom tags to the VMSS
    # tags = {
    #   some = "a"
    #   new  = "b"
    #   tag  = "c"
    # }

    # timezone     = "Eastern Standard Time"                       # (Optional) Specifies the time zone of the virtual machine, the possible values are defined here: https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/
    # user_data    = "post_install_scripts/ubuntu/post_install.sh" # (Optional) Set this value with the relative path to the file from your CWD.
    # vtpm_enabled = false                                         # (Optional) Specifies whether vTPM should be enabled on the virtual machine. Changing this forces a new resource to be created.

    # winrm_listener = [{
    #   certificate_url = ""      # (Optional) The Secret URL of a Key Vault Certificate, which must be specified when protocol is set to Https. Changing this forces a new resource to be created.
    #   protocol        = "Https" # (Required) The Protocol of the WinRM Listener. Possible values are Http and Https. Changing this forces a new resource to be created.
    # }]

    # zone_balance = false                                         # (Optional) Should the Virtual Machines in this Scale Set be strictly evenly distributed across Availability Zones? Defaults to false. Changing this forces a new resource to be created.
    # zones        = []                                            # (Optional) Specifies a list of Availability Zones in which this windows Virtual Machine Scale Set should be located. Changing this forces a new windows Virtual Machine Scale Set to be created.

  }
}
