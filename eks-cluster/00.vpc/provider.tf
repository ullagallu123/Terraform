terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.78.0"
    }
  }
  backend "s3" {
    bucket         = "eks-cluster-state.bapatlas.site"
    key            = "vpc/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "eks-cluster-state-locking.bapatlas.site"
    profile        = "eks-siva.bapatlas.site"
  }
}

provider "aws" {
  profile = "eks-siva.bapatlas.site"
  region  = "ap-south-1"
}

