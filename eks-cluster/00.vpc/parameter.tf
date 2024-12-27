resource "aws_ssm_parameter" "vpc_id" {
  name  = "/${var.project_name}/${var.environment}/vpc-id"
  type  = "String"
  value = module.vpc.vpc_id
}
resource "aws_ssm_parameter" "public_subnet_ids" {
  name  = "/${var.project_name}/${var.environment}/public-subnet-ids"
  type  = "StringList"
  value = join(",", module.vpc.public_subnet_ids)
}
resource "aws_ssm_parameter" "private_subnet_ids" {
  name  = "/${var.project_name}/${var.environment}/private-subnet-ids"
  type  = "StringList"
  value = join(",", module.vpc.private_subnet_ids)
}
resource "aws_ssm_parameter" "db_subnet_ids" {
  name  = "/${var.project_name}/${var.environment}/db-subnet-ids"
  type  = "StringList"
  value = join(",", module.vpc.db_subnet_ids)
}
resource "aws_ssm_parameter" "db_subnet_group_name" {
  name  = "/${var.project_name}/${var.environment}/db-subnet-group-name"
  type  = "String"
  value = module.vpc.db_subnet_group
}