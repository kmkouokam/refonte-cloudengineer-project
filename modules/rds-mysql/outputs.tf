output "rds_endpoints" {
  description = "RDS MySQL endpoints"
  value = {
    for k, inst in aws_db_instance.rds_instance :
    k => inst.endpoint
  }
}

# modules/rds-mysql/outputs.tf
output "rds_instance_identifiers" {
  value = {
    for k, db in aws_db_instance.rds_instance :
    k => db.identifier
  }
}


output "rds_instance_ids" {
  description = "RDS MySQL instance IDs"
  value = {
    for k, inst in aws_db_instance.rds_instance :
    k => inst.id
  }
}









