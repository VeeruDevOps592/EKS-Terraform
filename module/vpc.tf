locals {
  cluster_name = var.cluster_name
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = [var.address_space]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    Name = var.vnet_name
    Env  = var.env
  }
}

# Subnets
resource "azurerm_subnet" "public_subnet" {
  count                = var.pub_subnet_count
  name                 = "${var.pub_subnet_name}-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [element(var.pub_address_space, count.index)]

  delegation {
    name = "aks"
    service_delegation {
      name = "Microsoft.ContainerService/managedClusters"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
    }
  }

  tags = {
    Name = "${var.pub_subnet_name}-${count.index + 1}"
    Env  = var.env
    "kubernetes.io/role/elb" = "1"
  }
}

resource "azurerm_subnet" "private_subnet" {
  count                = var.pri_subnet_count
  name                 = "${var.pri_subnet_name}-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [element(var.pri_address_space, count.index)]

  tags = {
    Name = "${var.pri_subnet_name}-${count.index + 1}"
    Env  = var.env
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Public IP for NAT Gateway
resource "azurerm_public_ip" "ngw_eip" {
  name                = var.eip_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Name = var.eip_name
  }
}

# NAT Gateway
resource "azurerm_nat_gateway" "ngw" {
  name                = var.ngw_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  public_ip {
    id = azurerm_public_ip.ngw_eip.id
  }

  tags = {
    Name = var.ngw_name
  }
}

# Route Table for Public Subnets
resource "azurerm_route_table" "public_rt" {
  name                = var.public_route_table_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    Name = var.public_route_table_name
    Env  = var.env
  }
}

# Route Table for Private Subnets
resource "azurerm_route_table" "private_rt" {
  name                = var.private_route_table_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  route {
    name                   = "default-route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "Internet"
    next_hop_in_ip_address = azurerm_nat_gateway.ngw.public_ip[0].ip_address
  }

  tags = {
    Name = var.private_route_table_name
    Env  = var.env
  }
}

# Associate Subnets with Route Tables
resource "azurerm_subnet_route_table_association" "public_rt_assoc" {
  count          = var.pub_subnet_count
  subnet_id      = azurerm_subnet.public_subnet[count.index].id
  route_table_id = azurerm_route_table.public_rt.id
}

resource "azurerm_subnet_route_table_association" "private_rt_assoc" {
  count          = var.pri_subnet_count
  subnet_id      = azurerm_subnet.private_subnet[count.index].id
  route_table_id = azurerm_route_table.private_rt.id
}

# Network Security Group
resource "azurerm_network_security_group" "aks_sg" {
  name                = var.eks_sg
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "0.0.0.0/0" # Replace with a specific IP range
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-All-Outbound"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "0.0.0.0/0"
  }

  tags = {
    Name = var.eks_sg
  }
}
