output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "db_subnet_ids" {
  value = module.vpc.db_subnet_ids
}

output "db_subnet_group" {
  value = module.vpc.db_subnet_group
}

output "eip" {
  value = module.vpc.eip
}

output "nat_id" {
  value = module.vpc.nat_id
}