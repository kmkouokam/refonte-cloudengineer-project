data "aws_caller_identity" "current" {}

#########################################
# KMS Key for Secrets Manager
#########################################
resource "aws_kms_key" "secrets_manager" {
  description             = "KMS key for Secrets Manager encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 20
}

resource "aws_kms_key_policy" "secrets_manager_policy" {
  key_id = aws_kms_key.secrets_manager.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "Enable IAM Root Access",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "Allow Secrets Manager",
        Effect = "Allow",
        Principal = {
          Service = "secretsmanager.amazonaws.com"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
}

#########################################
# KMS Key for RDS MySQL
#########################################
resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS MySQL encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 20
}

resource "aws_kms_key_policy" "rds_policy" {
  key_id = aws_kms_key.rds.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "Enable IAM Root Access",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "Allow RDS",
        Effect = "Allow",
        Principal = {
          Service = "rds.amazonaws.com"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
}

#########################################
# KMS Key for S3 (e.g., CloudTrail logs)
#########################################
resource "aws_kms_key" "s3" {
  description             = "KMS key for S3 encryption (e.g., CloudTrail logs)"
  enable_key_rotation     = true
  deletion_window_in_days = 20
}

resource "aws_kms_key_policy" "s3_policy" {
  key_id = aws_kms_key.s3.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "Enable IAM Root Access",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "Allow S3 Service",
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
}
 
