variable "peer_vpc_id" {
  description = "VPC ID of the peer VPC"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID of the current VPC"
  type        = string
}

variable "peer_aws_region" {
  description = "AWS region of the peer VPC"
  type        = string
}


variable "auto_accept" {
  type    = bool
  default = false
}

variable "public_route_table_ids" {
  type = list(string)
}

variable "private_route_table_ids" {
  type = list(string)
}

variable "peer_public_route_table_ids" {
  type = list(string)
}

variable "peer_private_route_table_ids" {
  type = list(string)
}

variable "env" {
  description = "The environment for the resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the current VPC"
  type        = string
}

variable "peer_vpc_cidr" {
  description = "CIDR block of the accepter VPC"
  type        = string
}
