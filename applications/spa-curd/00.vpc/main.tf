module "vpc" {
  source               = "../../../modules/vpc"
  vpc_cidr             = "192.168.0.0/16"
  environment          = var.environment
  project_name         = var.project_name
  az                   = ["ap-south-1a", "ap-south-1b"]
  public_subnet_cidr   = ["192.168.1.0/24", "192.168.2.0/24"]
  private_subnet_cidr  = ["192.168.11.0/24", "192.168.12.0/24"]
  db_subnet_cidr       = ["192.168.21.0/24", "192.168.22.0/24"]
  per_az_route_tables  = false
  single_nat           = false
  per_az_nat           = false
  db_subnet_group      = true
  enable_vpc_flow_logs = false
  common_tags = {
    Developer = "Sivaramakrishna"
    Terraform = true
  }
  vpc_tags = {
    "Component" = "VPC"
  }
  igw_tags = {
    "Component" = "IGW"
  }
  public_subnet_tags = {
    "Component" = "PublicSubnets"
  }
  private_subnet_tags = {
    "Component" = "PrivateSubnets"
  }
  db_subnet_tags = {
    "Component" = "DBSubnets"
  }
  db_subnet_group_tags = {
    "Component" = "DB subnet group"
  }
  public_rt_tags = {
    "Component" = "Public RT"
  }
  private_rt_tags = {
    "Component" = "Private RT"
  }
  db_rt_tags = {
    "Component" = "DB RT"
  }
  eip_tags = {
    "Component" = "EIP"
  }
  nat_tags = {
    "Component" = "NAT GW"
  }
}