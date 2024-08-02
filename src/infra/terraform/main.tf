terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "=1.14.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.112.0"
    }

    # helm = {
    #   source  = "hashicorp/helm"
    #   version = "=2.14.0"
    # }

    local = {
      source  = "hashicorp/local"
      version = "=2.5.1"
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

# provider "helm" {
#   kubernetes {
#     host                   = azapi_resource.aks.kube_admin_config.0.host
#     username               = azapi_resource.aks.kube_admin_config.0.username
#     password               = azapi_resource.aks.kube_admin_config.0.password
#     client_certificate     = base64decode(azapi_resource.aks.kube_admin_config.0.client_certificate)
#     client_key             = base64decode(azapi_resource.aks.kube_admin_config.0.client_key)
#     cluster_ca_certificate = base64decode(azapi_resource.aks.kube_admin_config.0.cluster_ca_certificate)
#   }
# }

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
}