module "bastion" {
  source         = "../../modules/sg"
  project_name   = var.project_name
  environment    = var.environment
  name           = "bastion"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  sg_description = "This SG was used for Bastion"
  common_tags = {
    "Terraform" = true
    "Developer" = "Sivaramakrishna"
  }
  sg_tags = {
    "Component" = "bastion-sg"
  }
}

module "vpn" {
  source         = "../../modules/sg"
  project_name   = var.project_name
  environment    = var.environment
  name           = "vpn"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  sg_description = "This SG was used for VPN"
  common_tags = {
    "Terraform" = true
    "Developer" = "Sivaramakrishna"
  }
  sg_tags = {
    "Component" = "vpn-sg"
  }
}

module "db" {
  source         = "../../modules/sg"
  project_name   = var.project_name
  environment    = var.environment
  name           = "rds"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  sg_description = "This SG was used for RDS MySQL"
  common_tags = {
    "Terraform" = true
    "Developer" = "Sivaramakrishna"
  }
  sg_tags = {
    "Component" = "rds-sg"
  }
}

module "controlplane" {
  source         = "../../modules/sg"
  project_name   = var.project_name
  environment    = var.environment
  name           = "controlplane"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  sg_description = "This SG was used for control plane"
  common_tags = {
    "Terraform" = true
    "Developer" = "Sivaramakrishna"
  }
  sg_tags = {
    "Component" = "control-plane-sg"
  }
}

module "node" {
  source         = "../../modules/sg"
  project_name   = var.project_name
  environment    = var.environment
  name           = "node"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  sg_description = "This SG was used for nodegroup"
  common_tags = {
    "Terraform" = true
    "Developer" = "Sivaramakrishna"
  }
  sg_tags = {
    "Component" = "node-sg"
  }
}

module "ingress" {
  source         = "../../modules/sg"
  project_name   = var.project_name
  environment    = var.environment
  name           = "ingress"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  sg_description = "This SG was used for nodegroup"
  common_tags = {
    "Terraform" = true
    "Developer" = "Sivaramakrishna"
  }
  sg_tags = {
    "Component" = "ingress-sg"
  }
}

# Bastion Ingress Rules
resource "aws_security_group_rule" "bastion_ssh" {
  type              = "ingress"
  description       = "This allow ssh port to bastion"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastion.sg_id
}

# VPN Rules
resource "aws_security_group_rule" "vpn_ssh" {
  type              = "ingress"
  description       = "This allow ssh port to vpn"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_https" {
  description       = "This rule allows all traffic from internet on 443"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_et" {
  description       = "This rule allows all traffic from internet on 992"
  type              = "ingress"
  from_port         = 943
  to_port           = 943
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}
resource "aws_security_group_rule" "vpn_udp" {
  description       = "This rule allows all traffic from internet on 1194"
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}


# DB Rules
resource "aws_security_group_rule" "db_vpn" {
  description              = "This rule allows traffic from vpn on port 3306"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.db.sg_id
}

resource "aws_security_group_rule" "db_bastion" {
  description              = "This rule allows traffic from bastion on port 3306"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.db.sg_id
}

resource "aws_security_group_rule" "db_node" {
  description              = "This rule allows traffic from node on port 3306"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.node.sg_id
  security_group_id        = module.db.sg_id
}

# ControlPlane Rules
resource "aws_security_group_rule" "controlplane_bastion" {
  description              = "EKS Cluster can be accessed from Bastion"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.controlplane.sg_id
}
resource "aws_security_group_rule" "controlplane_node" {
  description              = "EKS Cluster Can be Accessed all traffic from NodeGroup"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = module.node.sg_id
  security_group_id        = module.controlplane.sg_id
}

# NodeGroup Rules
resource "aws_security_group_rule" "node_bastion" {
  description              = "Nodes allow SSH from bastion"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.node.sg_id
}
resource "aws_security_group_rule" "node_controlplane" {
  description              = "Nodes Can be Accessed all traffic from ControlPlane"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = module.controlplane.sg_id
  security_group_id        = module.node.sg_id
}

resource "aws_security_group_rule" "node_vpc" {
  type              = "ingress"
  description       = "EKS nodes should accept all traffic from nodes with in VPC CIDR range."
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = module.node.sg_id
}


resource "aws_security_group_rule" "node_ingress" {
  type                     = "ingress"
  description              = "node group allow node port range from ingress sg"
  from_port                = 30000
  to_port                  = 32768
  protocol                 = "TCP"
  source_security_group_id = module.ingress.sg_id
  security_group_id        = module.node.sg_id
}

resource "aws_security_group_rule" "node_https" {
  type                     = "ingress"
  description              = "node group allow https from ingress sg"
  from_port                = 443
  to_port                  = 443
  protocol                 = "TCP"
  source_security_group_id = module.ingress.sg_id
  security_group_id        = module.node.sg_id
}

resource "aws_security_group_rule" "node_http" {
  type                     = "ingress"
  description              = "node group allow http from ingress sg"
  from_port                = 80
  to_port                  = 80
  protocol                 = "TCP"
  source_security_group_id = module.ingress.sg_id
  security_group_id        = module.node.sg_id
}


# Ingress Rules
resource "aws_security_group_rule" "ingress_https" {
  description       = "Ingress can accept https from internet"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.ingress.sg_id
}

resource "aws_security_group_rule" "ingress_public_http" {
  type              = "ingress"
  description       = "Ingress ALB accepting traffic on 80"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.ingress.sg_id
}
