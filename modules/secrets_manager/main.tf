# Generate a strong random password
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!@#$%&*()-_=+[]{}<>:?/"
}

# Create the secret in Secrets Manager
resource "aws_secretsmanager_secret" "db_secret" {
  name        = var.secret_name
  description = var.description
  kms_key_id  = var.kms_key_id

  tags = {
    Environment = var.env
  }
}

# Store the random password as secret value (JSON structure)
resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    password = random_password.password.result
  })
}

# Optional: Retrieve the secret (can be used elsewhere)
data "aws_secretsmanager_secret_version" "retrieved" {
  secret_id  = aws_secretsmanager_secret.db_secret.id
  depends_on = [aws_secretsmanager_secret_version.db_secret_version]
}
