variable "env" {
  description = "The environment for the Jenkins instance (e.g., dev, staging, prod)"
  type        = string
}



variable "instance_type" {
  description = "The instance type for the Jenkins server"
  type        = string
}
variable "key_name" {
  description = "The name of the key pair to use for SSH access to the Jenkins instance"
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket to store Jenkins artifacts"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of Security Group IDs to associate with Bastion"
  type        = list(string)
}
