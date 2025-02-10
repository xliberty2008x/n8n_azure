# outputs.tf
//output "n8n_public_ip" {
//  value = azurerm_public_ip.n8n.ip_address
//}

//output "n8n_ui_url" {
  //value = "http://${azurerm_public_ip.n8n.ip_address}:5678"
//}

output "azurerm_postgresql_flexible_server" {
  value = azurerm_postgresql_flexible_server.main.name
}

output "postgresql_flexible_server_database_name" {
  value = azurerm_postgresql_flexible_server_database.main.name
}

output "postgresql_flexible_server_admin_password" {
  sensitive = true
  value     = azurerm_postgresql_flexible_server.main.administrator_password
}

