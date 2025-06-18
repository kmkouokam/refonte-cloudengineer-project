variable "env" {
  description = "Environment name (e.g., Production, Staging)"
  type        = string
  default     = "Production"
}
variable "vpc_id" {
  description = "VPC ID where the RDS instance will be created"
  type        = string
}
variable "private_subnet_ids" {
  type = list(string)
}
# variable "secret_name" {
#   description = "Name of the Secrets Manager secret holding DB credentials"
#   type        = string
# }
variable "aws_secretsmanager_secret_name" {
  description = "AWS Secrets Manager secret resource"
  type        = any

}

variable "aws_secretsmanager_secret_version_id" {
  description = "AWS Secrets Manager secret version resource"
  type        = any

}

variable "secret_value" {
  description = "Map containing db_username and db_password"
  type        = map(string)
}


variable "engine_version" {
  default = "8.0"
}



variable "instance_class" {
  default = "db.t3.medium"
}
variable "allocated_storage" {
  default = 20
}
variable "max_allocated_storage" {
  default = 100
}
variable "backup_retention" {
  default = 7
}
# variable "kms_key_id" {
#   description = "KMS Key ID for RDS encryption"
#   type        = string
#   default     = null
# }

variable "tags" {
  type = map(string)
}

# variable "frontend_sg_id" {}
variable "bastion_sg_id" {
  description = "Security group ID for the bastion host"
  type        = string
}

# variable "db_username" {
#   description = "The database username"
#   type        = string
# }

#  variable "db_password" {
#   description = "The database password"
#   type        = string
#   sensitive   = true
# }




