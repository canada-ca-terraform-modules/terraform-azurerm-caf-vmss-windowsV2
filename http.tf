locals {
  # Legacy keyword kept for backward-compat: resolves to the default per-env script below.
  custom_data_url = strcontains(var.env, "G3") ? "https://g3pceslzresentdfa0353e.blob.core.windows.net/publicresources/windows-all-customdata-default.ps1" : "https://gcpcenteslzpublicblob4df.blob.core.windows.net/publicresources/windows-all-customdata-default.ps1"

  # custom_data may be the legacy "install-ca-certs" keyword, an explicit http(s) URL to fetch, or a
  # plain/pre-encoded value that should be passed straight through to the resource.
  custom_data_is_remote = var.custom_data == "install-ca-certs" || can(regex("^https?://", coalesce(var.custom_data, "")))
  custom_data_fetch_url = var.custom_data == "install-ca-certs" ? local.custom_data_url : var.custom_data
}

data "http" "custom_data" {
  count = local.custom_data_is_remote ? 1 : 0
  url   = local.custom_data_fetch_url
}
