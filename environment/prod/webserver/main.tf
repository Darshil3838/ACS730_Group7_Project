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
  default_tags = merge(module.globalvars.default_tags, { "env" = var.env })
  prefix       = module.globalvars.prefix
  name_prefix  = "${local.prefix}-${var.env}"
}

# Retrieve global variables from the Terraform module
module "globalvars" {
  source = "/home/ec2-user/environment/ACS730_Group7_Project/environment/modules/globalvars"
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


# Bastion host VM   
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet_id[0]
  security_groups             = [module.sg-prod.bastion_sg_id]
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-Bastion"
    }
  )
}


# Adding SSH key to Amazon EC2   ccccc
resource "aws_key_pair" "web_key" {
  key_name   = local.name_prefix
  public_key = file("${local.name_prefix}.pub")
}


#Deploy security groups 
module "sg-prod" {
  source       = "/home/ec2-user/environment/ACS730_Group7_Project/environment/modules/sg_group"
  prefix       = module.globalvars.prefix
  default_tags = module.globalvars.default_tags
  env          = var.env
}







#Deploy application load balancer
module "alb-prod" {
  source       = "/home/ec2-user/environment/ACS730_Group7_Project/environment/modules/load_balancer"
  prefix       = module.globalvars.prefix
  default_tags = module.globalvars.default_tags
  env          = var.env
  sg_id        = module.sg-prod.lb_sg_id
}


#Deploy webserver launch configuration
module "launch-config-prod" {
  source        = "/home/ec2-user/environment/ACS730_Group7_Project/environment/modules/launch_config"
  prefix        = module.globalvars.prefix
  env           = var.env
  sg_id         = module.sg-prod.lb_sg_id
  instance_type = var.instance_type
}


# Auto Scaling Group
module "asg-prod" {
  source             = "/home/ec2-user/environment/ACS730_Group7_Project/environment/modules/autoscalling_group"
  prefix             = module.globalvars.prefix
  env                = var.env
  default_tags       = module.globalvars.default_tags
  #desired_capacity   = var.asg_desired_size
  target_group_arn   = module.alb-prod.aws_lb_target_group_arn
  launch_config_name = module.launch-config-prod.launch_config_name
}
