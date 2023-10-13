terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  backend "s3" {
    bucket = "tsy-iabs-terraform"
    key    = "terraform.tfstate"
    region = "ap-southeast-1"
  }

  required_version = ">= 0.14.9"
}