variable "env" {
  description = "The environment for the resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where Jenkins will be deployed"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy Jenkins"
  type        = string
  default     = "us-east-1"

}

variable "jenkins_instance_type" {
  description = "The instance type for the Jenkins EC2 instance"
  type        = string
  default     = "t2.micro"

}

variable "key_name" {
  description = "The name of the SSH key pair for accessing the Jenkins instance"
  type        = string

}

variable "public_subnet_ids" {
  description = "The public subnet IDs to launch the frontend instances in"
  type        = list(string)
}




variable "bucket_name" {
  description = "The name of the S3 bucket for Jenkins logs"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy the bastion host"
  type        = string

}





variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}




variable "key_name" {
  description = "The SSH key name"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed for SSH"
  type        = list(string)
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
}

variable "env" {
  description = "Environment name"
  type        = string
}







variable "security_group_ids" {
  description = "List of Security Group IDs to associate with Bastion"
  type        = list(string)
}
