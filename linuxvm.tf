# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.97.1"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}

resource "tls_private_key" "linuxkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "linuxkey" {
  content  = tls_private_key.linuxkey.private_key_pem
  filename = "/Users/tamika/Documents/keys/linuxkey.pem"
}

# Create a resource group
resource "azurerm_resource_group" "rancher" {
  name     = "rancher-rg"
  location = "West US"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "rancher" {
  name                = "rancher-vnet"
  resource_group_name = azurerm_resource_group.rancher.name
  location            = azurerm_resource_group.rancher.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "rancher" {
  name                 = "rancher-subnet"
  resource_group_name  = azurerm_resource_group.rancher.name
  virtual_network_name = azurerm_virtual_network.rancher.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "rancherpubip" {
  count               = 2
  name                = "ranchersrv-pub-ip-${count.index + 1}"
  resource_group_name = azurerm_resource_group.rancher.name
  location            = azurerm_resource_group.rancher.location
  allocation_method   = "Dynamic"
  domain_name_label = "ranchersrv-${count.index + 1}"
}

resource "azurerm_network_interface" "rancher" {
  count               = 2
  name                = "rancher-nic-${count.index}"
  location            = azurerm_resource_group.rancher.location
  resource_group_name = azurerm_resource_group.rancher.name

  ip_configuration {
    name                          = "rancherip"
    subnet_id                     = azurerm_subnet.rancher.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = "${azurerm_public_ip.rancherpubip[count.index].id}"
  }
}


# Create Network Security Group and rule
resource "azurerm_network_security_group" "ranchernsg" {
  name                = "rancher-nsg"
  location            = azurerm_resource_group.rancher.location
  resource_group_name = azurerm_resource_group.rancher.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ALLOW9345"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9345"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ALLOW6443"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ALLOW8472"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "8472"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ALLOW10250"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "10250"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ALLOW2379"
    priority                   = 1006
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "2379"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ALLOW2380"
    priority                   = 1007
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "2380"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ALLOW30000-32767"
    priority                   = 1008
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "30000-32767"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ALLOW5473"
    priority                   = 1009
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5473"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ALLOW80"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ALLOW443"
    priority                   = 1011
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "ALLOW4789"
    priority                   = 1012
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "4789"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "ALLOW10254"
    priority                   = 1013
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "10254"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ALLOW8080"
    priority                   = 1014
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface_security_group_association" "rancher" {
  count                     = 2
  network_interface_id      = azurerm_network_interface.rancher[count.index].id
  network_security_group_id = azurerm_network_security_group.ranchernsg.id
}

resource "azurerm_linux_virtual_machine" "rancher" {
  count               = 2
  name                = "ranchersrv-${count.index + 1}"
  resource_group_name = azurerm_resource_group.rancher.name
  location            = azurerm_resource_group.rancher.location
  size                = "Standard_B4ms"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.rancher[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"

  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }


  computer_name = "ranchersrv-${count.index + 1}"


  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.linuxkey.public_key_openssh
  }

  depends_on = [tls_private_key.linuxkey]


}