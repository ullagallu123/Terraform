variable "project_name" {
  description = "Name of the project to be used as an identifier."
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name, such as 'dev', 'staging', or 'prod'."
  type        = string
  default     = ""
}

variable "sg_description" {
  description = "Description of the security group."
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Tags to be applied to all resources."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "ID of the VPC where resources will be created."
  type        = string
  default     = ""
}

variable "name" {
  type = string
  default = ""
}

variable "sg_tags" {
  description = "Tags for the security group."
  type        = map(string)
  default     = {}
}

variable "ingress_rules" {
  description = "Inbound traffic rules for the security group."
  type        = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "egress_rules" {
  description = "Outbound traffic rules for the security group."
  type        = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [{
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }]
}
