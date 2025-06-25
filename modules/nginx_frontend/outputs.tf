output "frontend_instance_id" {
  value = aws_launch_template.nginx[*].id
}

output "frontend_instance_name" {
  value       = aws_launch_template.nginx[*].name
  description = "Name of the EC2 instance running the NGINX frontend"

}
