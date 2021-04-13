output "bu11JumphostPublicIp" {
  description = "BU11 Jumphost Public IP"
  value = module.jumphost[*].bu11Jumphost.publicIp
}
output "bu12JumphostPublicIp" {
  description = "BU12 Jumphost Public IP"
  value = module.jumphost[*].bu12Jumphost.publicIp
}
output "bu13JumphostPublicIp" {
  description = "BU13 Jumphost Public IP"
  value = module.jumphost[*].bu13Jumphost.publicIp
}
output "bu11WebServerIP" {
  description = "BU11 Web Server Private IP"
  value = module.webserver[*].bu11App1.privateIp
}
output "bu12WebServerIP" {
  description = "BU12 Web Server Private IP"
  value = module.webserver[*].bu12App1.privateIp
}
output "bu13WebServerIP" {
  description = "BU13 Web Server Private IP"
  value = module.webserver[*].bu13App1.privateIp
}
output "vnetIdBu11" {
  description = "BU11 VNet ID"
  value       = module.vnetBu11.vnet_id
}
output "vnetIdBu12" {
  description = "BU12 VNet ID"
  value       = module.vnetBu12.vnet_id
}
output "vnetIdBu13" {
  description = "BU13 VNet ID"
  value       = module.vnetBu13.vnet_id
}
