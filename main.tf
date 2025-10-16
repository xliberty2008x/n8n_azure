# main.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.17.0"
    }
  }
}


provider "kubernetes" {
  config_path = "~/.kube/config"

  host                   = azurerm_kubernetes_cluster.main.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)
}

provider "azurerm" {
  features {}
  # subscription_id is required even with CLI auth
  subscription_id = var.subscription_id
  # When using ARM_USE_CLI=true (GitHub Actions), do not set client credentials
  # When running locally with service principal, uncomment these lines:
  # client_id       = var.client_id
  # client_secret   = var.client_secret
  # tenant_id       = var.tenant_id
}

resource "azurerm_resource_group" "main" {
  name     = "n8n_bs"
  location = "East US 2"
}

resource "azurerm_network_security_group" "main" {
  name                = "n8n-security-group"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

// ... existing code ...

resource "azurerm_virtual_network" "main" {
  name                = "n8n-network"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/8"]
  dns_servers         = ["10.1.0.4", "10.1.0.5"]

  tags = {
    environment = "Production"
  }
}

// resource "azurerm_private_dns_zone" "postgres" {
//   name                = "example.postgres.database.azure.com"
//   resource_group_name = azurerm_resource_group.main.name
// }

// resource "azurerm_subnet_network_security_group_association" "subnetA_nsg" {
//   subnet_id                 = azurerm_subnet.subnetA.id
//   network_security_group_id = azurerm_network_security_group.main.id
// }

// resource "azurerm_subnet" "subnetA" {
//   name                 = "subnetA"
//   resource_group_name  = azurerm_resource_group.main.name
//   virtual_network_name = azurerm_virtual_network.main.name
//   address_prefixes     = ["10.1.1.0/24"]

//   delegation {
//     name = "aciDelegation"
//     service_delegation {
//       name    = "Microsoft.ContainerInstance/containerGroups"
//       actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
//     }
//   }
// }

// resource "azurerm_subnet" "subnetB" {
//   name                 = "subnetB"
//   resource_group_name  = azurerm_resource_group.main.name
//   virtual_network_name = azurerm_virtual_network.main.name
//   address_prefixes     = ["10.1.2.0/24"]
//   service_endpoints    = ["Microsoft.Storage"]
//   delegation {
//     name = "fs"
//     service_delegation {
//       name = "Microsoft.DBforPostgreSQL/flexibleServers"
//       actions = [
//         "Microsoft.Network/virtualNetworks/subnets/join/action",
//       ]
//     }
//   }
// }
