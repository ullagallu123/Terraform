terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.82.2"
    }
  }
}

provider "aws" {
  profile = "eks-siva.bapatlas.site"
  region  = "ap-south-1"
}