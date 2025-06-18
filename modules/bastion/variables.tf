variable "aws_region" {
  default = "us-east-1"
}

variable "bastion_instance_type" {
  description = "Instance type for the bastion host"
  type        = string
}

variable "bastion_instance_id" {
  description = "The ID of the bastion host instance"
  type        = string

}

variable "public_subnet_id" {
  description = "The public subnet ID to launch the bastion host in"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID for the bastion host"
  type        = string
}

variable "key_name" {
  description = "The SSH key name"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed for SSH"
  type        = list(string)
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
}

variable "env" {
  description = "Environment name"
  type        = string
}

# variable "ec2_instance_profile" {
#   description = "IAM instance profile name to attach to the EC2 instance"
#   type        = string
# }

# variable "secret_name" {}

variable "security_group_id" {
  description = "Security group ID for the bastion"
  type        = string
}



