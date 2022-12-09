#Add output variables

output "lb_dns_name" {
  value = module.alb-prod.alb_dns_name
}

