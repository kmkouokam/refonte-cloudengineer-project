variable "env" {
  type = string
}


variable "rds_instances" {
  description = "Map of RDS instance configs. Keys are used as instance suffixes."
  type = map(object({
    db_name            = string
    db_username        = string
    db_password        = string
    private_subnet_ids = list(string)
    az_name            = string
  }))
}


variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "engine_version" {
  type    = string
  default = "8.0"
}

variable "storage_size" {
  type    = number
  default = 20
}


variable "security_group_ids" {
  type = list(string)
}

variable "kms_key_id" {
  type = string
}


variable "rds_monitoring_role_arn" {
  description = "The ARN of the IAM role for RDS monitoring"
  type        = list(string)

}


