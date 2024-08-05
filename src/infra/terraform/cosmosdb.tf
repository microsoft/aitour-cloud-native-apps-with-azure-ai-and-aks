resource "azurerm_cosmosdb_account" "example" {
  name                               = "db-${local.random_name}"
  location                           = azurerm_resource_group.example.location
  resource_group_name                = azurerm_resource_group.example.name
  offer_type                         = "Standard"
  kind                               = "GlobalDocumentDB"
  access_key_metadata_writes_enabled = false
  minimal_tls_version                = "Tls12"
  automatic_failover_enabled         = true

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = azurerm_resource_group.example.location
    failover_priority = 0 # primary location
  }
}

resource "azurerm_cosmosdb_sql_database" "example" {
  name                = "orderdb"
  resource_group_name = azurerm_cosmosdb_account.example.resource_group_name
  account_name        = azurerm_cosmosdb_account.example.name
  throughput          = 400
}

resource "azurerm_cosmosdb_sql_container" "example" {
  name                  = "orders"
  resource_group_name   = azurerm_cosmosdb_account.example.resource_group_name
  account_name          = azurerm_cosmosdb_account.example.name
  database_name         = azurerm_cosmosdb_sql_database.example.name
  partition_key_paths   = ["/storeId"]
  partition_key_version = 1
  throughput            = 400
}

resource "azurerm_user_assigned_identity" "db" {
  resource_group_name = azurerm_resource_group.example.name
  location            = var.location
  name                = "db-${local.random_name}-identity"
}

resource "azurerm_federated_identity_credential" "db" {
  resource_group_name = azurerm_resource_group.example.name
  parent_id           = azurerm_user_assigned_identity.db.id
  name                = "db-${local.random_name}"
  issuer              = jsondecode(azapi_resource.aks.output).properties.oidcIssuerProfile.issuerURL
  audience            = ["api://AzureADTokenExchange"]
  subject             = "system:serviceaccount:${var.k8s_namespace}:makeline-service-account"
}

resource "azurerm_cosmosdb_sql_role_definition" "db" {
  resource_group_name = azurerm_resource_group.example.name
  account_name        = azurerm_cosmosdb_account.example.name
  name                = "CosmosDBDataContributor - ${azurerm_user_assigned_identity.db.name}"
  type                = "CustomRole"
  assignable_scopes   = [azurerm_cosmosdb_account.example.id]

  permissions {
    data_actions = [
      "Microsoft.DocumentDB/databaseAccounts/readMetadata",
      "Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*",
      "Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*",
    ]
  }
}

resource "azurerm_cosmosdb_sql_role_assignment" "db_sql_data_contributor" {
  resource_group_name = azurerm_resource_group.example.name
  role_definition_id  = azurerm_cosmosdb_sql_role_definition.db.id
  scope               = azurerm_cosmosdb_account.example.id
  account_name        = azurerm_cosmosdb_account.example.name
  principal_id        = azurerm_user_assigned_identity.db.principal_id
}

resource "azurerm_role_assignment" "db_sb_data_owner" {
  scope                = azurerm_servicebus_namespace.example.id
  role_definition_name = "Azure Service Bus Data Owner"
  principal_id         = azurerm_user_assigned_identity.db.principal_id
}