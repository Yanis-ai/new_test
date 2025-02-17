output "benchmark_db_subnet_group_name" {
  value = aws_db_subnet_group.benchmark_db_subnet_group.name
}

output "vpc_id" {
  value = aws_vpc.benchmark_vpc.id
}

output "security_group_id" {
  value = aws_security_group.benchmark_db_security_group.id
}