# 输出基准测试数据库集群的端点
output "benchmark_db_endpoint" {
  value = module.benchmark_db.benchmark_db_endpoint
}

# 输出EC2实例的公共IP地址
output "ec2_public_ips" {
  value = module.benchmark_ec2.ec2_public_ips
}

# 输出密钥对的名称
output "key_pair_name" {
  value = var.key_pair_name
}

# 输出私钥文件路径
output "private_key_file_path" {
  value = module.benchmark_ec2.private_key_file_path
}