# 配置AWS提供者，指定区域
provider "aws" {
  region = "ap-northeast-1"
}

# 调用网络模块
module "benchmark_db_network" {
  source = "./modules/benchmark-db-network"
  allowed_ip = var.allowed_ip
}

