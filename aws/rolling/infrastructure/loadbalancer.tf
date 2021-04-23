resource "aws_security_group" "lb" {
  name        = "${local.service_name}-lb"
  description = "controls access to the Application Load Balancer (ALB)"
  vpc_id      = aws_vpc.main.id

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

resource "aws_security_group" "ecs_tasks" {
  name        = "${local.service_name}-ecs"
  description = "allow inbound access from the ALB only"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.lb.id]
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
  subnets            = aws_subnet.private.*.id
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]

  tags = local.standard_tags
}

resource "aws_lb_listener" "service" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "main" {
  name        = local.service_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
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

module "pretty_domain" {  
  source = "./pretty_domain"

  aws_route53_zone_name   = var.pretty_domain.aws_route53_zone_name
  aws_route53_record_name = var.pretty_domain.aws_route53_record_name
  lb = {
    dns_name                = aws_lb.main.dns_name
    zone_id                 = aws_lb.main.zone_id
    aws_lb_arn              = aws_lb.main.arn
    aws_lb_target_group_arn = aws_lb_target_group.main.arn
  }
}
