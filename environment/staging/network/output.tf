#Add output variables for vpc_id
output "vpc_id" {
  value = module.dev.vpc_id
}



#Add output variables for public_subnet_id
output "public_subnet_id" {
  value = module.dev.public_subnet_id
}


#Add output variables for private_subnet_id
output "private_subnet_id" {
  value = module.dev.private_subnet_id
}



#Add output variables for public_route_table_id
output "public_route_table_id" {
  value = module.dev.public_route_table_id
}


#Add output variables for private_route_table_id
output "private_route_table_id" {
  value = module.dev.private_route_table_id
}
