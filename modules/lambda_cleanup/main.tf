# terraform/lambda_cleanup/main.tf

resource "aws_iam_role" "lambda_cleanup_role" {
  name = "lambda-cleanup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_cleanup_policy" {
  name = "lambda-cleanup-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeAddresses",
          "ec2:ReleaseAddress",
          "ec2:DescribeVolumes",
          "ec2:DeleteVolume",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_cleanup_policy" {
  role       = aws_iam_role.lambda_cleanup_role.name
  policy_arn = aws_iam_policy.lambda_cleanup_policy.arn

}

resource "aws_iam_policy" "lambda_sns_publish" {
  name = "${var.env}-lambda-sns-publish"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "sns:Publish",
        Effect   = "Allow",
        Resource = var.aws_sns_topic_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sns_attachment" {
  role       = aws_iam_role.lambda_cleanup_role.name
  policy_arn = aws_iam_policy.lambda_sns_publish.arn
}



resource "aws_lambda_function" "cleanup" {
  filename         = "${path.module}/function.zip"
  function_name    = "CleanupUnusedResources"
  role             = aws_iam_role.lambda_cleanup_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = filebase64sha256("${path.module}/function.zip")

  environment {
    variables = {
      LOG_LEVEL     = "INFO",
      SNS_TOPIC_ARN = var.aws_sns_topic_arn
    }
  }
}

resource "aws_cloudwatch_event_rule" "weekly_cleanup" {
  description         = "trigger weekly cleanup of unused resources"
  name                = "weekly-cleanup-schedule"
  schedule_expression = "cron(0 0 ? * 1 *)" # every Monday at 00:00 UTC
}

resource "aws_cloudwatch_event_target" "cleanup_target" {
  rule      = aws_cloudwatch_event_rule.weekly_cleanup.name
  target_id = "CleanupTarget"
  arn       = aws_lambda_function.cleanup.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cleanup.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.weekly_cleanup.arn
}
