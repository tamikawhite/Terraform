output "public_ip_addresses" {
  value = {
    for instance in azurerm_linux_virtual_machine.rancher :
    instance.id => instance.public_ip_address
  }
}