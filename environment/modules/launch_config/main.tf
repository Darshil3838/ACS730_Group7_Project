# Define the provider
provider "aws" {
  region = "us-east-1"
}


# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}


# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}




# Define tags locally
locals {
  
  name_prefix  = "${var.prefix}-${var.env}"
}




# Launch Configuration
resource "aws_launch_configuration" "as_conf" {
  name                        = "linux"
  image_id                    = "ami-0c02fb55956c7d316"
  instance_type               = var.type
  security_groups             = [var.sg_id]
  key_name                    = local.name_prefix
  associate_public_ip_address = true
  iam_instance_profile        = "LabInstanceProfile"
  user_data                   = filebase64("${path.module}/install_httpd.sh")
}
