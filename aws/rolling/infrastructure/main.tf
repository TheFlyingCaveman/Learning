locals {  
  product_name = "${var.product_name}-${var.environment}"
  standard_tags = {
    Name        = local.product_name
    Environment = var.environment
    Product     = var.product_name
  }
  vpc_cidr_block              = "10.0.0.0/16"
  count_of_availability_zones = length(data.aws_availability_zones.available.names) 
}

resource "aws_cloudwatch_log_group" "ecs" {
  name = local.product_name

  tags = local.standard_tags
}

resource "aws_ecs_cluster" "shared" {
  name               = local.product_name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Ran into ACM limits :( 
# module "exposed_containerized_service" {
#   source = "./modules/exposed_containerized_service"

#   execution_role_arn = aws_iam_role.execution.arn
#   image_url_with_tag = "${data.aws_ecr_repository.service.repository_url}:${var.image_tag}"
#   app_name           = "ServiceA"
#   environment        = "NonProd"
#   standard_tags      = local.standard_tags
#   # additional_ecs_task_security_group_ids = [aws_security_group.ecs_tasks.id]
#   private_subnet_ids = aws_subnet.private.*.id
#   pretty_domain = {
#     aws_route53_zone_name = "experiments.joshuamiller.net"
#     aws_route53_record_name = "rolling.experiments.joshuamiller.net"
#   }
#   vpc_id             = aws_vpc.main.id
#   ecs_cluster_id     = aws_ecs_cluster.shared.id
# }

resource "aws_security_group" "shared" {
  name        = "${local.product_name}-ecs-shared"
  description = "allow inbound access from items in same security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# module "containerized_service" {
#   source = "./modules/containerized_service"

#   execution_role_arn       = aws_iam_role.execution.arn
#   image_url_with_tag       = "${data.aws_ecr_repository.service.repository_url}:${var.image_tag}"
#   app_name                 = "ServiceA"
#   environment              = "NonProd"
#   standard_tags            = local.standard_tags
#   security_group_ids       = [aws_security_group.shared.id]
#   private_subnet_ids       = aws_subnet.private.*.id
#   ecs_cluster_id           = aws_ecs_cluster.shared.id
#   private_dns_namespace_id = aws_service_discovery_private_dns_namespace.main.id
# }

data "aws_ecr_repository" "simpleweb" {
  name = "simpleweb"
}

module "service_a" {
  source = "./modules/internal_containerized_service"

  execution_role_arn = aws_iam_role.execution.arn
  image_url_with_tag = "${data.aws_ecr_repository.simpleweb.repository_url}:latest"
  app_name           = "ServiceA"
  environment        = var.environment
  standard_tags      = local.standard_tags
  # additional_ecs_task_security_group_ids = [aws_security_group.ecs_tasks.id]
  private_subnet_ids       = aws_subnet.private.*.id  
  vpc_id                   = aws_vpc.main.id
  ecs_cluster_id           = aws_ecs_cluster.shared.id
  private_dns_namespace_id = aws_service_discovery_private_dns_namespace.main.id
}
