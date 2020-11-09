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