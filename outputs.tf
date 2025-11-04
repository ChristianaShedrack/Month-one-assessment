output "ssh_private_key_path" {
  description = "Path to the generated SSH private key"
  value       = local_file.private_key.filename
}

output "ssh_to_bastion_command" {
  description = "Command to SSH into bastion host"
  value       = "ssh -i ${local_file.private_key.filename} ec2-user@${aws_eip.bastion_eip.public_ip}"
}

output "ssh_to_web_server_1_via_bastion" {
  description = "Command to SSH into web server 1 via bastion"
  value       = "ssh -i ${local_file.private_key.filename} -J ec2-user@${aws_eip.bastion_eip.public_ip} ec2-user@${aws_instance.web_server_1.private_ip}"
}

output "ssh_to_web_server_2_via_bastion" {
  description = "Command to SSH into web server 2 via bastion"
  value       = "ssh -i ${local_file.private_key.filename} -J ec2-user@${aws_eip.bastion_eip.public_ip} ec2-user@${aws_instance.web_server_2.private_ip}"
}

output "ssh_to_db_server_via_bastion" {
  description = "Command to SSH into database server via bastion"
  value       = "ssh -i ${local_file.private_key.filename} -J ec2-user@${aws_eip.bastion_eip.public_ip} ec2-user@${aws_instance.db_server.private_ip}"
}