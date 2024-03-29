data "aws_route53_zone" "selected" {
  name = var.a_record_name
}

resource "aws_route53_record" "a_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.a_record_name
  type    = "A"
  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}