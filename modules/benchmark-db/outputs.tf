# 输出基准测试数据库集群的端点
output "benchmark_db_endpoint" {
  value = aws_rds_cluster.benchmark_aurora_postgresql_cluster.endpoint
}