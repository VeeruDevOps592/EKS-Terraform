# General
variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "env" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

# Networking
variable "vnet_cidr" {
  description = "CIDR block for the virtual network"
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
}

# AKS Cluster Configuration
variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "node_pool_name" {
  description = "Name of the AKS node pool"
  type        = string
  default     = "default"
}

variable "node_count" {
  description = "Default number of nodes in the node pool"
  type        = number
  default     = 3
}

variable "min_count" {
  description = "Minimum number of nodes for auto-scaling"
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Maximum number of nodes for auto-scaling"
  type        = number
  default     = 5
}

variable "vm_size" {
  description = "VM size for the AKS nodes"
  type        = string
  default     = "Standard_DS2_v2"
}

# Networking Profile
variable "network_plugin" {
  description = "Networking plugin for AKS (azure or kubenet)"
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Network policy for AKS (azure or calico)"
  type        = string
  default     = "azure"
}

variable "service_cidr" {
  description = "Service CIDR for the AKS cluster"
  type        = string
  default     = "10.0.0.0/16"
}

variable "dns_service_ip" {
  description = "DNS service IP address"
  type        = string
  default     = "10.0.0.10"
}

variable "docker_bridge_cidr" {
  description = "Docker bridge CIDR"
  type        = string
  default     = "172.17.0.1/16"
}

# Add-ons and Integrations
variable "addons" {
  description = "List of AKS add-ons to enable"
  type        = list(object({
    name    = string
    version = string
  }))
}

# Tags
variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {
    environment = "dev"
    project     = "example"
  }
}
