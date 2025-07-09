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

# output "rds_instance_ids" {
#   description = "RDS MySQL instance names"
#   value = {
#     for k, inst in aws_db_instance.rds_instance :
#     k => inst.id
#   }
# }






# output "rds_endpoint" {
#   value       = aws_db_instance.rds_instance[each.key].endpoint
#   description = "RDS MySQL endpoint"
# }

# output "rds_instance_id" {
#   value = aws_db_instance.rds_instance[each.key].id
# }

# output "rds_instance_name" {
#   value       = aws_db_instance.rds_instance[each.key].db_name
#   description = "RDS MySQL instance name"

# }

# output "private_subnet_ids" {
#   description = "IDs of the private subnets used by RDS"
#   value       = aws_db_subnet_group.rds_subnet_group[*].id

# }
