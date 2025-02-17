variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where EC2 instances will be launched"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the security group"
  type        = string
}

variable "key_pair_name" {
  description = "Name of the key pair for EC2 instances"
  type        = string
}

variable "ec2_instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
}

variable "ec2_instance_type" {
  description = "Instance type for EC2 instances"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}