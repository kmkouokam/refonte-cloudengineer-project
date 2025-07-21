
variable "aws_region" {
  description = "AWS region to deploy the bastion host"
  type        = string

}

variable "bastion_instance_type" {
  description = "Instance type for the bastion host"
  type        = string
}


variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
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


variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile to attach"
  type        = string
}


variable "security_group_ids" {
  description = "List of Security Group IDs to associate with Bastion"
  type        = list(string)
}










