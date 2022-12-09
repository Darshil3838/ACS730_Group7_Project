# Instance type
variable "instance_type" {
  default     = "t2.micro"
  description = "Type of the instance"
  type        = string
}

# Variable to signal the current environment 
variable "env" {
  default     = "dev"
  type        = string
  description = "dev environment"
}

#private ip for cloud9 needs to add cloud9's private ip mannualy
variable "cloud_private_ip"{
  default      = "172.31.76.50"
  type          =string
  description = "PRIVATE IP OF CLOUD9"
}


#public ip for cloud9 needs to add cloud9's public ip mannualy
variable "cloud_public_ip"{
  default      = "3.238.228.167"
  type          =string
  description = "public IP OF CLOUD9"
}