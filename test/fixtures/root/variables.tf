variable "regions" {
  type = list(string)
}

variable "expected" {
  type = map(object({
    abbreviation = string
    display_name = string
    latitude     = number
    longitude    = number
  }))
}

# Unused in this fixture, but defined in kitchen.local.yml. Add here to supress
# Terraform warnings.
variable "project_id" {
  type    = string
  default = ""
}
