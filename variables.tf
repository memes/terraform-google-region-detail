variable "regions" {
  type = list(string)
  validation {
    condition     = var.regions == null ? true : length(join("", [for region in var.regions : can(regex("^[a-z]{2,}-[a-z]{2,}[1-9][0-9]*$", region)) ? "x" : ""])) == length(var.regions)
    error_message = "Each entry must be a valid Google Cloud region name."
  }
  description = <<-EOD
  A list of Google Compute region names for which to return details. The module
  does not validate that any region name is valid, just that it matches a pattern
  expected of Google Compute region names.
  EOD
}
