data "aws_caller_identity" "current" {}

# modules/cost_optimization/main.tf
# This module sets up cost optimization strategies including budget alerts and anomaly detection

resource "aws_ce_cost_category" "env_category" {
  name         = "EnvironmentCategory"
  rule_version = "CostCategoryExpression.v1"

  rule {
    value = "Production"
    rule {
      dimension {
        key    = "LINKED_ACCOUNT"
        values = [data.aws_caller_identity.current.account_id]
      }
    }
    type = "REGULAR"
  }

  rule {
    value = "Development"
    rule {
      dimension {
        key    = "LINKED_ACCOUNT"
        values = [data.aws_caller_identity.current.account_id]
      }
    }
    type = "REGULAR"
  }
}

resource "aws_ce_anomaly_monitor" "ec2_monitor" {
  name              = "ec2-anomaly-monitor"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"

  #   monitor_specification = jsonencode({
  #     Dimensions = ["SERVICE "]
  #   })
  tags = {
    Environment = var.env
  }
}

resource "aws_ce_anomaly_subscription" "email_alert" {
  name             = "cost-anomaly-subscription"
  frequency        = "DAILY"
  monitor_arn_list = [aws_ce_anomaly_monitor.ec2_monitor.arn]

  dynamic "subscriber" {
    for_each = var.alert_email
    content {
      type    = "EMAIL"
      address = subscriber.value
    }
  }
  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      match_options = ["GREATER_THAN_OR_EQUAL"]
      values        = ["100"]
    }
  }
}

resource "aws_budgets_budget" "monthly_budget" {
  name_prefix  = "monthly-project-budget"
  budget_type  = "COST"
  limit_amount = var.budget_amount
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  cost_types {
    include_tax                = true
    include_subscription       = true
    use_blended                = false
    include_recurring          = true
    include_upfront            = true
    include_other_subscription = true
  }

  cost_filter {
    name   = "Service"
    values = ["Amazon Elastic Compute Cloud - Compute"]
  }

  dynamic "notification" {
    for_each = var.alert_email
    content {
      comparison_operator        = "GREATER_THAN"
      notification_type          = "ACTUAL"
      threshold                  = 79
      threshold_type             = "PERCENTAGE"
      subscriber_email_addresses = [notification.value]
      subscriber_sns_topic_arns  = []
    }
  }
  lifecycle {
    ignore_changes = [
      notification
    ]
  }

  tags = {
    Environment = var.env
  }

}
