# Set minimum Terraform version and Terraform Cloud backend
terraform {
  required_version = "~> 0.14"
  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = "0.2.1"
    }
    azurerm = "~> 2"
  }
}