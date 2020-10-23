resource "azurerm_application_insights" "fplan_api_ai" {
  name                = "${local.full_prefix}-fplan-api-ai"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "other"
}

resource "azurerm_api_management_api" "funcapi" {
  name                  = "${local.full_prefix}-func"
  resource_group_name   = azurerm_resource_group.rg.name
  api_management_name   = azurerm_api_management.apim.name
  revision              = "1"
  display_name          = "Func API"
  path                  = "somefunc"
  protocols             = ["https"]
  subscription_required = true
}

resource "azurerm_api_management_logger" "funcapi_logger" {
  name                = "funcapi-apimlogger"
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.rg.name

  application_insights {
    instrumentation_key = azurerm_application_insights.fplan_api_ai.instrumentation_key
  }
}

resource "azurerm_api_management_api_diagnostic" "funcapi_diagnostic" {
  identifier               = "applicationinsights"
  resource_group_name      = azurerm_resource_group.rg.name
  api_management_name      = azurerm_api_management.apim.name
  api_name                 = azurerm_api_management_api.funcapi.name
  api_management_logger_id = azurerm_api_management_logger.funcapi_logger.id
}

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
  kind                = "functionapp"

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
      name                      = "Allow APIM subnet"
      virtual_network_subnet_id = azurerm_subnet.sub_apim.id
      priority                  = 100
    }

    dynamic "ip_restriction" {
      for_each = azurerm_api_management.apim.public_ip_addresses

      content {
        name       = "Allow APIM Public IP ${ip_restriction.key}"
        ip_address = "${ip_restriction.value}/32"
        priority   = 1 + ip_restriction.key
      }
    }
  }
}
