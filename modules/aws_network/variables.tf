# Default tags
variable "default_tags" {
  
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}

# Name prefix
variable "prefix" {
 
  type        = string
  description = "Name prefix"
}




# Variable to signal the current environment 
variable "env" {

  type        = string
  description = "dev environment"
}





# VPC CIDR range
variable "vpc_cidr" {
  type        = string
  description = "VPC for dev environment"
}





# Provision public subnets in VPC
variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDRs"
}

# Provision private subnets in VPC
variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDRs"
}

