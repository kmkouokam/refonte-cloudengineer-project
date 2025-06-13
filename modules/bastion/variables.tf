

variable "bastion_instance_type" {
  description = "Instance type for the bastion host"
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

