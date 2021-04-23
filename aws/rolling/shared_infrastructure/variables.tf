variable "region" {
  type    = string
  default = "us-east-1"
}

variable "docker_hub_image_to_push" {
  type    = string
  default = "trfc/simpleweb"
}

variable "name_of_ecr_image" {
  type    = string
  default = "simpleweb"
}