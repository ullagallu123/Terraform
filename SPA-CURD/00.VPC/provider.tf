terraform {
  backend "remote" {
    organization = "ECS-SPA"
    workspaces {
      name = "vpc"
    }
  }
}
