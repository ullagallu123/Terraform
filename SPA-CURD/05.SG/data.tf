data "terraform_remote_state" "vpc" {
  backend = "remote"
  config = {
    organization = "your-terraform-cloud-org" 
    workspaces = {
      name = "vpc"
    }
  }
}