# 1. PROVIDER SETUP
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 2. BRAND NEW RESOURCE GROUP 
resource "azurerm_resource_group" "sentinel_rg" {
  name     = "Sentinel-Project-Final"
  location = "Central India"
}

# 3. MONITORING HUB
resource "azurerm_log_analytics_workspace" "sentinel_law" {
  name                = "sentinel-logs-satnam"
  location            = azurerm_resource_group.sentinel_rg.location
  resource_group_name = azurerm_resource_group.sentinel_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# 4. NETWORKING
resource "azurerm_virtual_network" "sentinel_vnet" {
  name                = "sentinel-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.sentinel_rg.location
  resource_group_name = azurerm_resource_group.sentinel_rg.name
}

resource "azurerm_subnet" "sentinel_subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.sentinel_rg.name
  virtual_network_name = azurerm_virtual_network.sentinel_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "sentinel_nic" {
  name                = "sentinel-nic"
  location            = azurerm_resource_group.sentinel_rg.location
  resource_group_name = azurerm_resource_group.sentinel_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sentinel_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# 5. VIRTUAL MACHINE (Ubuntu 24.04 + Trusted Launch)
resource "azurerm_linux_virtual_machine" "sentinel_vm" {
  name                            = "Sentinel-Server"
  resource_group_name             = azurerm_resource_group.sentinel_rg.name
  location                        = azurerm_resource_group.sentinel_rg.location
  size                            = "Standard_D2as_v5" 
  admin_username                  = "adminuser"
  admin_password                  = "P@ssw0rd1234!" 
  disable_password_authentication = false
  
  # Trusted Launch Settings
  secure_boot_enabled = true
  vtpm_enabled        = true

  network_interface_ids = [
    azurerm_network_interface.sentinel_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}
