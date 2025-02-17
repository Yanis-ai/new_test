# 创建用于基准测试的Aurora PostgreSQL数据库集群
resource "aws_rds_cluster" "benchmark_aurora_postgresql_cluster" {
  cluster_identifier = var.cluster_identifier
  engine             = var.engine
  engine_version     = var.engine_version
  database_name      = var.database_name
  master_username    = var.master_username
  master_password    = var.benchmark_db_master_password
  db_subnet_group_name = var.db_subnet_group_name
  vpc_security_group_ids = [var.security_group_id]
  tags = {
    Name        = "BenchmarkAuroraPostgreSQLCluster"
    Environment = "Benchmark"
  }
}

# 在基准测试数据库集群中创建实例
resource "aws_rds_cluster_instance" "benchmark_aurora_postgresql_instance" {
  count = var.instance_count
  identifier = var.instance_identifier
  cluster_identifier = aws_rds_cluster.benchmark_aurora_postgresql_cluster.id
  instance_class = var.instance_class
  engine = aws_rds_cluster.benchmark_aurora_postgresql_cluster.engine
  engine_version = aws_rds_cluster.benchmark_aurora_postgresql_cluster.engine_version
  db_subnet_group_name = var.db_subnet_group_name
  publicly_accessible = var.publicly_accessible
  tags = {
    Name        = "BenchmarkAuroraPostgreSQLInstance"
    Environment = "Benchmark"
  }
}