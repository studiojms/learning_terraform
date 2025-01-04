# provider "aws" {
#   region     = "us-east-1"
#   access_key = "test"
#   secret_key = "test"
#   #   profile = "localstack"
# }

variables {
  prefix             = "test"
  vpc_cidr_block     = "10.0.0.0/16"
  subnet_cidr_blocks = ["10.0.0.0/24", "10.0.1.0/24"]
}

run "validate_vpc" {
  command = plan

  assert {
    condition     = aws_vpc.vpc.cidr_block == var.vpc_cidr_block
    error_message = "Unexpected VPC CIDR block"
  }

  assert {
    condition     = aws_vpc.vpc.tags.Name == "test-vpc"
    error_message = "Unexpected VPC tag name"
  }
}

run "validate_subnets" {
  command = plan

  assert {
    condition     = length(aws_subnet.subnets) == length(var.subnet_cidr_blocks)
    error_message = "Unexpected number of subnets"
  }

  assert {
    condition     = aws_subnet.subnets[0].cidr_block == var.subnet_cidr_blocks[0]
    error_message = "Unexpected subnet CIDR block"
  }

  assert {
    condition     = aws_subnet.subnets[1].cidr_block == var.subnet_cidr_blocks[1]
    error_message = "Unexpected subnet CIDR block"
  }

  assert {
    condition     = aws_subnet.subnets[0].availability_zone != aws_subnet.subnets[1].availability_zone
    error_message = "Subnets are in the same availability zone"
  }
}
