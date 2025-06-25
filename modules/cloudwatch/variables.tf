# # 
# variable "frontend_instance_id" {
#   description = "The ID of the EC2 instance running the frontend application"
#   type        = string

# }

# variable "rds_instance_id" {
#   description = "The ID of the RDS instance"
#   type        = string
# }

variable "env" {
  description = "The environment name (e.g., dev, prod)"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "The name of the IAM instance profile for EC2 instances"
  type        = string

}

variable "cloudwatch_agent_role_name" {
  description = "The name of the IAM role for the CloudWatch agent"
  type        = string

}

variable "cloudwatch_agent_profile_name" {
  description = "The name of the IAM instance profile for the CloudWatch agent"
  type        = string
}

variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string

}

variable "rds_instance_name" {
  description = "The name of the RDS instance"
  type        = string
}

variable "frontend_instance_name" {
  description = "The name of the EC2 instance running the frontend application"
  type        = list(string)
}
