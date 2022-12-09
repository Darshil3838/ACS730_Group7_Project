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
  source = "../../../modules/globalvars"
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
  security_groups             = [aws_security_group.sg_bastion.id]
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


# Security Group for Bastion VM
resource "aws_security_group" "sg_bastion" {
  name        = "allow_ssh_bastion"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description      = "SSH from admin"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
# merging tags
  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-Sg-Bastion"
    }
  )
}






#Deploy security groups 
module "sg-dev" {
  source       = "/home/ec2-user/environment/environment/modules/sg_group"
  prefix       = module.globalvars.prefix
  default_tags = module.globalvars.default_tags
  env          = var.env
}







#Deploy application load balancer
module "alb-dev" {
  source       = "/home/ec2-user/environment/environment/modules/load_blancer"
  prefix       = module.globalvars.prefix
  default_tags = module.globalvars.default_tags
  env          = var.env
  sg_id        = module.sg-dev.lb_sg_id
}


#Deploy webserver launch configuration
module "launch-config-dev" {
  source        = "/home/ec2-user/environment/environment/modules/launch_config"
  prefix        = module.globalvars.prefix
  env           = var.env
  sg_id         = module.sg-dev.lb_sg_id
  instance_type = var.instance_type
}


# Auto Scaling Group
module "asg-dev" {
  source             = "/home/ec2-user/environment/environment/modules/autoscalling_group"
  prefix             = module.globalvars.prefix
  env                = var.env
  default_tags       = module.globalvars.default_tags
  #desired_capacity   = var.asg_desired_size
  target_group_arn   = module.alb-dev.aws_lb_target_group_arn
  launch_config_name = module.launch-config-dev.launch_config_name
}
