# Default tags
variable "default_tags" {
  default = {
    "Owner" = "Darshil, Harsh, Bishal"
    "App"   = "Web"
  }
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}

# Name prefix
variable "prefix" {
  default     = "Group7"
  type        = string
  description = "Name prefix"
}


#private ip for cloud9
variable "cloud_private_ip"{
  default      = "172.31.76.50"
  type          =string
  description = "PRIVATE IP OF CLOUD9"
}


#private ip for cloud9
variable "cloud_public_ip"{
  default      = "3.238.228.167"
  type          =string
  description = "public IP OF CLOUD9"
}



# Variable to signal the current environment 
variable "env" {
  default     = "dev"
  type        = string
  description = "dev environment"
}