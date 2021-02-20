resource "aws_elastic_beanstalk_application" "app" {
  name        = var.name
  description = var.description

  tags = {
    ENVIRONMENT = var.environment
  }
}

resource "aws_elastic_beanstalk_environment" "env" {
  name                = var.name
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = var.solution_stack_name

#   setting {
#     namespace = "aws:ec2:vpc"
#     name      = "VPCId"
#     value     = "vpc-xxxxxxxx"
#   }

#   setting {
#     namespace = "aws:ec2:vpc"
#     name      = "Subnets"
#     value     = "subnet-xxxxxxxx"
#   }

  tags = {
    ENVIRONMENT = var.environment
  }
}
