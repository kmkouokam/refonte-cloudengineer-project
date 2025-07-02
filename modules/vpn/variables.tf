variable "public_subnet_ids" {
  description = "List of public subnet IDs for VPN"
  type        = set(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for VPN"
  type        = set(string)
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)


}


variable "vpc_id" {
  description = "ID of the VPC where the VPN will be deployed"
  type        = string
}



variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}


variable "vpn_aws_security_group" {
  description = "ID of the AWS security group for VPN"
  type        = string
  default     = null
}

