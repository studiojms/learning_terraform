variable "prefix" {
  description = "The prefix to use for all resources"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "subnet_cidr_blocks" {
  description = "The CIDR blocks for the subnets"
  type        = list(string)
}
