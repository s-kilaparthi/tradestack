output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.tradestack_server.id
}

output "public_ip" {
  description = "Elastic IP address of the server"
  value       = aws_eip.tradestack_ip.public_ip
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.tradestack_sg.id
}
