# Environment and Region
env         = "dev"
location    = "eastus"  # Equivalent to aws-region

# Virtual Network (VNet) and Subnets
vnet_cidr           = "10.16.0.0/16"
vnet_name           = "vnet"
subnet_count        = 3
subnet_cidr_blocks  = ["10.16.0.0/20", "10.16.16.0/20", "10.16.32.0/20"]
subnet_names        = ["subnet-1", "subnet-2", "subnet-3"]

# AKS Cluster Configuration
is_aks_cluster_enabled = true
cluster_version         = "1.29.11"  # Specify an AKS-compatible Kubernetes version
cluster_name            = "aks-cluster"
dns_prefix              = "aksdns"

# Node Pool Configuration
node_pool_name           = "default"
node_vm_size             = "Standard_DS3_v2"
node_count               = 3
min_node_count           = 1
max_node_count           = 5
spot_vm_size             = ["Standard_D2_v3", "Standard_D4_v3"]
spot_min_count           = 1
spot_max_count           = 10

# Networking
network_plugin          = "azure"  # Use "azure" or "kubenet" as needed
network_policy          = "azure"
service_cidr            = "10.0.0.0/16"
dns_service_ip          = "10.0.0.10"
docker_bridge_cidr      = "172.17.0.1/16"

# Add-ons
addons = [
  {
    name    = "azure-policy"
    version = "latest"
  },
  {
    name    = "http-application-routing"
    version = "latest"
  },
  {
    name    = "azure-keyvault-secrets-provider"
    version = "latest"
  }
  # Add more Azure-specific add-ons as needed
]

# Tags for Resources
tags = {
  environment = "dev"
  project     = "azure-aks-project"
}
