locals {
  distinct_security_group_ids = distinct(concat([aws_security_group.ecs_tasks.id], var.additional_ecs_task_security_group_ids))
}

module "containerized_service" {
  source = "../containerized_service"

  execution_role_arn       = var.execution_role_arn
  image_url_with_tag       = var.image_url_with_tag
  app_name                 = var.app_name
  environment              = var.environment
  standard_tags            = var.standard_tags
  application_version      = var.application_version
  container_port           = var.container_port
  container_cpu_units      = var.container_cpu_units
  container_memory         = var.container_memory
  desired_count            = var.desired_count
  health_check_period      = var.health_check_period
  lb_target_group_arn      = aws_lb_target_group.main.arn
  security_group_ids       = local.distinct_security_group_ids
  private_subnet_ids       = var.private_subnet_ids
  ecs_cluster_id           = var.ecs_cluster_id
  private_dns_namespace_id = var.private_dns_namespace_id

  depends_on = [
    #   aws_iam_role.api    
    aws_lb_listener.service
  ]
}
