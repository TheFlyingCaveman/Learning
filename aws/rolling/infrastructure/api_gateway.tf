resource "aws_apigatewayv2_api" "main" {
  name          = local.product_name
  protocol_type = "HTTP"
  tags          = local.standard_tags
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