variable "project_name" {
  default     = ""
  description = "Specifies the name of the project. It is currently an empty string, so you can set it to your project's name."
}

variable "environment" {
  default     = ""
  description = "Defines the environment for which the resources are being created, such as 'development', 'staging', or 'production'."
}

variable "sg_description" {
  default     = ""
  description = "A description for the security group. This provides information about the purpose or usage of the security group."
}

variable "common_tags" {
  default     = {}
  description = "A map of common tags that will be applied to all resources. Tags are useful for organizing and managing resources."
}
variable "vpc_id" {
  default     = ""
  description = "The ID of the VPC (Virtual Private Cloud) where the security group will be created. This links the security group to a specific VPC."
}

variable "ingress_rules" {
  description = "List of ingress rules that define the inbound traffic allowed to the security group. Each ingress rule object contains: description, from_port, to_port, protocol, and cidr_blocks."
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules that define the outbound traffic allowed by the security group. Each egress rule object contains: description, from_port, to_port, protocol, and cidr_blocks."
  type = list(object({
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
