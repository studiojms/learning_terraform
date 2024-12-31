output "subnet_ids" {
  value = aws_subnet.subnets[*].id
}

output "security_group_id" {
  value = aws_security_group.sg_ssh.id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}
