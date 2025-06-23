variable "env" {
  description = "Environment name"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
}

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
}
