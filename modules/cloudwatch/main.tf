## CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.env}-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric",
        x      = 0,
        y      = 0,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", "i-xxxxxxx"]
          ],
          period = 300,
          stat   = "Average",
          region = var.aws_region,
          title  = "EC2 CPU Utilization"
        }
      }
    ]
  })
}

##SNS Topic for Alarms
resource "aws_sns_topic" "alerts" {
  name = "${var.env}-cloudwatch-alerts"
}

resource "aws_sns_topic_subscription" "sns_email" {
  for_each  = toset(var.notification_emails)
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = each.value

}

##CloudWatch Alarms for rds
resource "aws_cloudwatch_metric_alarm" "rds_high_cpu" {
  for_each            = var.rds_instance_names
  alarm_name          = "${var.env}-rds-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "This metric monitors high CPU utilization on RDS"
  dimensions = {
    DBInstanceIdentifier = each.value
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}
resource "aws_cloudwatch_metric_alarm" "rds_high_memory" {
  for_each            = var.rds_instance_names
  alarm_name          = "${var.env}-rds-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 1000000000
  alarm_description   = "This metric monitors low freeable memory on RDS"
  dimensions = {
    DBInstanceIdentifier = each.value
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

##CloudWatch Alarms for EC2 frondend
resource "aws_cloudwatch_metric_alarm" "ec2_high_cpu" {
  count               = length(var.frontend_instance_name)
  alarm_name          = "${var.env}-ec2-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors high CPU utilization on EC2 instances"
  dimensions = {
    InstanceId = element(var.frontend_instance_name, count.index + 1) # Replace with your actual instance name
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "ec2_high_disk" {
  count               = length(var.frontend_instance_name)
  alarm_name          = "${var.env}-ec2-high-disk"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DiskSpaceUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "This metric monitors high disk space utilization on EC2 instances"
  dimensions = {
    InstanceId = element(var.frontend_instance_name, count.index + 1) # Replace with your actual instance name
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_log_group" "waf_metrics" {
  name              = "aws-waf-logs-${var.env}"
  retention_in_days = 14

  tags = {
    Name        = "WAF Log Group"
    Environment = var.env
  }

}

data "aws_caller_identity" "current" {}




