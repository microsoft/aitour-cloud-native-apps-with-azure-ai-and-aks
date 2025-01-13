resource "azurerm_servicebus_namespace" "example" {
  name                = "sb-${local.random_name}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"
  local_auth_enabled  = false
}

resource "azurerm_servicebus_queue" "example" {
  name         = "orders"
  namespace_id = azurerm_servicebus_namespace.example.id
}

resource "azurerm_user_assigned_identity" "sb" {
  resource_group_name = azurerm_resource_group.example.name
  location            = var.location
  name                = "sb-${local.random_name}-identity"
}

resource "azurerm_federated_identity_credential" "sb" {
  resource_group_name = azurerm_resource_group.example.name
  parent_id           = azurerm_user_assigned_identity.db.id
  name                = "sb-${local.random_name}"
  issuer              = azapi_resource.aks.output.properties.oidcIssuerProfile.issuerURL
  audience            = ["api://AzureADTokenExchange"]
  subject             = "system:serviceaccount:${var.k8s_namespace}:order-service-account"
}

resource "azurerm_role_assignment" "sb_data_owner" {
  scope                = azurerm_servicebus_namespace.example.id
  role_definition_name = "Azure Service Bus Data Owner"
  principal_id         = azurerm_user_assigned_identity.sb.principal_id
}