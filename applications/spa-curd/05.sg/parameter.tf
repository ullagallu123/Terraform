resource "aws_ssm_parameter" "bastion_sg" {
  name  = "/${var.project_name}/${var.environment}/bastion-sg"
  type  = "String"
  value = module.bastion.sg_id
}
resource "aws_ssm_parameter" "vpn_sg" {
  name  = "/${var.project_name}/${var.environment}/vpn-sg"
  type  = "String"
  value = module.vpn.sg_id
}
resource "aws_ssm_parameter" "db_sg" {
  name  = "/${var.project_name}/${var.environment}/db-sg"
  type  = "String"
  value = module.db.sg_id
}
resource "aws_ssm_parameter" "alb_sg" {
  name  = "/${var.project_name}/${var.environment}/alb-sg"
  type  = "String"
  value = module.alb.sg_id
}
resource "aws_ssm_parameter" "backend_sg" {
  name  = "/${var.project_name}/${var.environment}/backend-sg"
  type  = "String"
  value = module.backend.sg_id
}