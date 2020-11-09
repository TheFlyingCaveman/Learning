data "aws_route53_zone" "experiments" {
  name         = var.aws_route53_zone_name
  private_zone = false
}

resource "aws_route53_record" "codedeploy" {
  zone_id = data.aws_route53_zone.experiments.zone_id
  name    = var.aws_route53_record_name
  type    = "A"
  alias {
    evaluate_target_health = false
    name                   = var.lb.dns_name
    zone_id                = var.lb.zone_id
  }
}

resource "aws_acm_certificate" "example" {
  domain_name       = var.aws_route53_record_name
  validation_method = "DNS"
}

resource "aws_route53_record" "example" {
  for_each = {
    for dvo in aws_acm_certificate.example.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.experiments.zone_id
}

resource "aws_acm_certificate_validation" "example" {
  certificate_arn         = aws_acm_certificate.example.arn
  validation_record_fqdns = [for record in aws_route53_record.example : record.fqdn]
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = var.lb.aws_lb_arn
  port              = "443"
  protocol          = "HTTPS"

  ssl_policy        = "ELBSecurityPolicy-2016-08"

  certificate_arn    = aws_acm_certificate_validation.example.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = var.lb.aws_lb_target_group_arn
  }
}