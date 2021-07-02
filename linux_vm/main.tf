provider "azurerm" {
  features {}
}

data "azurerm_key_vault_secret" "resourcegroupname" {
name         = "resourcegroupname"
key_vault_id = "/subscriptions/4a5b5785-dec0-4465-a13b-794c650c26d1/resourceGroups/kopicloud-tstate-rg/providers/Microsoft.KeyVault/vaults/secretkeyvalut1"
}

data "azurerm_key_vault_secret" "resourcegrouplocation" {
name         = "resourcegrouplocation"
key_vault_id = "/subscriptions/4a5b5785-dec0-4465-a13b-794c650c26d1/resourceGroups/kopicloud-tstate-rg/providers/Microsoft.KeyVault/vaults/secretkeyvalut1"
}

data "azurerm_key_vault_secret" "virtualnetworkname" {
name         = "virtualnetworkname"
key_vault_id = "/subscriptions/4a5b5785-dec0-4465-a13b-794c650c26d1/resourceGroups/kopicloud-tstate-rg/providers/Microsoft.KeyVault/vaults/secretkeyvalut1"
}

data "azurerm_key_vault_secret" "subnetname" {
name         = "subnetname"
key_vault_id = "/subscriptions/4a5b5785-dec0-4465-a13b-794c650c26d1/resourceGroups/kopicloud-tstate-rg/providers/Microsoft.KeyVault/vaults/secretkeyvalut1"
}

data "azurerm_key_vault_secret" "publicipname" {
name         = "publicipname"
key_vault_id = "/subscriptions/4a5b5785-dec0-4465-a13b-794c650c26d1/resourceGroups/kopicloud-tstate-rg/providers/Microsoft.KeyVault/vaults/secretkeyvalut1"
}

data "azurerm_key_vault_secret" "networksecuritygroupname" {
name         = "networksecuritygroupname"
key_vault_id = "/subscriptions/4a5b5785-dec0-4465-a13b-794c650c26d1/resourceGroups/kopicloud-tstate-rg/providers/Microsoft.KeyVault/vaults/secretkeyvalut1"
}

data "azurerm_key_vault_secret" "networkinterfacename" {
name         = "networkinterfacename"
key_vault_id = "/subscriptions/4a5b5785-dec0-4465-a13b-794c650c26d1/resourceGroups/kopicloud-tstate-rg/providers/Microsoft.KeyVault/vaults/secretkeyvalut1"
}

data "azurerm_key_vault_secret" "linuxvirtualmachinename" {
name         = "linuxvirtualmachinename"
key_vault_id = "/subscriptions/4a5b5785-dec0-4465-a13b-794c650c26d1/resourceGroups/kopicloud-tstate-rg/providers/Microsoft.KeyVault/vaults/secretkeyvalut1"
}


# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "rg" {
  name     = data.azurerm_key_vault_secret.resourcegroupname.value
  location = data.azurerm_key_vault_secret.resourcegrouplocation.value
  
  tags = {
    environment = "salman",
    purpose = "testing"

  }
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = data.azurerm_key_vault_secret.virtualnetworkname.value
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_key_vault_secret.resourcegrouplocation.value
  resource_group_name = data.azurerm_key_vault_secret.resourcegroupname.value
  depends_on = [azurerm_resource_group.rg]

  tags = {
    environment = "salman"
  }
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = data.azurerm_key_vault_secret.subnetname.value
  resource_group_name  = data.azurerm_key_vault_secret.resourcegroupname.value
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on = [azurerm_resource_group.rg]

}

# Create public IPs
resource "azurerm_public_ip" "public_ip" {
  name                = data.azurerm_key_vault_secret.publicipname.value
  location            = data.azurerm_key_vault_secret.resourcegrouplocation.value
  resource_group_name = data.azurerm_key_vault_secret.resourcegroupname.value
  allocation_method   = "Dynamic"
  depends_on = [azurerm_resource_group.rg]
  tags = {
    environment = "salman"
  }
}

resource "azurerm_public_ip" "public_ipsec" {
  name                = "public_ipsec"
  location            = data.azurerm_key_vault_secret.resourcegrouplocation.value
  resource_group_name = data.azurerm_key_vault_secret.resourcegroupname.value
  allocation_method   = "Dynamic"
  depends_on = [azurerm_resource_group.rg]
  tags = {
    environment = "salman"
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = data.azurerm_key_vault_secret.networksecuritygroupname.value
  location            = data.azurerm_key_vault_secret.resourcegrouplocation.value
  resource_group_name = data.azurerm_key_vault_secret.resourcegroupname.value
  depends_on = [azurerm_resource_group.rg]

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

  tags = {
    environment = "salman"
  }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = data.azurerm_key_vault_secret.networkinterfacename.value
  location            = data.azurerm_key_vault_secret.resourcegrouplocation.value
  resource_group_name = data.azurerm_key_vault_secret.resourcegroupname.value
  depends_on = [azurerm_resource_group.rg]

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  tags = {
    environment = "salman"
  }
}


# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}



# Generate random text for a unique storage account name
#resource "random_id" "randomId" {
# keepers = {
# Generate a new ID only when a new resource group is defined
#  resource_group = azurerm_resource_group.rg.name
#}

#byte_length = 8
#}

# Create storage account for boot diagnostics
#resource "azurerm_storage_account" "storage" {
# name                     = "diag${random_id.randomId.hex}"
# resource_group_name      = azurerm_resource_group.rg.name
# location                 = azurerm_resource_group.rg.location
# account_tier             = "Standard"
# account_replication_type = "LRS"

# tags = {
#  environment = "production"
#}
#}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "linuxvm" {
  name                  = data.azurerm_key_vault_secret.linuxvirtualmachinename.value
  location              = data.azurerm_key_vault_secret.resourcegrouplocation.value
  resource_group_name   = data.azurerm_key_vault_secret.resourcegroupname.value
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_DS1_v2"
  depends_on = [azurerm_resource_group.rg]

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.example_ssh.public_key_openssh
  }

  ##boot_diagnostics {
  ##  storage_account_uri = azurerm_storage_account.storage.primary_blob_endpoint
  ##}

  #tags = {
  #  environment = "salman"
  #}
}


#create another resource
#data "azurerm_key_vault_secret" "resourcegroup" {
#name         = "resourcegroup"
#key_vault_id = "/subscriptions/4a5b5785-dec0-4465-a13b-794c650c26d1/resourceGroups/kopicloud-tstate-rg/providers/Microsoft.KeyVault/vaults/secretkeyvalut1"
#}

#data "azurerm_key_vault_secret" "resourcegrouplocations" {
#name         = "resourcegrouplocations"
#key_vault_id = "/subscriptions/4a5b5785-dec0-4465-a13b-794c650c26d1/resourceGroups/kopicloud-tstate-rg/providers/Microsoft.KeyVault/vaults/secretkeyvalut1"
#}

# Create a resource group if it doesn't exist
#resource "azurerm_resource_group" "rgs" {
  #name     = data.azurerm_key_vault_secret.resourcegroup.value
  #location = data.azurerm_key_vault_secret.resourcegrouplocations.value
  
  #tags = {
    #environment = "salman",
    #purpose = "testing"

  #}
#}


#create a terraform tf file
terraform {
  backend "azurerm" {
    resource_group_name   = "kopicloud-tstate-rg"
    storage_account_name  = "kopicloudtfstate2"
    container_name        = "tfstate2"
    key                   = "tf_state_file"
  }
}




