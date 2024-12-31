terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82"
    }
  }
}

data "aws_secretsmanager_secret" "secret" {
  arn = "arn:aws:secretsmanager:us-east-1:000000000000:secret:prod/terraform/db-BIXMpu"
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.secret.id
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
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.example_subnet.id
  vpc_security_group_ids = [aws_security_group.example_sg_ssh.id]

  user_data = <<-EOF
              #!/bin/bash
              DB_STR="Server=${jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["Host"]};Database=${jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["DB"]};User=${jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["Username"]};Password=${jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["Password"]}"
              echo $DB_STR > /tmp/db_str.txt
              EOF
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

resource "aws_route_table" "example_rt" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }
}

resource "aws_route_table_association" "example_rta" {
  subnet_id      = aws_subnet.example_subnet.id
  route_table_id = aws_route_table.example_rt.id
}

resource "aws_security_group" "example_sg_ssh" {
  vpc_id = aws_vpc.example_vpc.id
  name   = "Allow SSH"

  tags = {
    Name = "Allow SSH"
  }
}

resource "aws_vpc_security_group_ingress_rule" "example_sg_ingress_rule_ssh" {
  security_group_id = aws_security_group.example_sg_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "example_sg_egress_rule" {
  security_group_id = aws_security_group.example_sg_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

output "private_dns" {
  value = aws_instance.example_instance.private_dns
}

output "eip" {
  value = aws_eip.example_eip.public_ip
}
