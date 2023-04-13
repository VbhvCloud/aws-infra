data "aws_acm_certificate" "issued" {
  domain   = var.a_record_name
  statuses = ["ISSUED"]
}


resource "aws_lb" "alb" {
  name               = "webapp-lb"
  internal           = false
  load_balancer_type = "application"

  subnets         = [for subnet in aws_subnet.public_subnets : subnet.id]
  security_groups = [aws_security_group.load_balancer_sg.id]

  tags = {
    webapp = "webapp_asg_instance"
  }
}

# Create a target group for the Auto Scaling Group instances
resource "aws_lb_target_group" "tg" {
  name       = "tg-webapp-lb"
  port       = 8000
  protocol   = "HTTP"
  vpc_id     = aws_vpc.vpc.id
  slow_start = 60

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/healthz"
    port                = "8000"
    protocol            = "HTTP"
  }
}

# Attach the target group to the Application Load Balancer
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
  certificate_arn = data.aws_acm_certificate.issued.arn
  ssl_policy      = "ELBSecurityPolicy-2016-08"

}