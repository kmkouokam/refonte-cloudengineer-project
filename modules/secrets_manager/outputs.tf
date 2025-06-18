output "secret_arn" {
  value       = aws_secretsmanager_secret.db_secret
  description = "ARN of the created secret"
}

output "secret_name" {
  value       = aws_secretsmanager_secret.db_secret
  description = "Name of the created secret"
}

output "secret_password" {
  value       = jsondecode(data.aws_secretsmanager_secret_version.retrieved.secret_string).password
  sensitive   = true
  description = "The retrieved password from the secret"
}
