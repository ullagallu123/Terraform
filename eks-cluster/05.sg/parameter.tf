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
resource "aws_ssm_parameter" "ingress_sg" {
  name  = "/${var.project_name}/${var.environment}/ingress-sg"
  type  = "String"
  value = module.ingress.sg_id
}
resource "aws_ssm_parameter" "node_sg" {
  name  = "/${var.project_name}/${var.environment}/node-sg"
  type  = "String"
  value = module.node.sg_id
}
resource "aws_ssm_parameter" "controlplane_sg" {
  name  = "/${var.project_name}/${var.environment}/controlplane-sg"
  type  = "String"
  value = module.controlplane.sg_id
}