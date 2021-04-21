# resource "aws_iam_role" "api" {
#   name = "ecs_role_${var.app_name}_${var.environment}"
# }

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
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

  tags = {
    Name = "example"
  }
}

// have these be passed in to the module
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  // To use public Docker Hub for learning
  // https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-configure-network.html
  map_public_ip_on_launch = false
  tags = {
    Name = "For testing ecs things"
  }
}

resource "aws_ecs_task_definition" "definition" {
  family       = var.app_name
  network_mode = "awsvpc"
  #   task_role_arn            = aws_iam_role.api.arn
  #   execution_role_arn       = aws_iam_role.api.arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu_units
  memory                   = var.container_memory
  tags                     = {}
  container_definitions    = <<DEFINITION
[
  {
    "name": "${var.app_name}",
    "image": "${var.container_image}",
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
  name               = var.app_name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "api" {
  name        = var.app_name
  launch_type = "FARGATE"

  cluster = aws_ecs_cluster.api.id

  task_definition = aws_ecs_task_definition.definition.arn

  scheduling_strategy = "REPLICA"
  desired_count       = var.desired_count
  #   health_check_grace_period_seconds = var.health_check_period
  #   iam_role                          = aws_iam_role.api.name

  force_new_deployment = true

  network_configuration {
    subnets = [
      aws_subnet.main.id
    ]
    // only because of learning at the moment
    assign_public_ip = true
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  #   depends_on = [
  #     aws_iam_role.api
  #   ]

  // We do not want to change the scale if auto-scaling has already occurred
  lifecycle {
    ignore_changes = [desired_count]
  }
  #   ordered_placement_strategy {
  #     type  = "spread"
  #     field = "host"
  #   }

  # load_balancer {
  #   container_name   = var.app_name
  #   container_port   = var.container_port
  #   target_group_arn = aws_lb_target_group.api.arn
  # }

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


