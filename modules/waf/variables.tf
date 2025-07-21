variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "scope" {
  description = "WAF scope: REGIONAL or CLOUDFRONT"
  type        = string
  default     = "REGIONAL"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}


variable "waf_logging_group_arn" {
  description = "ARN of the CloudWatch log group for WAF logging"
  type        = string
}


variable "nginx_alb_arn" {
  description = "ARN of the NGINX ALB"
  type        = string
}

variable "waf_logging_role_arn" {
  description = "ARN of the IAM role for WAF logging"
  type        = string
}

