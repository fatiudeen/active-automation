provider "aws" {
  region = local.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

locals {
  name   = "active-cluster"
  region = "us-east-1"

  vpc_cidr = "10.123.0.0/16"
  azs      = ["us-east-1a", "us-east-1b"]

  public_subnets  = ["10.123.11.0/24", "10.123.12.0/24"]
  private_subnets = ["10.123.13.0/24", "10.123.14.0/24"]
  intra_subnets   = ["10.123.15.0/24", "10.123.16.0/24"]

  tags = {
    Name = local.name
  }
}
