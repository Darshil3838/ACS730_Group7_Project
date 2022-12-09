

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





# Variable to signal the current environment 
variable "env" {
  default     = "dev"
  type        = string
  description = "dev environment"
}






variable "target_group_arn" {
  type        = string
  description = "calling load_balancers id"
}

variable "launch_config_name" {
  type        = string
  description = "calling template_name from launch config"
}

variable "min_size" {
  type        = any
  description = "Minimum capacity of Auto scaling group"
}

variable "max_size" {
  default     = 4
  type        = number
  description = "Maximum capacity of Auto scaling group"
}

variable "desired_size" {
default = 3
  type        = any
  description = "Desired capacity of Auto scaling group"
}