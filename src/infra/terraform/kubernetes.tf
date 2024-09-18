resource "azapi_resource" "aks" {
  type                      = "Microsoft.ContainerService/managedClusters@2024-03-02-preview"
  parent_id                 = azurerm_resource_group.example.id
  location                  = azurerm_resource_group.example.location
  name                      = "aks-${local.random_name}"
  schema_validation_enabled = false

  body = jsonencode({
    identity = {
      type = "SystemAssigned"
    },
    properties = {
      agentPoolProfiles = [
        {
          name   = "systempool"
          count  = 3
          vmSize = "Standard_DS4_v2"
          osType = "Linux"
          mode   = "System"
        }
      ]
      addonProfiles = {
        omsagent = {
          enabled = true
          config = {
            logAnalyticsWorkspaceResourceID = azurerm_log_analytics_workspace.example.id
            useAADAuth                      = "true"
          }
        }
      }
      azureMonitorProfile = {
        metrics = {
          enabled = true,
          kubeStateMetrics = {
            metricLabelsAllowlist      = "",
            metricAnnotationsAllowList = ""
          }
        },
        containerInsights = {
          enabled                         = true,
          logAnalyticsWorkspaceResourceId = azurerm_log_analytics_workspace.example.id
        }
      }
      serviceMeshProfile = {
        mode = "Istio"
        istio = {
          components = {
            ingressGateways = [
              {
                enabled = true
                mode    = "External"
              },
              {
                enabled = true
                mode    = "Internal"
              }
            ]
          }
          revisions = [
            "asm-1-22"
          ]
        }
      }
    }
    sku = {
      name = "Automatic"
      tier = "Standard"
    }
  })

  response_export_values = [
    "properties.identityProfile.kubeletidentity.objectId",
    "properties.oidcIssuerProfile.issuerURL",
    "properties.nodeResourceGroup"
  ]
}

resource "azurerm_role_assignment" "aks2" {
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  scope                = azapi_resource.aks.id
}