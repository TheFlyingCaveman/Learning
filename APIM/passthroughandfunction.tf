resource "azurerm_storage_account" "function_storage" {
  name                     = replace("${local.full_prefix}fsa", "-", "")
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "fplan" {
  name                = "${local.full_prefix}-fsa"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind = "functionapp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "function" {
  name                       = "${local.full_prefix}-func"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.fplan.id
  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key

  site_config {
    ip_restriction {
      virtual_network_subnet_id = azurerm_subnet.sub_apim.id
    }
  }  
}
