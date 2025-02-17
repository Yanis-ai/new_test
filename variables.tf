# 定义敏感变量，用于存储数据库主密码
variable "benchmark_db_master_password" {
  description = "Master password for the benchmark RDS cluster"
  type        = string
  sensitive   = true
}

# 定义允许访问数据库的IP地址
variable "allowed_ip" {
  description = "Allowed IP address to access the database"
  type        = string
}