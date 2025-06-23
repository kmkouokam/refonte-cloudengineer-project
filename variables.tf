variable "env" {
  default = "production"
}

## variables.tf vpc
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
# variable "public_subnet_ids" {
#   description = "List of public subnet IDs"
#   type        = list(string)
# }

# variable "private_subnet_ids" {
#   type = list(string)
# }

variable "ipv6_cidr_block" {
  description = "IPv6 CIDR block for inbound rules"
  type        = string
  default     = "::/0" # Allow all IPv6 traffic (you can change this)
}


variable "secret_name" {
  type        = string
  description = "Name of the secret (e.g., /production/mysql/creds)"
  default     = "my_secret"
  validation {
    condition     = length(var.secret_name) > 0
    error_message = "The secret_name variable must be a non-empty string."
  }
}

variable "description" {
  type        = string
  default     = "Managed secret"
  description = "Description of the secret"
}

variable "kms_key_id" {
  type        = string
  description = "KMS key ID to encrypt the secret"
  default     = "alias/aws/secretsmanager" # Default to AWS managed key
  validation {
    condition     = length(var.kms_key_id) > 0
    error_message = "The kms_key_id variable must be a non-empty string."
  }
}

variable "multi_az" {
  type        = bool
  description = "Enable Multi-AZ deployment for RDS"

  default = false
  validation {
    condition     = can(var.multi_az)
    error_message = "The multi_az variable must be a boolean."
  }
}



variable "forntend_instance_type" {
  description = "The instance type for the frontend"
  default     = "t2.micro"
  type        = string
}






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


variable "desired_capacity" {
  default     = 2
  description = "The desired number of instances in the ASG"
  type        = number
}
variable "min_size" {
  default     = 1
  description = "The minimum number of instances in the ASG"
  type        = number
}
variable "max_size" {
  default     = 3
  description = "The maximum number of instances in the ASG"
  type        = number
}
