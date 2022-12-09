#Add output variables

output "lb_dns_name" {
  value = module.alb-dev.alb_dns_name
}

