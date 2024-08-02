resource "azurerm_log_analytics_workspace" "example" {
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "log-${local.random_name}"
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
