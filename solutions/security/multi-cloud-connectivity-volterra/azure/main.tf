provider "azurerm" {
  features {}
}

############################ Locals for Business Units ############################

locals {
  businessUnits = {
    transitBu11 = {
      location       = var.azureLocation
      addressSpace   = ["100.64.48.0/20"]
      subnetPrefixes = ["100.64.48.0/24", "100.64.49.0/24", "100.64.50.0/24"]
      subnetNames    = ["external", "internal", "workload"]
    }
    transitBu12 = {
      location       = var.azureLocation
      addressSpace   = ["100.64.64.0/20"]
      subnetPrefixes = ["100.64.64.0/24", "100.64.65.0/24", "100.64.66.0/24"]
      subnetNames    = ["external", "internal", "workload"]
    }
    transitBu13 = {
      location       = var.azureLocation
      addressSpace   = ["100.64.80.0/20"]
      subnetPrefixes = ["100.64.80.0/24", "100.64.81.0/24", "100.64.82.0/24"]
      subnetNames    = ["external", "internal", "workload"]
    }
    bu11 = {
      location       = var.azureLocation
      addressSpace   = ["10.1.0.0/16"]
      subnetPrefixes = ["10.1.10.0/24", "10.1.52.0/24"]
      subnetNames    = ["external", "internal"]
    }
    bu12 = {
      location       = var.azureLocation
      addressSpace   = ["10.1.0.0/16"]
      subnetPrefixes = ["10.1.10.0/24", "10.1.52.0/24"]
      subnetNames    = ["external", "internal"]
    }
    bu13 = {
      location       = var.azureLocation
      addressSpace   = ["10.1.0.0/16"]
      subnetPrefixes = ["10.1.10.0/24", "10.1.52.0/24"]
      subnetNames    = ["external", "internal"]
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
  source              = "Azure/vnet/azurerm"
  resource_group_name = azurerm_resource_group.rg[each.key].name
  vnet_name           = format("%s-vnet-%s-%s", var.projectPrefix, each.key, random_id.buildSuffix.hex)
  address_space       = each.value["addressSpace"]
  subnet_prefixes     = each.value["subnetPrefixes"]
  subnet_names        = each.value["subnetNames"]

  # nsg_ids = {
  #   external = azurerm_network_security_group.allow_ce[each.key].id
  #   internal = azurerm_network_security_group.allow_ce[each.key].id
  # }

  route_tables_ids = {
    external = azurerm_route_table.rt[each.key].id
    internal = azurerm_route_table.rt[each.key].id
  }

  tags = {
    Name      = format("%s-vnet-%s-%s", var.resourceOwner, each.key, random_id.buildSuffix.hex)
    Terraform = "true"
  }
}

############################ VNet Peering - Transit Mesh ############################

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

############################ VNet Peering - BU to Transit ############################

# BU to Transit BU11 Peering
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

# BU to Transit BU12 Peering
resource "azurerm_virtual_network_peering" "peer12_1" {
  name                      = "peer12toTransit12"
  resource_group_name       = azurerm_resource_group.rg["bu12"].name
  virtual_network_name      = module.network["bu12"].vnet_name
  remote_virtual_network_id = module.network["transitBu12"].vnet_id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "peer12_2" {
  name                      = "peerTransit12to12"
  resource_group_name       = azurerm_resource_group.rg["transitBu12"].name
  virtual_network_name      = module.network["transitBu12"].vnet_name
  remote_virtual_network_id = module.network["bu12"].vnet_id
  allow_forwarded_traffic   = true
}

# BU to Transit BU13 Peering
resource "azurerm_virtual_network_peering" "peer13_1" {
  name                      = "peer13toTransit13"
  resource_group_name       = azurerm_resource_group.rg["bu13"].name
  virtual_network_name      = module.network["bu13"].vnet_name
  remote_virtual_network_id = module.network["transitBu13"].vnet_id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "peer13_2" {
  name                      = "peerTransit13to13"
  resource_group_name       = azurerm_resource_group.rg["transitBu13"].name
  virtual_network_name      = module.network["transitBu13"].vnet_name
  remote_virtual_network_id = module.network["bu13"].vnet_id
  allow_forwarded_traffic   = true
}

############################ Route Tables ############################

# Set locals
locals {
  routes = {
    bu11 = {
      nextHop = data.azurerm_network_interface.sliBu11.private_ip_address
    }
    bu12 = {
      nextHop = data.azurerm_network_interface.sliBu12.private_ip_address
    }
    bu13 = {
      nextHop = data.azurerm_network_interface.sliBu13.private_ip_address
    }
    transitBu11 = {
      nextHop = data.azurerm_network_interface.sliBu11.private_ip_address
    }
    transitBu12 = {
      nextHop = data.azurerm_network_interface.sliBu12.private_ip_address
    }
    transitBu13 = {
      nextHop = data.azurerm_network_interface.sliBu13.private_ip_address
    }
  }
}

# Create route tables
resource "azurerm_route_table" "rt" {
  for_each                      = local.businessUnits
  name                          = format("%s-rt-%s-%s", var.projectPrefix, each.key, random_id.buildSuffix.hex)
  location                      = azurerm_resource_group.rg[each.key].location
  resource_group_name           = azurerm_resource_group.rg[each.key].name
  disable_bgp_route_propagation = false

  tags = {
    Name      = format("%s-rt-%s-%s", var.resourceOwner, each.key, random_id.buildSuffix.hex)
    Terraform = "true"
  }
}

# Collect Volterra node "inside" NIC data
data "azurerm_network_interface" "sliBu11" {
  name                = "master-0-sli"
  resource_group_name = format("%s-bu11-volterra-%s", var.volterraUniquePrefix, random_id.buildSuffix.hex)
  depends_on          = [volterra_tf_params_action.applyBu11]
}

data "azurerm_network_interface" "sliBu12" {
  name                = "master-0-sli"
  resource_group_name = format("%s-bu12-volterra-%s", var.volterraUniquePrefix, random_id.buildSuffix.hex)
  depends_on          = [volterra_tf_params_action.applyBu12]
}

data "azurerm_network_interface" "sliBu13" {
  name                = "master-0-sli"
  resource_group_name = format("%s-bu13-volterra-%s", var.volterraUniquePrefix, random_id.buildSuffix.hex)
  depends_on          = [volterra_tf_params_action.applyBu13]
}

# Create routes
resource "azurerm_route" "rt" {
  for_each               = local.routes
  name                   = "volterra_gateway"
  resource_group_name    = azurerm_resource_group.rg[each.key].name
  route_table_name       = azurerm_route_table.rt[each.key].name
  address_prefix         = "100.64.101.0/24"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = each.value["nextHop"]
}

############################ Security Groups - Volterra CE Nodes ############################

# Set locals
locals {
  nsgVolterra = {
    bu11 = {
      sourceAddress = local.businessUnits["transitBu11"].subnetPrefixes[1]
    }
    bu12 = {
      sourceAddress = local.businessUnits["transitBu12"].subnetPrefixes[1]
    }
    bu13 = {
      sourceAddress = local.businessUnits["transitBu13"].subnetPrefixes[1]
    }
    transitBu11 = {
      sourceAddress = local.businessUnits["transitBu11"].subnetPrefixes[1]
    }
    transitBu12 = {
      sourceAddress = local.businessUnits["transitBu12"].subnetPrefixes[1]
    }
    transitBu13 = {
      sourceAddress = local.businessUnits["transitBu13"].subnetPrefixes[1]
    }
  }
}

# Allow Volterra CE nodes into network
resource "azurerm_network_security_group" "allow_ce" {
  for_each            = local.nsgVolterra
  name                = format("%s-nsg-allow-ce-%s", var.projectPrefix, random_id.buildSuffix.hex)
  location            = azurerm_resource_group.rg[each.key].location
  resource_group_name = azurerm_resource_group.rg[each.key].name

  security_rule {
    name                       = "allow-ingress-ce"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = each.value["sourceAddress"]
    destination_address_prefix = "*"
  }

  tags = {
    Name      = format("%s-nsg-allow-ce-%s", var.resourceOwner, random_id.buildSuffix.hex)
    Terraform = "true"
  }
}

############################ Security Groups - Jumphost, Web Servers ############################

# Set locals
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

# Allow jumphost access
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

# Allow webserver access
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
