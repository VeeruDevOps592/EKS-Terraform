locals {
  cluster_name = var.cluster_name
}

# Random Suffix for Unique Resource Naming
resource "random_integer" "random_suffix" {
  min = 1000
  max = 9999
}

# Azure Kubernetes Service (AKS) Cluster Managed Identity Role
resource "azurerm_role_assignment" "aks_cluster_role_assignment" {
  count = var.is_aks_role_enabled ? 1 : 0

  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_name = "Contributor" # Assign Contributor role for full cluster control
  scope                = data.azurerm_subscription.primary.id
}

# AKS Node Group Identity Role
resource "azurerm_user_assigned_identity" "aks_nodegroup_identity" {
  count    = var.is_aks_nodegroup_role_enabled ? 1 : 0
  name     = "${local.cluster_name}-nodegroup-identity-${random_integer.random_suffix.result}"
  location = var.location
  resource_group_name = var.resource_group_name
}

# Role Assignment for Node Group Identity
resource "azurerm_role_assignment" "aks_nodegroup_contributor_role" {
  count = var.is_aks_nodegroup_role_enabled ? 1 : 0

  principal_id         = azurerm_user_assigned_identity.aks_nodegroup_identity[count.index].principal_id
  role_definition_name = "Contributor"
  scope                = data.azurerm_subscription.primary.id
}

# Assign Reader Role for Node Pool Networking
resource "azurerm_role_assignment" "aks_nodegroup_reader_role" {
  count = var.is_aks_nodegroup_role_enabled ? 1 : 0

  principal_id         = azurerm_user_assigned_identity.aks_nodegroup_identity[count.index].principal_id
  role_definition_name = "Reader"
  scope                = data.azurerm_virtual_network.vnet.id
}

# AKS Managed Identity Integration for Add-Ons
resource "azurerm_role_assignment" "aks_addons_role_assignment" {
  count = var.is_aks_role_enabled ? 1 : 0

  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = data.azurerm_storage_account.aks_storage_account.id
}

# Azure Kubernetes Cluster with Role Assignments
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kubernetes_version  = var.cluster_version

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "default"
    node_count = var.default_node_count
    vm_size    = var.default_vm_size
  }

  tags = {
    Name = var.cluster_name
    Env  = var.env
  }

  depends_on = [
    azurerm_role_assignment.aks_cluster_role_assignment
  ]
}

# Custom Role for OIDC Equivalent (Example Policy)
resource "azurerm_role_definition" "aks_oidc_role" {
  name        = "${local.cluster_name}-oidc-role"
  scope       = data.azurerm_subscription.primary.id
  description = "Custom role for OIDC-equivalent functionality"

  permissions {
    actions = [
      "Microsoft.ContainerService/managedClusters/*",
      "Microsoft.Storage/storageAccounts/*",
      "Microsoft.Network/virtualNetworks/*"
    ]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id
  ]
}

# Assign Custom Role for OIDC Functionality
resource "azurerm_role_assignment" "aks_oidc_role_assignment" {
  role_definition_name = azurerm_role_definition.aks_oidc_role.name
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  scope                = data.azurerm_subscription.primary.id
}
