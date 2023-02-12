terraform {
  required_version = ">= 1.2"
}

module "test" {
  source  = "./../../../"
  regions = var.regions
}
