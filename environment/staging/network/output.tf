#Add output variables for vpc_id
output "vpc_id" {
  value = module.staging.vpc_id
}



#Add output variables for public_subnet_id
output "public_subnet_id" {
  value = module.staging.public_subnet_id
}


#Add output variables for private_subnet_id
output "private_subnet_id" {
  value = module.staging.private_subnet_id
}



#Add output variables for public_route_table_id
output "public_route_table_id" {
  value = module.staging.public_route_table_id
}


#Add output variables for private_route_table_id
output "private_route_table_id" {
  value = module.staging.private_route_table_id
}
