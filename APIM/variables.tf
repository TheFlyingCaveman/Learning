variable "resource_prefix" {
    type = string
    description = "Consistent prefix to be used accross resources. Strive for uniqueness."
}

variable "environment" {
    type = string
}

variable "location" {
    type = string
    description = "The location for the resource group and other resources."
}

variable "publisher_name" {
    type = string
}

variable "publisher_email" {
    type = string
}

variable "app_service_plan_size" {
    type = string
    description = "The SKU size for the App Service Plan"    
}

variable "app_service_plan_tier" {
    type = string
    description = "The SKU tier for the App Service Plan"    
}

variable "hybrid_connections" {
  type = list(object({
    hostname = string
    port = number
    name = string
  }))
  default = []
}