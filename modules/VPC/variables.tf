# VPC and Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "environment" {
  description = "The environment name (e.g., dev, prod)"
  type        = string
}

variable "project_name" {
  description = "The project name"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

# Availability Zones
variable "az" {
  description = "List of availability zones"
  type        = list(string)
  validation {
    condition     = length(var.az) > 0
    error_message = "Please provide at least one availability zone"
  }
}

# Subnet Configuration
variable "public_subnet_cidr" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidr" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "db_subnet_cidr" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
}

# Route Table Configuration
variable "per_az_route_tables" {
  description = "Set to true to create route tables per AZ, false for a single route table per type"
  type        = bool
}

# NAT Gateway Configuration
variable "single_nat" {
  description = "Set to true to create a single NAT Gateway"
  type        = bool
}

variable "per_az_nat" {
  description = "Set to true to create a NAT Gateway in each AZ"
  type        = bool
}

# DB Subnet Configuration
variable "db_subnet_group" {
  description = "Set true to create DB subnet group"
  type        = bool
}

# Tags for Resources
variable "vpc_tags" {
  description = "Tags for the VPC"
  type        = map(string)
}

variable "igw_tags" {
  description = "Tags for the Internet Gateway"
  type        = map(string)
}

variable "public_subnet_tags" {
  description = "Tags for the public subnets"
  type        = map(string)
}

variable "private_subnet_tags" {
  description = "Tags for the private subnets"
  type        = map(string)
}

variable "db_subnet_tags" {
  description = "Tags for the DB subnets"
  type        = map(string)
}

variable "public_rt_tags" {
  description = "Tags for the public route tables"
  type        = map(string)
}

variable "private_rt_tags" {
  description = "Tags for the private route tables"
  type        = map(string)
}

variable "db_rt_tags" {
  description = "Tags for the database route tables"
  type        = map(string)
}

variable "db_subnet_group_tags" {
  description = "Tags for the DB subnet group"
  type        = map(string)
}

variable "eip_tags" {
  description = "Tags for the Elastic IPs"
  type        = map(string)
}

variable "nat_tags" {
  description = "Tags for the NAT Gateway"
  type        = map(string)
}

# Flow Logs Configuration
variable "enable_vpc_flow_logs" {
  description = "Enable VPC flow logs"
  type        = bool
  default     = false
}
