# Terraform AWS Security Group Module

## Overview

This Terraform module creates an AWS Security Group with customizable ingress and egress rules. The security group is tagged according to the project name, environment, and other provided tags.

## Variables

- **`project_name`** (string, default: `""`): Specifies the name of the project.
- **`environment`** (string, default: `""`): Defines the environment (e.g., `development`, `staging`, `production`).
- **`sg_description`** (string, default: `""`): A description for the security group.
- **`common_tags`** (map, default: `{}`): A map of common tags applied to all resources.
- **`sg_tags`** (map, default: `{}`): A map of tags specifically for the security group.
- **`name`** (string, default: `""`): The name of the security group.
- **`vpc_id`** (string, default: `""`): The ID of the VPC where the security group will be created.
- **`ingress_rules`** (list of objects, default: `[]`): List of ingress rules defining allowed inbound traffic.
  - **description** (string): Description of the ingress rule.
  - **from_port** (number): Starting port for the rule.
  - **to_port** (number): Ending port for the rule.
  - **protocol** (string): Protocol (e.g., `tcp`, `udp`, `-1` for all protocols).
  - **cidr_blocks** (list of strings): List of CIDR blocks allowed by the rule.
- **`egress_rules`** (list of objects, default: Allow all outbound traffic):
  - **description** (string): Description of the egress rule.
  - **from_port** (number): Starting port for the rule.
  - **to_port** (number): Ending port for the rule.
  - **protocol** (string): Protocol (e.g., `tcp`, `udp`, `-1` for all protocols).
  - **cidr_blocks** (list of strings): List of CIDR blocks allowed by the rule.

## Outputs

- **`sg_id`**: The ID of the created security group.

## Usage

```hcl
module "security_group" {
  source = "git::https://github.com/ullagallu123/sg.git?ref=main"

  project_name   = "my-project"
  environment    = "production"
  name           = "web-sg"
  vpc_id         = "vpc-123456"
  sg_description = "Security group for web servers"

  ingress_rules = [
    {
      description = "Allow HTTP traffic"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow HTTPS traffic"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  common_tags = {
    "Project" = "my-project"
    "Owner"   = "team"
  }

  sg_tags = {
    "Environment" = "production"
  }
}
