data "aws_availability_zones" "available" {}

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

# resource "aws_iam_role" "api" {
#   name = "ecs_role_${var.app_name}_${var.environment}"
# }

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = local.standard_tags
}


resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.public.id
}

// So we can access Docker for the docker image
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = local.standard_tags
}

resource "aws_subnet" "public" {
  count                   = local.count_of_availability_zones
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${10 + count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = merge(
    local.standard_tags,
    {
      Name = "${local.service_name}-public"
  })
}

resource "aws_subnet" "private" {
  count                   = local.count_of_availability_zones
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${20 + count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = merge(
    local.standard_tags,
    {
      Name = "${local.service_name}-private"
  })
}

data "aws_ecr_repository" "service" {
  name = var.ecr_repo_name
}

resource "aws_iam_role" "execution" {
  name = "${local.service_name}-ecs-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = local.standard_tags
}

resource "aws_iam_role_policy" "test_policy" {
  name = "${local.service_name}-ecs-execution-policy"
  role = aws_iam_role.execution.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_ecs_task_definition" "definition" {
  family       = local.service_name
  network_mode = "awsvpc"
  #   task_role_arn            = aws_iam_role.api.arn
  execution_role_arn       = aws_iam_role.execution.arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu_units
  memory                   = var.container_memory
  tags                     = local.standard_tags
  container_definitions    = <<DEFINITION
[
  {
    "name": "${local.service_name}",
    "image": "${data.aws_ecr_repository.service.repository_url}:${var.image_tag}",
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

resource "aws_ecs_cluster" "api" {
  name               = local.service_name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# resource "aws_lb_target_group" "api" {
#   name     = local.service_name
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.main.id
# }

resource "aws_ecs_service" "api" {
  name        = local.service_name
  launch_type = "FARGATE"

  cluster = aws_ecs_cluster.api.id

  task_definition = aws_ecs_task_definition.definition.arn

  scheduling_strategy = "REPLICA"
  desired_count       = var.desired_count
  #   health_check_grace_period_seconds = var.health_check_period
  #   iam_role                          = aws_iam_role.api.name

  force_new_deployment = true

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  depends_on = [
    #   aws_iam_role.api
    aws_lb_listener.service
  ]

  // We do not want to change the scale if auto-scaling has already occurred
  lifecycle {
    ignore_changes = [desired_count]
  }

  load_balancer {
    container_name   = local.service_name
    container_port   = var.container_port
    target_group_arn = aws_lb_target_group.main.arn
  }

  #   ordered_placement_strategy {
  #     type  = "spread"
  #     field = "host"
  #   }

  # look into this for serivce discovery?
  #   service_registries 
}

# data "aws_lb" "internal" {
#   name = "ditto-website-alb-internal"
# }

# data "aws_alb_listener" "internal" {
#   load_balancer_arn = "${data.aws_lb.internal.arn}"
#   port              = 443
# }

# resource "aws_lb_target_group" "api" {
#   protocol   = "HTTP"
#   vpc_id     = "${data.aws_vpc.vpc.id}"
#   name       = "${var.app_name}"
#   port       = 80
#   slow_start = 0
# }

# resource "aws_lb_listener_rule" "api" {
#   listener_arn = "data.aws_alb_listener.public.arn"
#   priority     = "${var.lb_rule_number}"

#   action {
#     type             = "forward"
#     target_group_arn = "${aws_lb_target_group.api.arn}"
#   }

#   condition {
#     field  = "path-pattern"
#     values = ["${var.lb_pattern}"]
#   }
# }


