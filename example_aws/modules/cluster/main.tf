resource "aws_launch_template" "template" {
  name          = "${var.prefix}-template"
  image_id      = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  user_data = base64encode(var.user_data)

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
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [aws_lb_target_group.app_tg.arn]

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "${var.prefix}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = var.scale_out.scaling_adjustment
  cooldown               = var.scale_out.cooldown
}

resource "aws_cloudwatch_metric_alarm" "scale_out_alarm" {
  alarm_name          = "${var.prefix}-scale-out-alarm"
  alarm_description   = "Monitors CPU utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions       = [aws_autoscaling_policy.scale_out_policy.arn]
  threshold           = var.scale_out.threshold
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
  scaling_adjustment     = var.scale_in.scaling_adjustment
  cooldown               = var.scale_in.cooldown
}

resource "aws_cloudwatch_metric_alarm" "scale_in_alarm" {
  alarm_name          = "${var.prefix}-scale-in-alarm"
  alarm_description   = "Monitors CPU utilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  alarm_actions       = [aws_autoscaling_policy.scale_in_policy.arn]
  threshold           = var.scale_in.threshold
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}

resource "aws_lb" "app_lb" {
  name               = "${var.prefix}-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.prefix}-app-alb"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "${var.prefix}-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 10
  }

  tags = {
    Name = "${var.prefix}-app-tg"
  }
}

resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
