# 创建用于基准测试的VPC
resource "aws_vpc" "benchmark_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name        = "BenchmarkVPC"
    Environment = "Benchmark"
  }
}

# 在基准测试VPC内创建子网A
resource "aws_subnet" "benchmark_subnet_a" {
  vpc_id            = aws_vpc.benchmark_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name        = "BenchmarkSubnetA"
    Environment = "Benchmark"
  }
}

# 在基准测试VPC内创建子网B
resource "aws_subnet" "benchmark_subnet_b" {
  vpc_id            = aws_vpc.benchmark_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1b"
  tags = {
    Name        = "BenchmarkSubnetB"
    Environment = "Benchmark"
  }
}

# 创建用于基准测试数据库的子网组
resource "aws_db_subnet_group" "benchmark_db_subnet_group" {
  name       = "benchmark-db-subnet-group"
  subnet_ids = [aws_subnet.benchmark_subnet_a.id, aws_subnet.benchmark_subnet_b.id]
  tags = {
    Name        = "BenchmarkDBSubnetGroup"
    Environment = "Benchmark"
  }
}

# 创建用于基准测试数据库的安全组
resource "aws_security_group" "benchmark_db_security_group" {
  vpc_id = aws_vpc.benchmark_vpc.id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${var.allowed_ip}/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "BenchmarkDBSecurityGroup"
    Environment = "Benchmark"
  }
}