#Add output variables

output "lb_dns_name" {
  value = module.alb-staging.alb_dns_name
}

