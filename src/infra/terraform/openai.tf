resource "azurerm_cognitive_account" "example" {
  resource_group_name   = azurerm_resource_group.example.name
  location              = var.ai_location
  name                  = "oai-${local.random_name}"
  custom_subdomain_name = "oai-${local.random_name}"
  kind                  = "OpenAI"
  sku_name              = "S0"
  local_auth_enabled    = false
}

resource "azurerm_cognitive_deployment" "gpt" {
  cognitive_account_id = azurerm_cognitive_account.example.id
  name                 = var.gpt_model_name

  model {
    format  = "OpenAI"
    name    = var.gpt_model_name
    version = var.gpt_model_version
  }

  sku {
    name     = var.gpt_model_sku_name
    capacity = var.gpt_model_capacity
  }
}

resource "azurerm_cognitive_deployment" "dalle" {
  cognitive_account_id = azurerm_cognitive_account.example.id
  name                 = var.dalle_model_name

  model {
    format  = "OpenAI"
    name    = var.dalle_model_name
    version = var.dalle_model_version
  }

  sku {
    name     = var.dalle_model_sku_name
    capacity = var.dalle_model_capacity
  }
}

resource "azurerm_user_assigned_identity" "oai" {
  resource_group_name = azurerm_resource_group.example.name
  location            = var.ai_location
  name                = "oai-${local.random_name}-identity"
}

resource "azurerm_federated_identity_credential" "oai" {
  resource_group_name = azurerm_resource_group.example.name
  parent_id           = azurerm_user_assigned_identity.oai.id
  name                = "oai-${local.random_name}"
  issuer              = jsondecode(azapi_resource.aks.output).properties.oidcIssuerProfile.issuerURL
  audience            = ["api://AzureADTokenExchange"]
  subject             = "system:serviceaccount:${var.k8s_namespace}:ai-service-account"
}

resource "azurerm_role_assignment" "oai_rbac_mi" {
  scope                = azurerm_cognitive_account.example.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = azurerm_user_assigned_identity.oai.principal_id
}

resource "azurerm_role_assignment" "oai_rbac_me" {
  scope                = azurerm_cognitive_account.example.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = data.azurerm_client_config.current.object_id
}