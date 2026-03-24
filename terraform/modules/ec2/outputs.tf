output "instance_id" {
  description = "ID da instancia EC2"
  value       = aws_instance.app.id
}

output "instance_public_ip" {
  description = "IP publico da instancia"
  value       = aws_instance.app.public_ip
}

output "security_group_id" {
  description = "Security Group atachado"
  value       = aws_security_group.ec2_sg.id
}
