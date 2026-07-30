# Changelog

All notable changes to this module will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.2.0] - 2026-07-30

### Changed

- **BREAKING (handled via compat fallback):** `network_interface.enable_accelerated_networking` renamed to `accelerated_networking_enabled` (v5 provider). Old tfvars continue to work via `try()` fallback.
- **BREAKING (handled via compat fallback):** `network_interface.enable_ip_forwarding` renamed to `ip_forwarding_enabled` (v5 provider). Old tfvars continue to work via `try()` fallback.
- **BREAKING (handled via compat fallback):** `enable_automatic_updates` renamed to `automatic_updates_enabled` (v5 provider). Old tfvars continue to work via `try()` fallback.
- **BREAKING (handled via compat fallback):** `automatic_os_upgrade_policy.disable_automatic_rollback` renamed and boolean-inverted to `automatic_rollback_enabled` (v5 provider). Old tfvars continue to work via `!try()` fallback.
- **BREAKING (handled via compat fallback):** `automatic_os_upgrade_policy.enable_automatic_os_upgrade` renamed to `automatic_os_upgrade_enabled` (v5 provider). Old tfvars continue to work via `try()` fallback.
- **BREAKING (handled via compat fallback):** `data_disk.ultra_ssd_disk_iops_read_write` renamed to `disk_iops_read_write` (v5 provider). Old tfvars continue to work via `try()` fallback.
- **BREAKING (handled via compat fallback):** `data_disk.ultra_ssd_disk_mbps_read_write` renamed to `disk_mbps_read_write` (v5 provider). Old tfvars continue to work via `try()` fallback.
- **Security regression fix:** reverted `encryption_at_host_enabled` default from `false` back to `true`. The `false` default (introduced in Nov 2024) silently disabled host encryption for any caller not explicitly setting this field. Callers relying on the `false` default must now set `vmss.encryption_at_host_enabled = false` explicitly.
- Bumped child module `terraform-azurerm-caf-storage_accountV2` from `v1.0.3` to `v1.2.0`.
- Bumped child module `terraform-azurerm-caf-load_balancer` from `v1.0.2` to `v2.0.0` (adds azurerm v5 compatibility internally).
- Target provider version updated to `azurerm ~> 5.0` in `providers.tf`.
- ESLZ module source ref bumped to `v1.2.0`.

### Added

- `resilient_vm_creation_enabled` — resilient VM creation (v5 new arg).
- `resilient_vm_deletion_enabled` — resilient VM deletion (v5 new arg).
- `automatic_instance_repair.action` — repair action type (`Replace`, `Restart`, `Reimage`).
- `network_interface.auxiliary_mode` — NVA high-performance feature mode.
- `network_interface.auxiliary_sku` — NVA high-performance feature SKU.
- `network_interface.network_security_group_id` — NSG assignment on NIC.
- `providers.tf` with pinned `azurerm ~> 5.0`, `http ~> 3.0`, `null ~> 3.0`, `random ~> 3.0` constraints.
- `.tflint.hcl` config using `call_module_type = "local"` (tflint >= v0.54.0 compatible).
- `.gitignore` with the standard module template (module previously had no `.gitignore`).
- `.gitattributes` enforcing LF line endings.
- `tests/vmss_windows.tftest.hcl` — mock-provider unit tests (naming, defaults, v5 compat args, v5-only args).
- `tests/upgrade_compat.tftest.hcl` — state-chaining upgrade safety test.
- `.github/workflows/terraform-ci.yml` — CI pipeline with tflint and terraform validate.

### Removed

- `load_balancer` module call no longer passes `group`, `project`, `custom_data`, `user_data` — these arguments were removed from `terraform-azurerm-caf-load_balancer` v2.0.0 (VM-specific fields dropped from a pure load-balancer module). If any caller relied on `var.vmss.lb.custom_data` / `var.vmss.lb.user_data`, that capability is no longer available upstream.

### Fixed

- `regex("[^\\/]+"` → `regex("[^/]+"` in `locals.tf` and `secret.tf` (invalid Terraform regex escape).
- Typo `rotected_settings_from_key_vault` → `protected_settings_from_key_vault` in the `extension.protected_settings_from_key_vault` dynamic block (was causing a reference-to-undeclared-resource error whenever this block was used).
- `ip_tag` dynamic block inside `public_ip_address` referenced the wrong iterator name (`ip_tags` instead of `ip_tag`), which always errored when `ip_tags` was supplied.
- `data_disk.name` referenced `each.value.lun` instead of `data_disk.value.lun` (wrong iterator, always errored when a data disk was configured).
- `scale_in.rule` / `scale_in.force_deletion_enabled` referenced the dynamic block's own iterator value (`scale_in.value.rule`) instead of `var.vmss.scale_in.rule`, so both fields were always silently `null` regardless of caller input.
- `output "vmss_windows"` now has `sensitive = true` to prevent mock-provider test failures.
- Removed unused `local.nic_indices` (dead code, flagged by tflint `terraform_unused_declarations`).
- Removed stale Linux-specific comment on `local.vm-admin-password` (copy-paste artifact referencing `disable_password_authentication`, which does not apply to Windows VMSS).
