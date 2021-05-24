resource "aws_apigatewayv2_api" "main" {
  name          = local.product_name
  protocol_type = "HTTP"
  tags          = local.standard_tags
}

data "aws_vpc_endpoint_service" "alb" {
  service      = "elasticloadbalancing"  
  # filter {
  #   name = "service-name"
  #   values = ["elasticloadbalancing"]
  # }
}

data "aws_subnet_ids" "private_supported" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "*-private"
  }

  filter {
    name = "availability-zone"
    values = data.aws_vpc_endpoint_service.alb.availability_zones
  }
}

resource "aws_apigatewayv2_vpc_link" "example" {
  name               = "example"
  security_group_ids = [aws_security_group.from_ecs_tasks.id]
  subnet_ids         = data.aws_subnet_ids.private_supported.ids

  tags = {
    Usage = "example"
  }
}

output "zones" {
  value = data.aws_vpc_endpoint_service.alb.availability_zones
}

output "subnets" {
  value = data.aws_subnet_ids.private_supported.ids
}

# resource "aws_apigatewayv2_integration" "example" {
#   api_id           = aws_apigatewayv2_api.main.id
#   integration_type = "HTTP_PROXY"

#   integration_method = "ANY"
#   integration_uri    = "https://example.com/{proxy}"
# }

# resource "aws_apigatewayv2_route" "simpleweb" {
#   api_id    = aws_apigatewayv2_api.main.id
#   route_key = "ANY /example/{proxy+}"

#   target = "integrations/${aws_apigatewayv2_integration.example.id}"
# }