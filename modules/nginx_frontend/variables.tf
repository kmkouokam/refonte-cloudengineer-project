variable "env" {}

variable "forntend_instance_type" {
  description = "The instance type for the frontend"

  type = string
}
variable "iam_instance_profile_name" {
  description = "The IAM instance profile name to attach to the frontend instances"
  type        = string
}
variable "public_subnet_ids" {
  description = "The public subnet IDs to launch the frontend instances in"
  type        = list(string)
}
variable "vpc_id" { type = string }

variable "key_name" {
  description = "The SSH key name"
  type        = string
}
variable "elb_security_group_ids" {
  description = "The security group ID for the ELB"
  type        = list(string)
}

variable "nginx_security_group_ids" {
  type        = list(string)
  description = "The security group ID for the NGINX instances"
}

variable "desired_capacity" {

  description = "The desired number of instances in the ASG"
  type        = number
}
variable "min_size" {

  description = "The minimum number of instances in the ASG"
  type        = number
}
variable "max_size" {

  description = "The maximum number of instances in the ASG"
  type        = number
}
