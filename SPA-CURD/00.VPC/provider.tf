terraform {
  backend "remote" {
    organization = "ECS-SPA"
    workspaces {
      name = "vpc"
    }
  }
}

provider "aws" {
  profile = "mumbai"
  region = "ap-south-1"
}
