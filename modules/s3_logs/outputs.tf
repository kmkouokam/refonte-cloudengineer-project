output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.logs.bucket
}


output "bucket_arn" {
  value       = aws_s3_bucket.logs.arn
  description = "ARN of the S3 bucket"
}


