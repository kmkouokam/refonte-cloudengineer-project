output "frontend_instance_id" {
  value = aws_launch_template.nginx[*].id
}

output "frontend_instance_name" {
  value       = aws_launch_template.nginx[*].name
  description = "Name of the EC2 instance running the NGINX frontend"

}

output "nginx_alb_name" {
  value       = aws_lb.nginx_alb.name
  description = "Name of the NGINX Application Load Balancer"

}

output "nginx_alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = aws_lb.nginx_alb.arn
}


