module "bastion" {
  source         = "../../../modules/sg"
  project_name   = var.project_name
  environment    = var.environment
  name = "bastion"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  sg_description = "This SG was used for Bastion"
  common_tags = {
    "Terraform" = true
    "Developer" = "Sivaramakrishna"
  }
  sg_tags = {
    "Component" = "Bastion"
  }
}
module "vpn" {
  source         = "../../../modules/sg"
  project_name   = var.project_name
  environment    = var.environment
  name = "vpn"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  sg_description = "This SG was used for VPN"
  common_tags = {
    "Terraform" = true
    "Developer" = "Sivaramakrishna"
  }
  sg_tags = {
    "Component" = "VPN"
  }
}
module "backend" {
  source         = "../../../modules/sg"
  project_name   = var.project_name
  environment    = var.environment
  name = "backend"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  sg_description = "This SG was used for backend container"
  common_tags = {
    "Terraform" = true
    "Developer" = "Sivaramakrishna"
  }
  sg_tags = {
    "Component" = "Backend"
  }
}

module "db" {
  source         = "../../../modules/sg"
  project_name   = var.project_name
  environment    = var.environment
  name="db"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  sg_description = "This SG was used for RDS MySQL"
  common_tags = {
    "Terraform" = true
    "Developer" = "Sivaramakrishna"
  }
  sg_tags = {
    "Component" = "RDS-MYSQL"
  }
}

module "alb" {
  source         = "../../../modules/sg"
  project_name   = var.project_name
  environment    = var.environment
  name = "alb"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  sg_description = "This SG was used for ALB"
  common_tags = {
    "Terraform" = true
    "Developer" = "Sivaramakrishna"
  }
  sg_tags = {
    "Component" = "ALB"
  }
}


resource "aws_security_group_rule" "vpn_db" {
  description              = "This rule allows traffic from vpn on port 3306"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.db.sg_id
}

resource "aws_security_group_rule" "bastion_db" {
  description              = "This rule allows traffic from bastion on port 3306"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.db.sg_id
}

resource "aws_security_group_rule" "backend_db" {
  description              = "This rule allows traffic from backend on port 3306"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.backend.sg_id
  security_group_id        = module.db.sg_id
}

resource "aws_security_group_rule" "alb_backend" {
  description              = "This rule allows traffic from ALB on port 8080"
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.alb.sg_id
  security_group_id        = module.backend.sg_id
}

resource "aws_security_group_rule" "bastion_backend" {
  description              = "This rule allows traffic from bastion on port 8080"
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.backend.sg_id
}

resource "aws_security_group_rule" "vpn_backend" {
  description              = "This rule allows traffic from vpn on port 8080"
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.backend.sg_id
}




resource "aws_security_group_rule" "bastion_ssh" {
  description       = "This rule allows all traffic from internet on 22"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastion.sg_id
}

# VPN
resource "aws_security_group_rule" "vpn_ssh" {
  description       = "This rule allows all traffic from internet on 22"
  type              = "ingress"
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


resource "aws_security_group_rule" "vpn_alb" {
  description              = "This rule allows traffic from vpn on port 80"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id        = module.alb.sg_id
}

resource "aws_security_group_rule" "bastion_alb" {
  description              = "This rule allows traffic from bastion on port 80"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id        = module.alb.sg_id
}

resource "aws_security_group_rule" "vpn_http_backend" {
  description       = "This rule allows traffic from cloud front on port 80"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.alb.sg_id
}

resource "aws_security_group_rule" "vpn_https_backend" {
  description       = "Allow traffic from CloudFront on port 443"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.alb.sg_id
}
