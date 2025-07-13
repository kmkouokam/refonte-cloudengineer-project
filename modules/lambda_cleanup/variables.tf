variable "env" {
  description = "The environment for the resources"
  type        = string
  default     = "dev"
}

variable "aws_sns_topic_arn" {
  description = "SNS Topic ARN for cleanup Lambda alerts"
  type        = string
}


