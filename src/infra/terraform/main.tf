terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "=1.15.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.2.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "=2.5.2"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    cognitive_account {
      purge_soft_delete_on_destroy = true
    }
  }
}

data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

resource "random_integer" "example" {
  min = 10
  max = 99
}

resource "random_pet" "example" {
  length    = 2
  separator = ""
  keepers = {
    location = var.location
  }
}

resource "azurerm_resource_group" "example" {
  name     = "rg-${local.random_name}"
  location = var.location
  tags = {
    owner   = var.owner
    session = "BRK470"
  }
}