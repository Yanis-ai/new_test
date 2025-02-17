# 定义敏感变量，用于存储数据库主密码
variable "benchmark_db_master_password" {
  description = "Master password for the benchmark RDS cluster"
  type        = string
  sensitive   = true
}

# 定义允许访问数据库的IP地址数组
variable "allowed_ips" {
  description = "List of allowed IP addresses to access the database"
  type        = list(string)
}

# VPC CIDR块
variable "vpc_cidr_block" {
  description = "CIDR block for the benchmark VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# 子网A的CIDR块
variable "subnet_a_cidr_block" {
  description = "CIDR block for subnet A"
  type        = string
  default     = "10.0.1.0/24"
}

# 子网B的CIDR块
variable "subnet_b_cidr_block" {
  description = "CIDR block for subnet B"
  type        = string
  default     = "10.0.2.0/24"
}

# 子网A的可用区
variable "availability_zone_a" {
  description = "Availability zone for subnet A"
  type        = string
  default     = "ap-northeast-1a"
}

# 子网B的可用区
variable "availability_zone_b" {
  description = "Availability zone for subnet B"
  type        = string
  default     = "ap-northeast-1b"
}

# 数据库子网组名称
variable "db_subnet_group_name" {
  description = "Name of the database subnet group"
  type        = string
  default     = "benchmark-db-subnet-group"
}

# 数据库集群标识符
variable "cluster_identifier" {
  description = "Identifier for the Aurora PostgreSQL cluster"
  type        = string
  default     = "benchmark-aurora-postgresql-cluster"
}

# 数据库引擎类型
variable "engine" {
  description = "Database engine type"
  type        = string
  default     = "aurora-postgresql"
}

# 数据库引擎版本
variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "10.14"
}

# 数据库名称
variable "database_name" {
  description = "Name of the database"
  type        = string
  default     = "benchmarkdb"
}

# 数据库主用户名
variable "master_username" {
  description = "Master username for the database"
  type        = string
  default     = "benchmark_master"
}

# RDS实例数量
variable "instance_count" {
  description = "Number of RDS instances to create"
  type        = number
  default     = 1
}

# RDS实例标识符
variable "instance_identifier" {
  description = "Identifier for the RDS instance"
  type        = string
  default     = "benchmark-aurora-postgresql-instance"
}

# RDS实例类型
variable "instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
  default     = "db.t3.medium"
}

# RDS实例是否公开可访问
variable "publicly_accessible" {
  description = "Whether the RDS instance is publicly accessible"
  type        = bool
  default     = false
}

# 密钥对名称
variable "key_pair_name" {
  description = "Name of the key pair for EC2 instances"
  type        = string
  default     = "benchmark-key-pair"
}

# EC2实例数量
variable "ec2_instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 2
}

# EC2实例类型
variable "ec2_instance_type" {
  description = "Instance type for EC2 instances"
  type        = string
  default     = "t2.micro"
}

# AMI ID，这里以亚马逊Linux 2为例，不同区域ID不同
variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0c94855ba95c71c99"
}