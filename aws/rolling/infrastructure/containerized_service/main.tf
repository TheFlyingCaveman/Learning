resource "aws_ecs_task_definition" "definition" {
  family       = local.service_name
  network_mode = "awsvpc"
  #   task_role_arn            = aws_iam_role.api.arn
  execution_role_arn       = var.execution_role_arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu_units
  memory                   = var.container_memory
  tags                     = var.standard_tags
  container_definitions    = <<DEFINITION
[
  {
    "name": "${local.service_name}",
    "image": "${var.image_url_with_tag}",
    "essential": true,     
    "cpu": 0,
    "mountPoints": [],    
    "volumesFrom": [],
    "portMappings": [
      {
        "containerPort": ${var.container_port},
        "hostPort": 80,
        "protocol": "tcp"
      }
    ],
    "environment": [
      {
          "name": "ApplicationVersion",
          "value": "${var.application_version}"
      }
    ],
    "requiresAttributes": [
        {
        "value": null,
        "name": "com.amazonaws.ecs.capability.ecr-auth",
        "targetId": null,
        "targetType": null
        },
        {
        "value": null,
        "name": "com.amazonaws.ecs.capability.task-iam-role",
        "targetId": null,
        "targetType": null
        },
        {
        "value": null,
        "name": "com.amazonaws.ecs.capability.docker-remote-api.1.19",
        "targetId": null,
        "targetType": null
        }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "api" {
  name        = local.service_name
  launch_type = "FARGATE"
  tags        = var.standard_tags

  cluster = aws_ecs_cluster.api.id

  task_definition = aws_ecs_task_definition.definition.arn

  scheduling_strategy = "REPLICA"
  desired_count       = var.desired_count
  #   health_check_grace_period_seconds = var.health_check_period
  #   iam_role                          = aws_iam_role.api.name

  force_new_deployment = true

  network_configuration {
    security_groups  = var.security_group_ids
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  // We do not want to change the scale if auto-scaling has already occurred
  lifecycle {
    ignore_changes        = [desired_count]    
  }

  dynamic "load_balancer" {
    for_each = local.hasLoadBalancer
    content {
      container_name   = local.service_name
      container_port   = var.container_port
      target_group_arn = var.lb_target_group_arn
    }
  }

  #   ordered_placement_strategy {
  #     type  = "spread"
  #     field = "host"
  #   }

  # look into this for serivce discovery?
  #   service_registries 
}

resource "aws_ecs_cluster" "api" {
  name               = local.service_name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
