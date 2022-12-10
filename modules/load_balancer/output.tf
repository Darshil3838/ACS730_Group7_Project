output "aws_lb_target_group_arn" {
  value = aws_lb_target_group.group.arn
}




output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}