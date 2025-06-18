# variable "secret_name" {
#   description = "Name of the secret"
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

variable "description" {
  description = "Description of the secret"
  type        = string
  default     = "Secret managed by Terraform"
}

variable "secret_value" {
  description = "Key-value map of the secret data"
  type        = map(string)
}

variable "db_username" {
  description = "The database username"
  type        = string
  sensitive   = true
}

# variable "db_password" {
#   description = "The database password"
#   type        = string
#   sensitive   = true
# }

variable "tags" {
  description = "Tags to apply to the secret"
  type        = map(string)
  default     = {}
}
variable "env" {
  description = "Environment for the secret (e.g., dev, prod)"
  type        = string
  default     = "dev"
}
