
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private_subnets[*].id
}

output "secret_name" {
  description = "Name of the secret created for the database"
  value       = var.secret_name
  sensitive   = true

}









output "kms_key_id" {
  description = "KMS key ID for Secrets Manager"
  value       = module.kms.secrets_manager_kms_key_id
}

output "rds_kms_key_id" {
  description = "KMS key ID for RDS MySQL"
  value       = module.kms.rds_kms_key_id
}

output "s3_kms_key_id" {
  description = "KMS key ID for S3 encryption"
  value       = module.kms.s3_kms_key_id
}

output "secrets_manager_kms_key_id" {
  description = "KMS key ID for Secrets Manager"
  value       = module.kms.secrets_manager_kms_key_id
}


output "rds_sg_id" {
  value       = aws_security_group.rds_sg.id
  description = "Security Group ID for RDS"
}


output "rds_instance_ids" {
  value       = module.rds_mysql.rds_instance_ids
  description = "Map of RDS instance IDs"
}

output "rds_endpoints" {
  value       = module.rds_mysql.rds_endpoints
  description = "Map of RDS instance endpoints"
}


output "bastion_sg_id" {
  description = "ID of the Bastion security group"
  value       = aws_security_group.bastion_sg.id
}

output "elb_security_group_ids" {
  description = "ID of the ELB security group"
  value       = aws_security_group.elb_sg.id

}

output "nginx_security_group_ids" {
  description = "ID of the Nginx security group"
  value       = aws_security_group.nginx_sg.id

}


output "vpn_security_group_ids" {
  description = "ID of the AWS security group"
  value       = aws_security_group.vpn_sg.id

}

output "public_route_table_ids" {
  description = "IDs of the public route tables"
  value       = aws_route_table.public_subnets[*].id
}
output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = aws_route_table.private_subnets[*].id
}

output "peer_public_route_table_ids" {
  description = "IDs of the peer public route tables"
  value       = aws_route_table.peer_public_subnets[*].id
}

output "peer_private_route_table_ids" {
  description = "IDs of the peer private route tables"
  value       = aws_route_table.peer_private_subnets[*].id
}

output "aws_sns_topic_alerts_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = aws_sns_topic.alerts.arn

}
