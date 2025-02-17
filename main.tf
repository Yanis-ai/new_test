# 配置AWS提供者，指定区域
provider "aws" {
  region = "ap-northeast-1"
}

# 调用网络模块
module "benchmark_db_network" {
  source = "./modules/benchmark-db-network"
  vpc_cidr_block = var.vpc_cidr_block
  subnet_a_cidr_block = var.subnet_a_cidr_block
  subnet_b_cidr_block = var.subnet_b_cidr_block
  availability_zone_a = var.availability_zone_a
  availability_zone_b = var.availability_zone_b
  db_subnet_group_name = var.db_subnet_group_name
  allowed_ips = var.allowed_ips
}

# 调用基准测试数据库模块
module "benchmark_db" {
  source = "./modules/benchmark-db"
  benchmark_db_master_password = var.benchmark_db_master_password
  db_subnet_group_name = module.benchmark_db_network.db_subnet_group_name
  security_group_id = module.benchmark_db_network.security_group_id
  cluster_identifier = var.cluster_identifier
  engine = var.engine
  engine_version = var.engine_version
  database_name = var.database_name
  master_username = var.master_username
  instance_count = var.instance_count
  instance_identifier = var.instance_identifier
  instance_class = var.instance_class
  publicly_accessible = var.publicly_accessible
#   vpc_id = module.benchmark_db_networ
}

# 调用EC2模块
module "benchmark_ec2" {
  source = "./modules/benchmark-ec2"
  vpc_id = module.benchmark_db_network.vpc_id
  subnet_ids = [module.benchmark_db_network.subnet_a_id, module.benchmark_db_network.subnet_b_id]
  security_group_id = module.benchmark_db_network.security_group_id
  key_pair_name = var.key_pair_name
  ec2_instance_count = var.ec2_instance_count
  ec2_instance_type = var.ec2_instance_type
  ami_id = var.ami_id
}