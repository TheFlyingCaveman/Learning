variable "region" {
  type    = string
  default = "us-east-1"
}

variable "product_name" {
  type = string
  description = "In this context, a Product is a collection of Services. Product resources may be shared by individual Services."
  default = "TheItemShop"
}

variable "environment" {
  type    = string
  default = "NonProd"
}