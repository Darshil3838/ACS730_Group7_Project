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

#private ip fro cloud9
variable "cloud_private_ip"{
  default      = "172.31.76.50"
  type          =string
  description = "PRIVATE IP OF CLOUD9"
}


#private ip fro cloud9
variable "cloud_public_ip"{
  default      = "3.238.228.167"
  type          =string
  description = "public IP OF CLOUD9"
}
