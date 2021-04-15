provider "azurerm" {
  features {}
}

############################ Locals for Business Units ############################

locals {
  businessUnits = {
    transitBu11 = {
      location       = var.azureLocation
      addressSpace   = "100.64.48.0/20"
      subnetPrefixes = ["100.64.48.0/24", "100.64.49.0/24", "100.64.50.0/24"]
      subnetNames    = ["external", "internal", "workload"]
    }
    transitBu12 = {
      location       = var.azureLocation
      addressSpace   = "100.64.64.0/20"
      subnetPrefixes = ["100.64.64.0/24", "100.64.65.0/24", "100.64.66.0/24"]
      subnetNames    = ["external", "internal", "workload"]
    }
    transitBu13 = {
      location       = var.azureLocation
      addressSpace   = "100.64.80.0/20"
      subnetPrefixes = ["100.64.80.0/24", "100.64.81.0/24", "100.64.82.0/24"]
      subnetNames    = ["external", "internal", "workload"]
    }
    bu11 = {
      location       = var.azureLocation
      addressSpace   = "10.1.0.0/16"
      subnetPrefixes = ["10.1.10.0/24", "10.1.52.0/24"]
      subnetNames    = ["external", "internal"]
    }
    bu12 = {
      location       = var.azureLocation
      addressSpace   = "10.1.0.0/16"
      subnetPrefixes = ["10.1.10.0/24", "10.1.52.0/24"]
      subnetNames    = ["external", "internal"]
    }
    bu13 = {
      location       = var.azureLocation
      addressSpace   = "10.1.0.0/16"
      subnetPrefixes = ["10.1.10.0/24", "10.1.52.0/24"]
      subnetNames    = ["external", "internal"]
    }
  }
}

############################ Locals for Compute ############################

locals {
  jumphosts = {
    transitBu11 = {
      subnet = module.network["transitBu11"].vnet_subnets[0]
    }
    transitBu12 = {
      subnet = module.network["transitBu12"].vnet_subnets[0]
    }
    transitBu13 = {
      subnet = module.network["transitBu13"].vnet_subnets[0]
    }
    bu11 = {
      subnet = module.network["bu11"].vnet_subnets[0]
    }
    bu12 = {
      subnet = module.network["bu12"].vnet_subnets[0]
    }
    bu13 = {
      subnet = module.network["bu13"].vnet_subnets[0]
    }
  }

  webservers = {
    bu11 = {
      subnet = module.network["bu11"].vnet_subnets[1]
    }
    bu12 = {
      subnet = module.network["bu12"].vnet_subnets[1]
    }
    bu13 = {
      subnet = module.network["bu13"].vnet_subnets[1]
    }
  }
}

############################ Resource Groups ############################

resource "azurerm_resource_group" "rg" {
  for_each = local.businessUnits
  name     = format("%s-rg-%s-%s", var.projectPrefix, each.key, random_id.buildSuffix.hex)
  location = each.value["location"]

  tags = {
    Name      = format("%s-rg-%s-%s", var.resourceOwner, each.key, random_id.buildSuffix.hex)
    Terraform = "true"
  }
}

############################ VNets ############################

module "network" {
  for_each            = local.businessUnits
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.rg[each.key].name
  vnet_name           = format("%s-vnet-%s-%s", var.projectPrefix, each.key, random_id.buildSuffix.hex)
  address_space       = each.value["addressSpace"]
  subnet_prefixes     = each.value["subnetPrefixes"]
  subnet_names        = each.value["subnetNames"]

  tags = {
    Name      = format("%s-vnet-%s-%s", var.resourceOwner, each.key, random_id.buildSuffix.hex)
    Terraform = "true"
  }
}

############################ VNet Peering ############################

# Transit to Transit Peering
resource "azurerm_virtual_network_peering" "peer11to12" {
  name                      = "peer11to12"
  resource_group_name       = azurerm_resource_group.rg["transitBu11"].name
  virtual_network_name      = module.network["transitBu11"].vnet_name
  remote_virtual_network_id = module.network["transitBu12"].vnet_id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "peer11to13" {
  name                      = "peer11to13"
  resource_group_name       = azurerm_resource_group.rg["transitBu11"].name
  virtual_network_name      = module.network["transitBu11"].vnet_name
  remote_virtual_network_id = module.network["transitBu13"].vnet_id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "peer12to11" {
  name                      = "peer12to11"
  resource_group_name       = azurerm_resource_group.rg["transitBu12"].name
  virtual_network_name      = module.network["transitBu12"].vnet_name
  remote_virtual_network_id = module.network["transitBu11"].vnet_id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "peer12to13" {
  name                      = "peer12to13"
  resource_group_name       = azurerm_resource_group.rg["transitBu12"].name
  virtual_network_name      = module.network["transitBu12"].vnet_name
  remote_virtual_network_id = module.network["transitBu13"].vnet_id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "peer13to11" {
  name                      = "peer13to11"
  resource_group_name       = azurerm_resource_group.rg["transitBu13"].name
  virtual_network_name      = module.network["transitBu13"].vnet_name
  remote_virtual_network_id = module.network["transitBu11"].vnet_id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "peer13to12" {
  name                      = "peer13to12"
  resource_group_name       = azurerm_resource_group.rg["transitBu13"].name
  virtual_network_name      = module.network["transitBu13"].vnet_name
  remote_virtual_network_id = module.network["transitBu12"].vnet_id
  allow_forwarded_traffic   = true
}

# BU to Transit BU Peering
resource "azurerm_virtual_network_peering" "peer11_1" {
  name                      = "peer11toTransit11"
  resource_group_name       = azurerm_resource_group.rg["bu11"].name
  virtual_network_name      = module.network["bu11"].vnet_name
  remote_virtual_network_id = module.network["transitBu11"].vnet_id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "peer11_2" {
  name                      = "peerTransit11to11"
  resource_group_name       = azurerm_resource_group.rg["transitBu11"].name
  virtual_network_name      = module.network["transitBu11"].vnet_name
  remote_virtual_network_id = module.network["bu11"].vnet_id
  allow_forwarded_traffic   = true
}

############################ Route Tables ############################

# resource "azurerm_route_table" "rt" {
#   for_each                      = local.businessUnits
#   name                          = format("%s-rt-public-%s", var.projectPrefix, random_id.buildSuffix.hex)
#   location                      = azurerm_resource_group.rg[each.key].location
#   resource_group_name           = azurerm_resource_group.rg[each.key].name
#   disable_bgp_route_propagation = false

#   route {
#     name                   = "volterra_gateway"
#     address_prefix         = "100.64.0.0/16"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "10.64.1.10"
#   }

#   tags = {
#     Name      = format("%s-rt-public-%s", var.resourceOwner, random_id.buildSuffix.hex)
#     Terraform = "true"
#   }
# }

# resource "azurerm_subnet_route_table_association" "rt" {
#   for_each       = local.businessUnits
#   subnet_id      = module.network[each.key].vnet_subnets[0]
#   route_table_id = azurerm_route_table.rt[each.key].id
# }

############################ Security Groups ############################

resource "azurerm_network_security_group" "jumphost" {
  for_each            = local.jumphosts
  name                = format("%s-nsg-jumphost-%s", var.projectPrefix, random_id.buildSuffix.hex)
  location            = azurerm_resource_group.rg[each.key].location
  resource_group_name = azurerm_resource_group.rg[each.key].name

  security_rule {
    name                       = "allow_SSH"
    description                = "Allow SSH access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Name      = format("%s-nsg-jumphost-%s", var.resourceOwner, random_id.buildSuffix.hex)
    Terraform = "true"
  }
}

resource "azurerm_network_security_group" "webserver" {
  for_each            = local.webservers
  name                = format("%s-nsg-webservers-%s", var.projectPrefix, random_id.buildSuffix.hex)
  location            = azurerm_resource_group.rg[each.key].location
  resource_group_name = azurerm_resource_group.rg[each.key].name

  security_rule {
    name                       = "allow_SSH"
    description                = "Allow SSH access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_HTTP"
    description                = "Allow HTTP access"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Name      = format("%s-nsg-webservers-%s", var.resourceOwner, random_id.buildSuffix.hex)
    Terraform = "true"
  }
}

############################ Compute ############################

module "jumphost" {
  for_each           = local.jumphosts
  source             = "../../../../modules/azure/terraform/jumphost/"
  projectPrefix      = var.projectPrefix
  buildSuffix        = random_id.buildSuffix.hex
  resourceOwner      = var.resourceOwner
  azureResourceGroup = azurerm_resource_group.rg[each.key].name
  azureLocation      = azurerm_resource_group.rg[each.key].location
  keyName            = var.keyName
  mgmtSubnet         = each.value["subnet"]
  securityGroup      = azurerm_network_security_group.jumphost[each.key].id
}

module "webserver" {
  for_each           = local.webservers
  source             = "../../../../modules/azure/terraform/webServer/"
  projectPrefix      = var.projectPrefix
  buildSuffix        = random_id.buildSuffix.hex
  resourceOwner      = var.resourceOwner
  azureResourceGroup = azurerm_resource_group.rg[each.key].name
  azureLocation      = azurerm_resource_group.rg[each.key].location
  keyName            = var.keyName
  subnet             = each.value["subnet"]
  securityGroup      = azurerm_network_security_group.webserver[each.key].id
}
