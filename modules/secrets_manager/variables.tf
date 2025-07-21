variable "secret_name" {
  type        = string
  description = "Name of the secret (e.g., /production/mysql/creds)"
}

variable "description" {
  type        = string
  default     = "Managed secret"
  description = "Description of the secret"
}

variable "kms_key_id" {
  type        = string
  description = "KMS key ID to encrypt the secret"
}


variable "env" {
  type        = string
  description = "Environment tag"
}
