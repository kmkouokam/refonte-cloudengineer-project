output "secret_arn" {
  description = "ARN of the secret"
  value       = aws_secretsmanager_secret.db_secret.arn
}

output "secret_name" {
  description = "Name of the secret"
  value       = aws_secretsmanager_secret.db_secret.name
}

# Placeholder - implement later
output "example" {
  value = "secrets module stub"
}

output "aws_secretsmanager_secret_name" {
  description = "Name of the Secrets Manager secret holding DB credentials"
  value       = aws_secretsmanager_secret.db_secret.name
}

output "aws_secretsmanager_secret_version_id" {
  description = "Version ID of the Secrets Manager secret"
  value       = aws_secretsmanager_secret_version.db_secret_version.id
}
