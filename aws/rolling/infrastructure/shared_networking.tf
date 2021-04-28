data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = local.standard_tags

  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = local.standard_tags
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.public.id
}

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

resource "aws_security_group" "from_ecs_tasks" {
  name        = "${local.service_name}-from-ecs-tasks"
  description = "Allow inbound access from ECS"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
    # security_groups = [aws_security_group.ecs_tasks.id]
    security_groups = module.exposed_containerized_service.ecs_security_group_ids
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"

  auto_accept = true

  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.from_ecs_tasks.id
  ]

  subnet_ids = aws_subnet.private.*.id

  tags = merge(
    local.standard_tags,
    {
      Name = "${local.service_name}-ecr-dkr"
  })
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type = "Interface"

  auto_accept = true

  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.from_ecs_tasks.id
  ]

  subnet_ids = aws_subnet.private.*.id

  tags = merge(
    local.standard_tags,
    {
      Name = "${local.service_name}-ecr-api"
  })
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  auto_accept = true

  route_table_ids = [aws_route_table.public.id]

  tags = merge(
    local.standard_tags,
    {
      Name = "${local.service_name}-s3"
  })
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type = "Interface"

  auto_accept = true

  security_group_ids = [
    aws_security_group.from_ecs_tasks.id
  ]

  subnet_ids = aws_subnet.private.*.id

  tags = merge(
    local.standard_tags,
    {
      Name = "${local.service_name}-logs"
  })
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"

  auto_accept = true

  security_group_ids = [
    aws_security_group.from_ecs_tasks.id
  ]

  subnet_ids = aws_subnet.private.*.id

  tags = merge(
    local.standard_tags,
    {
      Name = "${local.service_name}-ssm"
  })
}
