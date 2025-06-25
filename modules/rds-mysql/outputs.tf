output "rds_endpoint" {
  value       = aws_db_instance.rds_instance.endpoint
  description = "RDS MySQL endpoint"
}

output "rds_instance_id" {
  value = aws_db_instance.rds_instance.id
}

output "rds_instance_name" {
  value       = aws_db_instance.rds_instance.db_name
  description = "RDS MySQL instance name"

}

output "private_subnet_ids" {
  description = "IDs of the private subnets used by RDS"
  value       = aws_db_subnet_group.rds_subnet_group[*].id

}
