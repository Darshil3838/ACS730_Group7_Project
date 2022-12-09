#Add output variables
output "launch_config_name" {
  value = aws_launch_configuration.as_conf.name
}
