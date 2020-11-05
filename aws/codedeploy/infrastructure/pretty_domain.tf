data "aws_route53_zone" "experiments" {
  name         = "experiments.joshuamiller.net"
  private_zone = false
}

resource "aws_route53_record" "codedeploy" {
  zone_id = data.aws_route53_zone.experiments.zone_id
  name    = "codedeploy.experiments.joshuamiller.net"
  type    = "A"
  alias {
    evaluate_target_health = false
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
  }
}
