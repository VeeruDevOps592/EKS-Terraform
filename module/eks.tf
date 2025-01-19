# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  count = var.is-aks-cluster-enabled == true ? 1 : 0

  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.cluster_name}-dns"
  kubernetes_version  = var.cluster_version

  default_node_pool {
    name                = "default"
    vm_size             = var.ondemand_instance_types[0]
    enable_auto_scaling = true
    min_count           = var.min_capacity_on_demand
    max_count           = var.max_capacity_on_demand
    vnet_subnet_id      = azurerm_subnet.private_subnet[0].id
    tags = {
      "Name" = "${var.cluster_name}-ondemand-nodes"
    }
  }

  # Network Configuration
  network_profile {
    network_plugin = "azure" # Use "azure" or "kubenet" based on your setup
    network_policy = "azure"
    load_balancer_sku = "standard"
  }

  role_based_access_control {
    enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Name = var.cluster_name
    Env  = var.env
  }
}

# Node Pools for Spot Instances
resource "azurerm_kubernetes_cluster_node_pool" "spot_node" {
  count               = var.is_aks_cluster_enabled == true ? 1 : 0
  name                = "spot"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks[0].id
  vm_size             = var.spot_instance_types[0]
  enable_auto_scaling = true
  min_count           = var.min_capacity_spot
  max_count           = var.max_capacity_spot
  vnet_subnet_id      = azurerm_subnet.private_subnet[1].id
  node_labels = {
    type      = "spot"
    lifecycle = "spot"
  }
  node_taints = ["lifecycle=spot:NoSchedule"]

  tags = {
    "Name" = "${var.cluster_name}-spot-nodes"
  }
}

# Virtual Network and Subnets
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_cidr]

  tags = {
    Name = var.vnet_name
    Env  = var.env
  }
}

resource "azurerm_subnet" "private_subnet" {
  count                = length(var.subnet_cidr_blocks)
  name                 = "${var.cluster_name}-subnet-${count.index + 1}"
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = element(var.subnet_cidr_blocks, count.index)

  tags = {
    Name = "subnet-${count.index + 1}"
    Env  = var.env
  }
}

# Add-ons (Optional)
resource "azurerm_kubernetes_cluster_addon_profile" "aks_addons" {
  count                = var.is_aks_cluster_enabled == true ? 1 : 0
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks[0].id

  addon_profile {
    oms_agent {
      enabled = true
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
    azure_policy {
      enabled = true
    }
  }
}
