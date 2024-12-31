terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82"
    }
  }
}

provider "aws" {
  #   region     = "us-east-1"
  #   access_key = "test"
  #   secret_key = "test"
  profile = "localstack"
}

resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "example_subnet" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_instance" "example_instance" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.example_subnet.id
}

resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example_vpc.id
}

resource "aws_eip" "example_eip" {
  instance   = aws_instance.example_instance.id
  depends_on = [aws_internet_gateway.example_igw]
}

resource "aws_ssm_parameter" "param" {
  name  = "vm_ip"
  type  = "String"
  value = aws_eip.example_eip.public_ip
}

output "private_dns" {
  value = aws_instance.example_instance.private_dns
}

output "eip" {
  value = aws_eip.example_eip.public_ip
}
