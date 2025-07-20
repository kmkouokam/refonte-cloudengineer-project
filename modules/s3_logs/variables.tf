# This file contains the variables for the S3 bucket module.


variable "env" {
  description = "The environment for which the S3 bucket is being created (e.g., dev, prod)"
  type        = string
}
variable "tags" {
  description = "A map of tags to assign to the S3 bucket"
  type        = map(string)
}


variable "bucket_name" {
  description = "The name of the S3 bucket to be created"
  type        = string

}
