variable "env" {
  default = "Production"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  type        = string
  description = "CIDR block for the VPC"
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "The provided vpc_cidr must be a valid CIDR block"
  }
}

variable "public_subnet_cidrs" {
  description = "List of CIDRs for public subnets"
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
  ]
}

variable "private_subnet_cidrs" {
  description = "List of CIDRs for private subnets"
  default = [
    "10.0.3.0/24",
    "10.0.4.0/24",
  ]
}

variable "ipv6_cidr_block" {
  description = "IPv6 CIDR block for inbound rules"
  type        = string
  default     = "::/0" # Allow all IPv6 traffic (you can change this)
}

# variable "bastion_ami" {
#   description = "AMI ID for the bastion host"
#   type        = string
# }

variable "bastion_instance_type" {
  description = "Instance type for the bastion host"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair to use for the bastion host"
  type        = string
  default     = "virg.keypair"
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDRs allowed to SSH into the bastion host"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}


variable "tags" {
  description = "values for the tags to be applied to the resources"
  type        = map(string)
  default = {
    Owner       = "Ernestine D Motouom"
    Project     = "refonte_class"
    Environment = "Production"
  }

}
