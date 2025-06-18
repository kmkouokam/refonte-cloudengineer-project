output "ec2_role_name" {
  value = aws_iam_role.ec2_role.name
}

output "rds_monitoring_role_arn" {
  value = aws_iam_role.rds_monitoring_role.arn
}

output "waf_logging_role_arn" {
  value = aws_iam_role.waf_logging_role.arn
}

output "cloudtrail_logs_role_arn" {
  value = aws_iam_role.cloudtrail_logs_role.arn
}
