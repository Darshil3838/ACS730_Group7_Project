provider "aws" {
  region = "us-east-1"
}






# Use remote state to retrieve the data
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "${var.env}-group7-project"
    key    = "${var.env}-network/terraform.tfstate"
    region = "us-east-1"
  }
}




locals {
  name_prefix = "${var.prefix}-${var.env}"
  }




# Auto Scaling Group
resource "aws_autoscaling_group" "asg_bar" {
  name                 = "${var.env}-asg"
  desired_capacity     = var.desired_size
  max_size             = var.max_size
  min_size             = var.min_size
  launch_configuration = var.launch_config_name
  vpc_zone_identifier  = [data.terraform_remote_state.network.outputs.private_subnet_id[0], data.terraform_remote_state.network.outputs.private_subnet_id[1], data.terraform_remote_state.network.outputs.private_subnet_id[2]]
  #depends_on           = [aws_lb.alb]
  target_group_arns    = [var.target_group_arn]
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupTotalCapacity",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
  metrics_granularity = "1Minute"
  tag {
    key                 = "Name"
    value               = "${var.env}-ASG-Instance"
    propagate_at_launch = true
  }
}






#Creating Scaling policy for AutoScaling Groupc combined CPU usage of all the instances  less then  or equal 5% 
resource "aws_autoscaling_policy" "asg_policy5_down" {
  name                   = "${local.name_prefix}-asg_policy_down"
  autoscaling_group_name = aws_autoscaling_group.asg_bar.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}




#Creating an alarm metric when combined CPU usage of all the instances  less then  or equal 5% 
resource "aws_cloudwatch_metric_alarm" "metric_asg_policy_down" {
  alarm_description   = "CPU usage of all the instances  less then  or equal 5% "
  alarm_actions       = [aws_autoscaling_policy.asg_policy5_down.arn]
  alarm_name          = "${local.name_prefix}_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "5"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_bar.name
  }
}

