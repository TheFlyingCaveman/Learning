variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cdir_block" {
  type    = string
  default = "172.31.0.0/16"
}

variable "private_subnet" {
  type = list(object({
    cidr_block        = string,
    availability_zone = string
  }))
  default = [{
    cidr_block        = "172.31.80.0/20",
    availability_zone = "us-east-1d"
  }] 
}

variable "liquibaseDownloadUrl" {
  type    = string
  description = "A link to the Liquibase tar.gz"
  default = "https://github.com/liquibase/liquibase/releases/download/v4.2.2/liquibase-4.2.2.tar.gz"
}

variable "ec2type" {
  type = string
  default = "t2.micro"
}