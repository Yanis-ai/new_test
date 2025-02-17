output "ec2_public_ips" {
  value = aws_instance.benchmark_ec2_instances.*.public_ip
}

output "private_key_file_path" {
  value = local_file.private_key.filename
}