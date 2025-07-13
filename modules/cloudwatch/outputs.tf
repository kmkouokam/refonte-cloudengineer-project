

# modules/cloudwatch/outputs.tf
output "waf_logging_group_arn" {
  value = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:aws-waf-logs-${var.env}:*"
}

