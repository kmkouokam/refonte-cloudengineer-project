resource "aws_wafv2_web_acl" "waf-metrics" {
  name        = "${var.env}-waf"
  description = "WAF for ${var.env} environment"
  scope       = var.scope # "REGIONAL" for ALB, "CLOUDFRONT" for CloudFront

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.env}-waf-metrics"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
    }
  }

  tags = var.tags
}


resource "aws_wafv2_web_acl_association" "waf_to_alb" {
  resource_arn = var.nginx_alb_arn # Replace with your actual ALB ARN
  web_acl_arn  = aws_wafv2_web_acl.waf-metrics.arn

  depends_on = [
  aws_wafv2_web_acl.waf-metrics]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_logging" {
  log_destination_configs = [
    var.waf_logging_group_arn # CloudWatch log group for WAF logs
  ]

  resource_arn = aws_wafv2_web_acl.waf-metrics.arn

  redacted_fields {
    method {}
  }

  redacted_fields {
    uri_path {}
  }

  depends_on = [
    var.waf_logging_group_arn,
    aws_wafv2_web_acl.waf-metrics
  ]
}

