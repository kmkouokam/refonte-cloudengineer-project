
output "public_subnet_ids" {
  value = aws_instance.bastion.public_ip
}


output "bastion_instance_id" {
  description = "ID of the Bastion host instance"
  value       = aws_instance.bastion.id

}



