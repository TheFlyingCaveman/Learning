locals {
  count_of_hybrid_connections = length(var.hybrid_connections)
  subscription_id             = data.azurerm_client_config.current.subscription_id
}

resource "azurerm_application_insights" "ai" {
  name                = "${local.full_prefix}-ai"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

resource "azurerm_app_service_plan" "plan" {
  name                = "${local.full_prefix}-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  is_xenon         = false
  kind             = "app"
  per_site_scaling = false
  reserved         = false

  sku {
    tier = var.app_service_plan_tier
    size = var.app_service_plan_size
  }
}

resource "azurerm_app_service" "app" {
  name                = "${local.full_prefix}-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.plan.id

  https_only              = true
  client_affinity_enabled = false

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on         = false
    ftps_state        = "Disabled"
    health_check_path = null
    http2_enabled     = true

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

resource "azurerm_relay_namespace" "relay" {
  name                = "${local.full_prefix}-relay"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name = "Standard"
}

resource "azurerm_relay_hybrid_connection" "hybrid_connection" {
  count                = local.count_of_hybrid_connections
  name                 = var.hybrid_connections[count.index].name
  resource_group_name  = azurerm_resource_group.rg.name
  relay_namespace_name = azurerm_relay_namespace.relay.name
  user_metadata = jsonencode([{
    "key"   = "endpoint",
    "value" = "${var.hybrid_connections[count.index].hostname}:${var.hybrid_connections[count.index].port}"
  }])
}

# Hybrid Connection Policy needed for HybridConnectionManager to function properly
resource "null_resource" "hybrid_connection_policy_send" {
  count = local.count_of_hybrid_connections
  provisioner "local-exec" {
    command = "az relay hyco authorization-rule create --subscription ${local.subscription_id} -g ${azurerm_resource_group.rg.name} --namespace-name ${azurerm_relay_namespace.relay.name} --hybrid-connection-name ${azurerm_relay_hybrid_connection.hybrid_connection[count.index].name} -n defaultSender --rights Send"
  }
}

# Hybrid Connection Policy needed for HybridConnectionManager to function properly
resource "null_resource" "hybrid_connection_policy_listen" {
  count = local.count_of_hybrid_connections
  provisioner "local-exec" {
    command = "az relay hyco authorization-rule create --subscription ${local.subscription_id} -g ${azurerm_resource_group.rg.name} --namespace-name ${azurerm_relay_namespace.relay.name} --hybrid-connection-name ${azurerm_relay_hybrid_connection.hybrid_connection[count.index].name} -n defaultListener --rights Listen"
  }
}

# Needed for AzureRM to work when setting the app_hybrid_connection, as azurerm_app_service_hybrid_connection incorrectly checks the existance of a key on the Relay instead
# of on the HC itself. 
resource "null_resource" "relay_policy_send" {
  provisioner "local-exec" {
    command = "az relay namespace authorization-rule create --subscription ${local.subscription_id} -g ${azurerm_resource_group.rg.name} --namespace-name ${azurerm_relay_namespace.relay.name} -n defaultSender --rights Send"
  }
}

resource "azurerm_app_service_hybrid_connection" "app_hybrid_connection" {
  count               = local.count_of_hybrid_connections
  depends_on          = [null_resource.hybrid_connection_policy_send, null_resource.hybrid_connection_policy_listen, null_resource.relay_policy_send]
  app_service_name    = azurerm_app_service.app.name
  resource_group_name = azurerm_resource_group.rg.name
  relay_id            = azurerm_relay_hybrid_connection.hybrid_connection[count.index].id
  hostname            = var.hybrid_connections[count.index].hostname
  port                = var.hybrid_connections[count.index].port
  # Terraform does not yet have the ability to nicely create Shared Access Policy keys for Relay :(
  send_key_name       = "defaultSender"
}

# There is a bug in the AzureRM Terraform provider where the sendKey value does not actually get set (see BugNotes.md)
# This causes the key to be swapped, forcing it to be set and valid
resource "null_resource" "hybrid_connection_key" {
  # Forcing it to occur after the App HCs are made as depends on does not work on "counted" resources alone
  count = length(azurerm_app_service_hybrid_connection.app_hybrid_connection)
  provisioner "local-exec" {
    command = "az appservice hybrid-connection set-key --subscription ${local.subscription_id} -g ${azurerm_resource_group.rg.name} --plan ${azurerm_app_service_plan.plan.name} --namespace  ${azurerm_relay_namespace.relay.name} --hybrid-connection ${azurerm_relay_hybrid_connection.hybrid_connection[count.index].name} --key-type primary"
  }
}