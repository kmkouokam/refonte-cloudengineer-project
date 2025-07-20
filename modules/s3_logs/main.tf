resource "aws_s3_bucket" "logs" {
  bucket        = var.bucket_name
  force_destroy = true
  tags          = var.tags
}

# ✅ Enable versioning
resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ✅ Lifecycle rule to expire non-current (versioned) objects after 30 days
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    filter {
      prefix = "AWSLogs/${data.aws_caller_identity.current.account_id}/"
    }
    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    expiration {
      days = 365 # delete current objects older than 1 year (optional)
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}


resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.logs.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

