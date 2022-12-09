provider "aws" {
  region = "us-east-1"
}






# Use remote state to retrieve the data
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "${var.env}-group7"
    key    = "${var.env}-network/terraform.tfstate"
    region = "us-east-1"
  }
}




locals {
  name_prefix = "${var.prefix}-${var.env}"
  }




# Auto Scaling Group
resource "aws_autoscaling_group" "asg_bar" {
  name                 = "dev-asg"
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