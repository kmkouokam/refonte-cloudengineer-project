variable "public_subnet_ids" {
  description = "List of public subnet IDs for VPN"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for VPN"
  type        = list(string)
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

# variable "subnet_ids" {
#   description = "IDs of the subnets where the VPN will be deployed"
#   type        = list(string)
# }
