provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "eks-tfstate-file-22a"
    key            = "tfstate/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "EKS_statefile-lock-22a"
    encrypt        = true
  }
}