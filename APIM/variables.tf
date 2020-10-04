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