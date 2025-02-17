variable "vpc_cidr_block" {
  description = "CIDR block for the benchmark VPC"
  type        = string
}

variable "subnet_a_cidr_block" {
  description = "CIDR block for subnet A"
  type        = string
}

variable "subnet_b_cidr_block" {
  description = "CIDR block for subnet B"
  type        = string
}

variable "availability_zone_a" {
  description = "Availability zone for subnet A"
  type        = string
}

variable "availability_zone_b" {
  description = "Availability zone for subnet B"
  type        = string
}

variable "db_subnet_group_name" {
  description = "Name of the database subnet group"
  type        = string
}

variable "allowed_ips" {
  description = "List of allowed IP addresses to access the database"
  type        = list(string)
}