terraform {
  backend "s3" {
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
  }
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.42.0"
    }
  }
}
