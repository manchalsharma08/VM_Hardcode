resource "azurerm_resource_group" "rg" {
    count = 5
  name = "manmeet-rg-${count.index +1}"
  location = "westus"
}

resource "azurerm_virtual_network" "vnet" {
  name = "manmeet-vnet"
  resource_group_name = "manmeet-rg"
  location = "westus"
  address_space = ["10.0.0.0/16"]
  depends_on = [ azurerm_resource_group.rg ]
}

resource "azurerm_subnet" "snet" {
  name = "manmeet-snet"
  virtual_network_name = "manmeet-vnet"
  resource_group_name = "manmeet-rg"
  address_prefixes = ["10.0.1.0/24"]
depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_storage_account" "sa"{
    name = "manmeetsa54hgk123"
    resource_group_name = "manmeet-rg"
    location = "westus"
    account_tier = "Standard"
    account_replication_type = "GRS"
depends_on = [azurerm_subnet.snet]
}

resource "azurerm_storage_container" "con" {
  name                  = "manmeet-con"
  storage_account_name  = "manmeetsa54hgk123"
  container_access_type = "private"
  depends_on = [azurerm_storage_account.sa]
}

resource "azurerm_public_ip" "pip" {
    name = "manmeet-pip"
    location = "westus"
    resource_group_name = "manmeet-rg"
    allocation_method = "Static"
}
resource "azurerm_interface_network" "nic" {
    name = "manmeet-nic"
    location = "westus"
    resource_group_name = "manmeet-rg"

ip_configuration {
    name = "hiheloo"
    subnet_id = azurerm_subnet.snet.id
    private_ip_address_allocation= "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip.id
    
    
}
}
  
resource "linux_virtual_machine" "vm" {
    name = "manmeet-vm"
    location = "westus"
    resource_group_name = "manmeet-rg"
    size = "Standard-F2"
    admin_username = "manmeet123"
    admin_password = "manmeet@123"
    disable_password_authentication = "false"

    network_interface_ids = [azurerm_interface_network.nic.ids]

    
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}