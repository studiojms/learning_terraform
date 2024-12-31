variable "prefix" {
  description = "The prefix to use for all resources"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to use for the cluster"
  type        = string
}

variable "security_group_ids" {
  description = "The IDs of the security groups to use for the cluster"
  type        = list(string)
}

variable "instance_count" {
  description = "The number of instances to launch"
  type        = number

}
