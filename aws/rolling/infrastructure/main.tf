locals {
  service_name = "${var.app_name}-${var.environment}"
  standard_tags = {
    Name        = local.service_name
    Environment = var.environment
    Application = var.app_name
  }
  vpc_cidr_block              = "10.0.0.0/16"
  count_of_availability_zones = length(data.aws_availability_zones.available.names)
}

resource "aws_cloudwatch_log_group" "ecs" {
  name = local.service_name

  tags = local.standard_tags
}

module "containerized_service" {
  source = "./modules/containerized_service"

  execution_role_arn  = aws_iam_role.execution.arn
  image_url_with_tag  = "${data.aws_ecr_repository.service.repository_url}:${var.image_tag}"
  app_name            = "ServiceA"
  environment         = "NonProd"
  standard_tags       = local.standard_tags
  lb_target_group_arn = aws_lb_target_group.main.arn
  security_group_ids  = [aws_security_group.ecs_tasks.id]
  private_subnet_ids  = aws_subnet.private.*.id

  depends_on = [
    #   aws_iam_role.api    
    aws_lb_listener.service
  ]
}
