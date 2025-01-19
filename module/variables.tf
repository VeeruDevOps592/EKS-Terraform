# General Variables
variable "cluster_name" {}
variable "address_space" {} # Equivalent to cidr-block in Azure
variable "vnet_name" {} # Equivalent to vpc-name
variable "env" {}
variable "location" {} # Azure requires specifying a region

# Public Subnet Variables
variable "pub_subnet_count" {}
variable "pub_address_space" { # Equivalent to pub-cidr-block
  type = list(string)
}
variable "pub_subnet_name" {} # Equivalent to pub-sub-name

# Private Subnet Variables
variable "pri_subnet_count" {}
variable "pri_address_space" { # Equivalent to pri-cidr-block
  type = list(string)
}
variable "pri_subnet_name" {} # Equivalent to pri-sub-name

# Route Table Variables
variable "public_route_table_name" {}
variable "private_route_table_name" {}

# Network Gateway Variables
variable "ngw_name" {}

# Security Group
variable "aks_nsg_name" {}

# Managed Identity
variable "is_aks_role_enabled" {
  type = bool
}
variable "is_aks_nodegroup_role_enabled" {
  type = bool
}

# AKS Cluster Variables
variable "is_aks_cluster_enabled" {}
variable "cluster_version" {}
variable "private_cluster_enabled" {
  type    = bool
  default = false
}
variable "addon_profiles" { # Equivalent to addons
  type = list(object({
    name    = string
    version = string
  }))
}

# Node Pool Variables
variable "node_pool_vm_size" {
  type    = string
  default = "Standard_DS2_v2"
}
variable "ondemand_instance_types" {
  type = list(string)
}
variable "spot_instance_types" {
  type = list(string)
}
variable "desired_capacity_on_demand" {}
variable "min_capacity_on_demand" {}
variable "max_capacity_on_demand" {}
variable "desired_capacity_spot" {}
variable "min_capacity_spot" {}
variable "max_capacity_spot" {}
