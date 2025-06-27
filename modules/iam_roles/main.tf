# ---------------------
# EC2 Instance Role
# ---------------------
resource "aws_iam_role" "ec2_role" {
  name               = "${var.env}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ---------------------
# CloudWatch Agent Role
# ---------------------

data "aws_iam_policy_document" "cw_agent_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cw_agent_role" {
  name               = "${var.env}-cw-agent-role"
  assume_role_policy = data.aws_iam_policy_document.cw_agent_assume.json
}

resource "aws_iam_role_policy_attachment" "ec2_cw_agent" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# ---------------------
# RDS MySQL Monitoring Role
# ---------------------
resource "aws_iam_role" "rds_monitoring_role" {
  name               = "${var.env}-rds-monitoring-role"
  assume_role_policy = data.aws_iam_policy_document.rds_assume.json
}

data "aws_iam_policy_document" "rds_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# ---------------------
# WAF Logging Role
# ---------------------
resource "aws_iam_role" "waf_logging_role" {
  name               = "${var.env}-waf-logging-role"
  assume_role_policy = data.aws_iam_policy_document.waf_assume.json
}

data "aws_iam_policy_document" "waf_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["waf.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "waf_logging" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "waf_logging_policy" {
  name   = "${var.env}-waf-logging-policy"
  role   = aws_iam_role.waf_logging_role.id
  policy = data.aws_iam_policy_document.waf_logging.json
}

# ---------------------
# CloudTrail Logging Role
# ---------------------
resource "aws_iam_role" "cloudtrail_logs_role" {
  name               = "${var.env}-cloudtrail-logs-role"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume.json
}

data "aws_iam_policy_document" "cloudtrail_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloudtrail_logs" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cloudtrail_logs_policy" {
  name   = "${var.env}-cloudtrail-logs-policy"
  role   = aws_iam_role.cloudtrail_logs_role.id
  policy = data.aws_iam_policy_document.cloudtrail_logs.json
}

# ---------------------
# CloudWatch monitoring role
#

data "aws_iam_policy_document" "ec2_cloudwatch_permissions" {
  statement {
    actions = [
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ec2_cloudwatch_metrics" {
  name   = "${var.env}-cloudwatch-metrics"
  role   = aws_iam_role.ec2_role.id
  policy = data.aws_iam_policy_document.ec2_cloudwatch_permissions.json
}


# ---------------------
# ec2 instance profiles
#

# For EC2 with SSM access
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.env}-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# For EC2 with CloudWatch Agent
resource "aws_iam_instance_profile" "cw_agent_instance_profile" {
  name = "${var.env}-cw-agent-instance-profile"
  role = aws_iam_role.cw_agent_role.name
}

# For EC2 with CloudWatch role
resource "aws_iam_instance_profile" "ec2_cloudwatch_metrics" {
  name = "${var.env}-cw-agent-instance-profile-${random_id.cw_agent_suffix.hex}"
  role = aws_iam_role.cw_agent_role.name
  depends_on = [
    aws_iam_role.cw_agent_role
  ]
}

resource "random_id" "cw_agent_suffix" {
  byte_length = 4
}
