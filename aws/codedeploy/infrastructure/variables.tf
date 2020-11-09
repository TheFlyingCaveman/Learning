variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cdir_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type = list(object({
    cidr_block        = string,
    availability_zone = string
  }))
  default = [
    {
      cidr_block        = "10.0.0.0/24",
      availability_zone = "us-east-1a"
    },
    {
      cidr_block        = "10.0.1.0/24",
      availability_zone = "us-east-1b"
    }
  ]
}

variable "count_of_ec2_instances_per_zone" {
  type    = number
  default = 1
}

variable "codedeploy_user_iam_object" {
  type = object({
    groupName : string
    userName : string
    path : string
  })
  description = "If set, it creates an IAM group and user to with permissions to use CodeDeploy."
  default     = null
}

variable "pretty_domain" {
  type = object({
    aws_route53_zone_name : string
    aws_route53_record_name : string
  })
  description = "If set, a new A record that points at the load balancer is added to the specified AWS DNS zone."
  default     = null
}

variable "force_destroy_items" {
  type    = bool
  description = "Highly recommend to only set this to true for PoC work!"
  default = false
}
