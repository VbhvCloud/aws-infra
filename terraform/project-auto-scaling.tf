data "template_file" "user_data" {

  template = file("./scripts/user_data.sh")
  vars = {
    db_username   = var.db_username
    db_password   = var.db_password
    db_host       = aws_db_instance.main.address
    db_name       = var.db_name
    aws_s3_bucket = aws_s3_bucket.private.id
  }
}

data "aws_ami" "custom_ami" {
  executable_users = ["self"]
  most_recent      = true
}

resource "aws_launch_template" "asg_launch_template" {
  name                    = "asg_launch_config"
  image_id                = data.aws_ami.custom_ami.id
  instance_type           = var.instance_type
  disable_api_termination = false
  iam_instance_profile {
    name = aws_iam_instance_profile.EC2-CSYE6225_instance_profile.name
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.security_group.id]
  }
  user_data = base64encode(data.template_file.user_data.rendered)
  depends_on = [
    aws_security_group.security_group
  ]
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = var.instance_volume_size
      volume_type = var.instance_volume_type
      encrypted   = true
      kms_key_id  = aws_kms_key.ebs-kms.arn
    }
  }
}

resource "aws_autoscaling_group" "webapp_asg" {
  name = "csye6225-asg-spring2023"

  launch_template {
    id      = aws_launch_template.asg_launch_template.id
    version = "$Latest"
  }

  vpc_zone_identifier = [for subnet in aws_subnet.public_subnets : subnet.id]

  min_size          = 1
  max_size          = 3
  desired_capacity  = 1
  health_check_type = "EC2"
  default_cooldown  = 60

  tag {
    key                 = "webapp"
    value               = "webapp_asg_instance"
    propagate_at_launch = true
  }

  target_group_arns = [

    aws_lb_target_group.tg.arn

  ]
}

resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "scale-up-policy"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
  scaling_adjustment     = 1
  cooldown               = 60
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "scale-up-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 5
  alarm_actions       = [aws_autoscaling_policy.scale_up_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }
}

resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "scale-down-policy"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
  scaling_adjustment     = -1
  cooldown               = 60
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "scale-down-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 4
  alarm_actions       = [aws_autoscaling_policy.scale_down_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }
}
