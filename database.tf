resource "azurerm_postgresql_flexible_server" "main" {
  name                   = "your_prefix-${random_string.aks_temporary_name.result}"
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  version                = "16"
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_login_password
  #delegated_subnet_id    = azurerm_subnet.subnetB.id
  #private_dns_zone_id    = azurerm_private_dns_zone.postgres.id
  storage_mb             = 32768
  sku_name               = "B_Standard_B1ms"
  backup_retention_days  = 7
  zone                   = "1"
  #public_network_access_enabled = false 


  depends_on = [
    azurerm_resource_group.main,
    azurerm_virtual_network.main,
  ]
}


resource "azurerm_postgresql_flexible_server_database" "main" {
  name       = var.postgres_database
  server_id  = azurerm_postgresql_flexible_server.main.id
  collation  = "en_US.utf8"
  charset    = "UTF8"
  depends_on = [azurerm_postgresql_flexible_server.main]
}
