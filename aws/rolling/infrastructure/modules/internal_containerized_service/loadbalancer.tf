resource "aws_security_group" "vpc_link" {
  name        = "${local.service_name}-vpc-link"
  description = "To allow traffic from VPC Link"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# data "aws_vpc_endpoint_service" "vpc_link" {
#   service = "vpc-link"
# }

# data "aws_subnet_ids" "supported_subnets" {
#   vpc_id = var.vpc_id

#   filter {
#     name   = "subnet-id"
#     values = var.private_subnet_ids
#   }

#   filter {
#     name   = "availability-zone"
#     values = data.aws_vpc_endpoint_service.vpc_link.availability_zones
#   }
# }

# resource "aws_apigatewayv2_vpc_link" "main" {
#   name               = local.service_name
#   security_group_ids = [aws_security_group.vpc_link.id]
#   subnet_ids         = data.aws_subnet_ids.supported_subnets.ids

#   tags = var.standard_tags
# }

resource "aws_security_group" "lb" {
  name        = "${local.service_name}-lb"
  description = "controls access to the Application Load Balancer (ALB)"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.vpc_link.id]
  }

  ingress {
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    security_groups = [aws_security_group.vpc_link.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "main" {
  name               = local.service_name
  subnets            = var.private_subnet_ids
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  internal           = true

  tags = var.standard_tags
}

# Running into issues with ACM, this should be used under normal circumstances
# resource "aws_lb_listener" "service" {
#   load_balancer_arn = aws_lb.main.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type = "redirect"

#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }

resource "aws_lb_target_group" "main" {
  name        = local.service_name
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "90"
    protocol            = "HTTP"
    matcher             = "200-299"
    timeout             = "20"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# module "pretty_domain" {
#   source = "../pretty_domain"

#   aws_route53_zone_name   = var.pretty_domain.aws_route53_zone_name
#   aws_route53_record_name = var.pretty_domain.aws_route53_record_name
#   lb = {
#     dns_name                = aws_lb.main.dns_name
#     zone_id                 = aws_lb.main.zone_id
#     aws_lb_arn              = aws_lb.main.arn
#     aws_lb_target_group_arn = aws_lb_target_group.main.arn
#   }
# }
