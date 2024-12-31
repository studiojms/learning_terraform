terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82"
    }
  }

  required_version = "~> 1.10.0"
}

provider "aws" {
  region  = "us-east-1"
  profile = "localstack"
  #   access_key = "test"
  #   secret_key = "test"
}
