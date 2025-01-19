locals {
  org = "medium"
  env = var.env
}

module "aks" {
  source = "../module" # Update this to your AKS module's path

  env                   = var.env
  resource_group_name   = "${local.env}-${local.org}-rg"
  aks_cluster_name      = "${local.env}-${local.org}-${var.cluster_name}"
  location              = var.location
  vnet_name             = "${local.env}-${local.org}-vnet"
  vnet_cidr             = var.vnet_cidr
  subnet_name           = "${local.env}-${local.org}-${var.subnet_name}"
  subnet_cidr           = var.subnet_cidr

  # AKS-specific configurations
  kubernetes_version    = var.kubernetes_version
  dns_prefix            = "${local.env}-${local.org}-${var.dns_prefix}"
  node_pool_name        = var.node_pool_name
  node_count            = var.node_count
  min_count             = var.min_count
  max_count             = var.max_count
  vm_size               = var.vm_size
  enable_http_application_routing = var.enable_http_application_routing
  enable_monitoring     = var.enable_monitoring
  enable_rbac           = var.enable_rbac

  # Network configurations
  network_profile = {
    network_plugin    = var.network_plugin
    network_policy    = var.network_policy
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
    docker_bridge_cidr = var.docker_bridge_cidr
  }

  # Addons and integrations
  addons = var.addons

  # Tags
  tags = {
    environment = local.env
    organization = local.org
  }
}
