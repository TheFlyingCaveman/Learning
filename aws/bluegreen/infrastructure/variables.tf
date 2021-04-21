variable "region" {
  type    = string
  default = "us-east-1"
}

variable "app_name" {
  type    = string
  default = "sometestapp2"
}

variable "environment" {
  type    = string
  default = "nonprod"
}

variable "container_image" {
  type    = string
  default = "trfc/simpleweb:latest"
}

variable "container_port" {
  type    = number
  default = 80
}

variable "application_version" {
  type    = string
  default = "0"
}

variable "container_cpu_units" {
  type    = number
  default = 256
}

variable "container_memory" {
  type    = number
  default = 512
}

variable "desired_count" {
  type    = number
  default = 3
}

variable "health_check_period" {
  type    = number
  default = 3
}

variable "pretty_domain" {
  type = object({
    aws_route53_zone_name : string
    aws_route53_record_name : string
  })
  description = "If set, a new A record that points at the load balancer is added to the specified AWS DNS zone."
  default     = null
}