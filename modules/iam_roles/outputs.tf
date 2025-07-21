#` Outputs for IAM roles and instance profiles

output "rds_monitoring_role_arn" {
  value = aws_iam_role.rds_monitoring_role.arn
}

output "waf_logging_role_arn" {
  value = aws_iam_role.waf_logging_role.arn
}

output "cloudtrail_logs_role_arn" {
  value = aws_iam_role.cloudtrail_logs_role.arn
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_instance_profile.name
}

output "cloudwatch_agent_role_name" {
  value = aws_iam_role.cw_agent_role.name
}

output "cloudwatch_agent_profile_name" {
  value = aws_iam_instance_profile.cw_agent_instance_profile.name
}

output "ec2_cloudwatch_metrics_name" {
  value = aws_iam_role_policy.ec2_cloudwatch_metrics.name
}

output "xray_instance_profile_name" {
  value = aws_iam_instance_profile.xray_instance_profile.name
}




