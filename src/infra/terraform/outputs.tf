output "rg_name" {
  value = azurerm_resource_group.example.name
}

output "aks_name" {
  value = azapi_resource.aks.name
}

output "oai_gpt_endpoint" {
  value = azurerm_cognitive_account.example.endpoint
}

output "oai_gpt_model_name" {
  value = var.gpt_model_name
}

output "oai_dalle_endpoint" {
  value = azurerm_cognitive_account.example.endpoint
}

output "oai_dalle_model_name" {
  value = var.dalle_model_name
}

output "oai_dalle_api_version" {
  value = var.dalle_openai_api_version
}

output "oai_identity_client_id" {
  value = azurerm_user_assigned_identity.oai.client_id
}

output "amg_name" {
  value = azurerm_dashboard_grafana.example.name
}

output "sb_hostname" {
  value = "${azurerm_servicebus_namespace.example.name}.servicebus.windows.net"
}

output "sb_queue_name" {
  value = azurerm_servicebus_queue.example.name
}

output "sb_identity_client_id" {
  value = azurerm_user_assigned_identity.sb.client_id
}

output "db_endpoint" {
  value = azurerm_cosmosdb_account.example.endpoint
}

output "db_database_name" {
  value = azurerm_cosmosdb_sql_database.example.name
}

output "db_container_name" {
  value = azurerm_cosmosdb_sql_container.example.name
}

output "db_identity_client_id" {
  value = azurerm_user_assigned_identity.db.client_id
}