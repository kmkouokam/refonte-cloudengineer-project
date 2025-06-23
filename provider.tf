## Provider Configuration


terraform {
  required_providers {


    random = {
      source = "hashicorp/random"
    }

    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

