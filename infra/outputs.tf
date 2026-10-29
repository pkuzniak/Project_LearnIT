output "instance_id" {
  description = "Application EC2 instance ID."
  value       = aws_instance.app.id
}

output "public_ip" {
  description = "Public IPv4 address of the application instance."
  value       = aws_instance.app.public_ip
}

output "application_url" {
  description = "Application URL, available after application deployment."
  value       = "http://${aws_instance.app.public_ip}:8000"
}

output "ssh_command" {
  description = "SSH command to connect from Dell."
  value       = "ssh -i ~/.ssh/id_ed25519 ubuntu@${aws_instance.app.public_ip}"
}
