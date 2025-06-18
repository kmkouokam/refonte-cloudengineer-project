output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "rds_identifier" {
  value = aws_db_instance.mysql.id
}

# Placeholder - implement later
output "example" {
  value = "rds_mysql module stub"
}
