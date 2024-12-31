variable "prefix" {
  description = "The prefix to use for all resources"
  type        = string
}

variable "subnet_ids" {
  description = "The IDs of the subnets to use for the cluster"
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC to use for the cluster"
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

variable "user_data" {
  description = "The user data to use for the instances"
  type        = string
}

variable "desired_capacity" {
  description = "The desired capacity of the autoscaling group"
  type        = number
}

variable "min_size" {
  description = "The minimum size of the autoscaling group"
  type        = number
}

variable "max_size" {
  description = "The maximum size of the autoscaling group"
  type        = number
}

variable "scale_in" {
  type = object({
    scaling_adjustment = number
    cooldown           = number
    threshold          = number
  })
  description = "values for scale in"
}

variable "scale_out" {
  type = object({
    scaling_adjustment = number
    cooldown           = number
    threshold          = number
  })
  description = "values for scale out"
}
