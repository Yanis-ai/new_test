variable "benchmark_db_master_password" {
  description = "Master password for the benchmark RDS cluster"
  type        = string
  sensitive   = true
}

variable "cluster_identifier" {
  description = "Identifier for the Aurora PostgreSQL cluster"
  type        = string
}

variable "engine" {
  description = "Database engine type"
  type        = string
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
}

variable "database_name" {
  description = "Name of the database"
  type        = string
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group"
  type        = string
}

variable "instance_count" {
  description = "Number of RDS instances to create"
  type        = number
}

variable "instance_identifier" {
  description = "Identifier for the RDS instance"
  type        = string
}

variable "instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
}

variable "publicly_accessible" {
  description = "Whether the RDS instance is publicly accessible"
  type        = bool
}