provider "azurerm" {
  features {}
}

############################ Resource Groups ############################

# bu11 Resource Group
resource "azurerm_resource_group" "bu11" {
  name     = format("%s-rgBu11-%s", var.projectPrefix, random_id.buildSuffix.hex)
  location = var.azureLocation

  tags = {
    Name      = format("%s-rgBu11-%s", var.resourceOwner, random_id.buildSuffix.hex)
    Terraform = "true"
  }
}

# bu12 Resource Group
resource "azurerm_resource_group" "bu12" {
  name     = format("%s-rgBu12-%s", var.projectPrefix, random_id.buildSuffix.hex)
  location = var.azureLocation

  tags = {
    Name      = format("%s-rgBu12-%s", var.resourceOwner, random_id.buildSuffix.hex)
    Terraform = "true"
  }
}

# bu13 Resource Group
resource "azurerm_resource_group" "bu13" {
  name     = format("%s-rgBu13-%s", var.projectPrefix, random_id.buildSuffix.hex)
  location = var.azureLocation

  tags = {
    Name      = format("%s-rgBu13-%s", var.resourceOwner, random_id.buildSuffix.hex)
    Terraform = "true"
  }
}


############################ VNets ############################

module "vnetTransitBu11" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.bu11.name
  vnet_name           = format("%s-vnetTransitBu11-%s", var.projectPrefix, random_id.buildSuffix.hex)
  address_space       = "100.64.48.0/20"
  subnet_prefixes     = ["100.64.48.0/24", "100.64.49.0/24", "100.64.50.0/24"]
  subnet_names        = ["external", "internal", "workload"]

  tags = {
    Name      = format("%s-vnetTransitBu11-%s", var.resourceOwner, random_id.buildSuffix.hex)
    Terraform = "true"
  }

  depends_on = [azurerm_resource_group.bu11]
}

module "vnetTransitBu12" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.bu12.name
  vnet_name           = format("%s-vnetTransitBu12-%s", var.projectPrefix, random_id.buildSuffix.hex)
  address_space       = "100.64.64.0/20"
  subnet_prefixes     = ["100.64.64.0/24", "100.64.65.0/24", "100.64.66.0/24"]
  subnet_names        = ["external", "internal", "workload"]

  tags = {
    Name      = format("%s-vnetTransitBu12-%s", var.resourceOwner, random_id.buildSuffix.hex)
    Terraform = "true"
  }

  depends_on = [azurerm_resource_group.bu12]
}

module "vnetTransitBu13" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.bu13.name
  vnet_name           = format("%s-vnetTransitBu13-%s", var.projectPrefix, random_id.buildSuffix.hex)
  address_space       = "100.64.80.0/20"
  subnet_prefixes     = ["100.64.80.0/24", "100.64.81.0/24", "100.64.82.0/24"]
  subnet_names        = ["external", "internal", "workload"]

  tags = {
    Name      = format("%s-vnetTransitBu13-%s", var.resourceOwner, random_id.buildSuffix.hex)
    Terraform = "true"
  }

  depends_on = [azurerm_resource_group.bu13]
}

module "vnetBu11" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.bu11.name
  vnet_name           = format("%s-vnetBu11-%s", var.projectPrefix, random_id.buildSuffix.hex)
  address_space       = "10.1.0.0/16"
  subnet_prefixes     = ["10.1.10.0/24", "10.1.52.0/24"]
  subnet_names        = ["external", "internal"]

  tags = {
    Name      = format("%s-vnetBu11-%s", var.resourceOwner, random_id.buildSuffix.hex)
    Terraform = "true"
  }

  depends_on = [azurerm_resource_group.bu11]
}

module "vnetBu12" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.bu12.name
  vnet_name           = format("%s-vnetBu12-%s", var.projectPrefix, random_id.buildSuffix.hex)
  address_space       = "10.1.0.0/16"
  subnet_prefixes     = ["10.1.10.0/24", "10.1.52.0/24"]
  subnet_names        = ["external", "internal"]

  tags = {
    Name      = format("%s-vnetBu12-%s", var.resourceOwner, random_id.buildSuffix.hex)
    Terraform = "true"
  }

  depends_on = [azurerm_resource_group.bu12]
}

module "vnetBu13" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.bu13.name
  vnet_name           = format("%s-vnetBu13-%s", var.projectPrefix, random_id.buildSuffix.hex)
  address_space       = "10.1.0.0/16"
  subnet_prefixes     = ["10.1.10.0/24", "10.1.52.0/24"]
  subnet_names        = ["external", "internal"]

  tags = {
    Name      = format("%s-vnetBu13-%s", var.resourceOwner, random_id.buildSuffix.hex)
    Terraform = "true"
  }

  depends_on = [azurerm_resource_group.bu13]
}


############################ Route Tables ############################

resource "azurerm_route_table" "transitBu11" {
  name                          = format("%s-udrTransitBu11-%s", var.projectPrefix, random_id.buildSuffix.hex)
  location                      = var.azureLocation
  resource_group_name           = azurerm_resource_group.bu11.name
  disable_bgp_route_propagation = false

  route {
    name                   = "volterra_gateway"
    address_prefix         = "100.64.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.64.1.10"
  }

  tags = {
    Name      = format("%s-udrTransitBu11-%s", var.resourceOwner, random_id.buildSuffix.hex)
    Terraform = "true"
  }

  #depends_on = [volterra_tf_params_action.applyBu11]
}

resource "azurerm_route_table" "transitBu12" {
  name                          = format("%s-udrTransitBu12-%s", var.projectPrefix, random_id.buildSuffix.hex)
  location                      = var.azureLocation
  resource_group_name           = azurerm_resource_group.bu12.name
  disable_bgp_route_propagation = false

  route {
    name                   = "volterra_gateway"
    address_prefix         = "100.64.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.64.1.10"
  }

  tags = {
    Name      = format("%s-udrTransitBu12-%s", var.resourceOwner, random_id.buildSuffix.hex)
    Terraform = "true"
  }

  #depends_on = [volterra_tf_params_action.applyBu11]
}

resource "azurerm_route_table" "transitBu13" {
  name                          = format("%s-udrTransitBu13-%s", var.projectPrefix, random_id.buildSuffix.hex)
  location                      = var.azureLocation
  resource_group_name           = azurerm_resource_group.bu13.name
  disable_bgp_route_propagation = false

  route {
    name                   = "volterra_gateway"
    address_prefix         = "100.64.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.64.1.10"
  }

  tags = {
    Name      = format("%s-udrTransitBu13-%s", var.resourceOwner, random_id.buildSuffix.hex)
    Terraform = "true"
  }

  #depends_on = [volterra_tf_params_action.applyBu11]
}

resource "azurerm_route_table" "bu11" {
  name                          = format("%s-udrBu11-%s", var.projectPrefix, random_id.buildSuffix.hex)
  location                      = var.azureLocation
  resource_group_name           = azurerm_resource_group.bu11.name
  disable_bgp_route_propagation = false

  route {
    name                   = "volterra_gateway"
    address_prefix         = "100.64.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.64.1.10"
  }

  tags = {
    Name      = format("%s-udrBu11-%s", var.resourceOwner, random_id.buildSuffix.hex)
    Terraform = "true"
  }

  #depends_on = [volterra_tf_params_action.applyBu11]
}

resource "azurerm_route_table" "bu12" {
  name                          = format("%s-udrBu12-%s", var.projectPrefix, random_id.buildSuffix.hex)
  location                      = var.azureLocation
  resource_group_name           = azurerm_resource_group.bu12.name
  disable_bgp_route_propagation = false

  route {
    name                   = "volterra_gateway"
    address_prefix         = "100.64.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.64.1.10"
  }

  tags = {
    Name      = format("%s-udrBu12-%s", var.resourceOwner, random_id.buildSuffix.hex)
    Terraform = "true"
  }

  #depends_on = [volterra_tf_params_action.applyBu11]
}

resource "azurerm_route_table" "bu13" {
  name                          = format("%s-udrBu13-%s", var.projectPrefix, random_id.buildSuffix.hex)
  location                      = var.azureLocation
  resource_group_name           = azurerm_resource_group.bu13.name
  disable_bgp_route_propagation = false

  route {
    name                   = "volterra_gateway"
    address_prefix         = "100.64.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.64.1.10"
  }

  tags = {
    Name      = format("%s-udrBu13-%s", var.resourceOwner, random_id.buildSuffix.hex)
    Terraform = "true"
  }

  #depends_on = [volterra_tf_params_action.applyBu11]
}


############################ Locals for Compute ############################

locals {

  jumphosts = {
    bu11Jumphost = {
      resourceGroup = azurerm_resource_group.bu11.name
      subnet        = module.vnetBu11.vnet_subnets[0]
    }
    bu12Jumphost = {
      resourceGroup = azurerm_resource_group.bu12.name
      subnet        = module.vnetBu12.vnet_subnets[0]
    }
    bu13Jumphost = {
      resourceGroup = azurerm_resource_group.bu13.name
      subnet        = module.vnetBu13.vnet_subnets[0]
    }
    # transitBu11Jumphost = {
    #   resourceGroup = azurerm_resource_group.bu11.name
    #   subnet        = module.vnetBu11.vnet_subnets[0]
    # }
    # transitBu12Jumphost = {
    #   resourceGroup = azurerm_resource_group.bu12.name
    #   subnet        = module.vnetBu12.vnet_subnets[0]
    # }
    # transitBu13Jumphost = {
    #   resourceGroup = azurerm_resource_group.bu13.name
    #   subnet        = module.vnetBu13.vnet_subnets[0]
    # }
  }

  webservers = {
    bu11App1 = {
      resourceGroup = azurerm_resource_group.bu11.name
      subnet        = module.vnetBu11.vnet_subnets[1]
    }
    bu12App1 = {
      resourceGroup = azurerm_resource_group.bu12.name
      subnet        = module.vnetBu12.vnet_subnets[1]
    }
    bu13App1 = {
      resourceGroup = azurerm_resource_group.bu13.name
      subnet        = module.vnetBu13.vnet_subnets[1]
    }
  }

}


############################ Security Groups ############################

resource "azurerm_network_security_group" "jumphost" {
  for_each            = local.jumphosts
  name                = format("%s-nsgJumphost-%s", var.projectPrefix, random_id.buildSuffix.hex)
  location            = var.azureLocation
  resource_group_name = each.value["resourceGroup"]

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
    Name      = format("%s-nsgJumphost-%s", var.resourceOwner, random_id.buildSuffix.hex)
    Terraform = "true"
  }
}

resource "azurerm_network_security_group" "webserver" {
  for_each            = local.webservers
  name                = format("%s-nsgWebservers-%s", var.projectPrefix, random_id.buildSuffix.hex)
  location            = var.azureLocation
  resource_group_name = each.value["resourceGroup"]

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
    Name      = format("%s-nsgWebservers-%s", var.resourceOwner, random_id.buildSuffix.hex)
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
  azureResourceGroup = each.value["resourceGroup"]
  azureLocation      = var.azureLocation
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
  azureResourceGroup = each.value["resourceGroup"]
  azureLocation      = var.azureLocation
  keyName            = var.keyName
  subnet             = each.value["subnet"]
  securityGroup      = azurerm_network_security_group.webserver[each.key].id
}
