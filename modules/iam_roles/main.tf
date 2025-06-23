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
# ece instance profile
#
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.env}-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}
