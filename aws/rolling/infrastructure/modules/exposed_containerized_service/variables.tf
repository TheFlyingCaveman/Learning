variable "execution_role_arn" {
  type = string
}

variable "image_url_with_tag" {
  type = string
}

variable "app_name" {
  type = string
}

variable "environment" {
  type = string
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
  default = 2
  description = "The amount of containers to run at initial launch. Defaults to 2 to allow for multiple availability zones."
}

variable "health_check_period" {
  type    = number
  default = 3
}

variable "lb_target_group_arn" {
  type        = string
  default     = null
  description = "Associates a load balancer with the ECS Service. Note that updating this after initial creation forces replacement, which will incur downtime."
}

variable "additional_ecs_task_security_group_ids" {
  type        = list(string)
  description = "Security Groups to be used *in addition to* the group created to allow traffic from the load balancer."
  default     = []
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "pretty_domain" {
  type = object({
    aws_route53_zone_name : string
    aws_route53_record_name : string
  })
  description = "If set, a new A record that points at the load balancer is added to the specified AWS DNS zone."
  default     = null
}

variable "vpc_id" {
  type = string
}

variable "ecs_cluster_id" {
  type = string
}

variable "private_dns_namespace_id" {
  type = string
}