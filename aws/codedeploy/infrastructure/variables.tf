variable "region" {
    type = string
    default = "us-east-1"
}

variable "vpc_cdir_block" {
    type = string
    default = "10.0.0.0/16"
}

variable "public_subnets" {
    type = list(object({
        cidr_block = string,
        availability_zone = string
    }))
    default = [
        {
            cidr_block = "10.0.0.0/24",
            availability_zone = "us-east-1a"
        },
        {
            cidr_block = "10.0.1.0/24",
            availability_zone = "us-east-1b"
        }
    ]
}

variable "count_of_ec2_instances_per_zone" {
    type = number
    default = 1
}