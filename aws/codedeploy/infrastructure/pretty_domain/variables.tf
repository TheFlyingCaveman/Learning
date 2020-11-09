variable "aws_route53_zone_name" {
  type = string
}

variable "aws_route53_record_name" {
  type = string
}

variable "lb" {
  type = object({
    dns_name : string
    zone_id : string
  })
}
