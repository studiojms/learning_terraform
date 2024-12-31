data "aws_secretsmanager_secret" "secret" {
  arn = "arn:aws:secretsmanager:us-east-1:000000000000:secret:prod/terraform/db-BIXMpu"
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.secret.id
}

resource "aws_launch_template" "template" {
  name          = "${var.prefix}-template"
  image_id      = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  user_data = base64encode(
    <<-EOF
        #!/bin/bash
        DB_STR="Server=${jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["Host"]};Database=${jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["DB"]};User=${jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["Username"]};Password=${jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["Password"]}"
        echo $DB_STR > /tmp/db_str.txt
    EOF
  )

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = var.security_group_ids
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.prefix}-node"
    }

  }
}

resource "aws_autoscaling_group" "asg" {
  name                = "${var.prefix}-asg"
  desired_capacity    = 2
  min_size            = 1
  max_size            = 3
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "${var.prefix}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "scale_out_alarm" {
  alarm_name          = "${var.prefix}-scale-out-alarm"
  alarm_description   = "Monitors CPU utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions       = [aws_autoscaling_policy.scale_out_policy.arn]
  threshold           = 80
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}

resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "${var.prefix}-scale-in"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "scale_in_alarm" {
  alarm_name          = "${var.prefix}-scale-in-alarm"
  alarm_description   = "Monitors CPU utilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  alarm_actions       = [aws_autoscaling_policy.scale_in_policy.arn]
  threshold           = 20
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}
