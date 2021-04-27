variable "execution_role_arn" {
  type    = string  
}

# variable "task_role_arn" {
#   type    = string 
# }

variable "image_url_with_tag" {
  type = string
}

variable "app_name" {
  type    = string  
}

variable "environment" {
  type    = string  
}

variable "standard_tags" {
  type = object({})
}

variable "application_version" {
  type    = string
  default = "0"
}

variable "container_port" {
  type    = number
  default = 80
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
  default = 1
}

variable "health_check_period" {
  type    = number
  default = 3
}

variable "lb_target_group_arn" {
    type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}