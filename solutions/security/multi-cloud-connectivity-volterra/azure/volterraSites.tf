provider "volterra" {
}

############################ Azure Subnet Names ############################

data "azurerm_subnet" "transitBu11_outside" {
  name                 = "external"
  virtual_network_name = module.network["transitBu11"].vnet_name
  resource_group_name  = azurerm_resource_group.rg["transitBu11"].name
}

data "azurerm_subnet" "transitBu11_inside" {
  name                 = "internal"
  virtual_network_name = module.network["transitBu11"].vnet_name
  resource_group_name  = azurerm_resource_group.rg["transitBu11"].name
}


############################ Volterra Azure VNet Sites ############################

resource "volterra_azure_vnet_site" "bu11" {
  name         = "${var.volterraUniquePrefix}-bu11"
  namespace    = "system"
  azure_region = azurerm_resource_group.rg["transitBu11"].location

  azure_cred {
    name      = var.volterraCloudCred
    namespace = "system"
    tenant    = var.volterraTenant
  }

  logs_streaming_disabled = true
  resource_group          = azurerm_resource_group.rg["transitBu11"].name

  ingress_egress_gw {
    azure_certified_hw = "azure-byol-multi-nic-voltmesh"

    az_nodes {
      azure_az  = "1"
      disk_size = "disk_size"

      inside_subnet {
        subnet {
          subnet_name = data.azurerm_subnet.transitBu11_inside.name
        }
      }
      outside_subnet {
        subnet {
          subnet_name = data.azurerm_subnet.transitBu11_outside.name
        }
      }
    }
  }

  vnet {
    existing_vnet {
      resource_group = azurerm_resource_group.rg["transitBu11"].name
      vnet_name      = module.network["transitBu11"].vnet_name
    }
  }
}


# resource "volterra_tf_params_action" "applyBu11" {
#   count            = var.assisted ? 0 : 1
#   site_name        = volterra_azure_vnet_site.bu11.name
#   site_kind        = "azure_vnet_site"
#   action           = "plan"
#   wait_for_action  = true
#   ignore_on_update = false
# }

