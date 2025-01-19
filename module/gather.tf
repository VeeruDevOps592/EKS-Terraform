# Azure AKS Cluster with AAD Integration
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kubernetes_version  = var.cluster_version

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true
    azure_active_directory {
      managed = true
      admin_group_object_ids = var.aad_admin_group_object_ids # Admin groups in AAD
    }
  }

  tags = {
    Name = var.cluster_name
    Env  = var.env
  }
}
# Define a Custom Role (Equivalent to IAM Policy)
resource "azurerm_role_definition" "aks_custom_role" {
  name        = "${var.cluster_name}-custom-role"
  scope       = data.azurerm_subscription.primary.id
  description = "Custom role for AKS Service Account access"
  
  permissions {
    actions = [
      "Microsoft.ContainerService/managedClusters/*", # Full access to AKS clusters
      "Microsoft.ContainerRegistry/registries/*",     # Access to container registry
      "Microsoft.Network/virtualNetworks/*"          # Network-related permissions
    ]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id
  ]
}

# Assign the Custom Role to AKS Managed Identity
resource "azurerm_role_assignment" "aks_role_assignment" {
  principal_id       = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_id = azurerm_role_definition.aks_custom_role.id
  scope              = data.azurerm_subscription.primary.id
}
