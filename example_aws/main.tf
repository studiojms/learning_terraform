module "network" {
  source = "./modules/network"
}
data "aws_secretsmanager_secret" "secret" {
  arn = "arn:aws:secretsmanager:us-east-1:000000000000:secret:prod/terraform/db-BIXMpu"
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.secret.id
}

resource "aws_instance" "example_instance" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  subnet_id              = module.network.subnet_id
  vpc_security_group_ids = [module.network.security_group_id]

  user_data = <<-EOF
              #!/bin/bash
              DB_STR="Server=${jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["Host"]};Database=${jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["DB"]};User=${jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["Username"]};Password=${jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["Password"]}"
              echo $DB_STR > /tmp/db_str.txt
              EOF
}


# resource "aws_eip" "example_eip" {
#   instance   = aws_instance.example_instance.id
#   depends_on = [aws_internet_gateway.example_igw]
# }

# resource "aws_ssm_parameter" "param" {
#   name  = "vm_ip"
#   type  = "String"
#   value = aws_eip.example_eip.public_ip
# }


