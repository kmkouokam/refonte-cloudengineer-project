output "secrets_manager_kms_key_id" {
  value       = aws_kms_key.secrets_manager.id
  description = "KMS key ID for Secrets Manager"
}

output "rds_kms_key_id" {
  value       = aws_kms_key.rds.id
  description = "KMS key ID for RDS MySQL"
}

output "s3_kms_key_id" {
  value       = aws_kms_key.s3.id
  description = "KMS key ID for S3 encryption"
}

