variable "budget_amount" {
  description = "Monthly budget amount in USD"
  type        = number
  default     = 100
}

variable "alert_email" {
  description = "Email address to send budget alerts"
  type        = list(string)
  default = [
    "kmkouokam@yahoo.com", "nycarine0@gmail.com"
  ]
}

variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string

}
