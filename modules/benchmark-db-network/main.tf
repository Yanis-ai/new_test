# 创建用于基准测试的VPC
resource "aws_vpc" "benchmark_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name        = "BenchmarkVPC"
    Environment = "Benchmark"
  }
}

# 在基准测试VPC内创建子网A
resource "aws_subnet" "benchmark_subnet_a" {
  vpc_id            = aws_vpc.benchmark_vpc.id
  cidr_block        = var.subnet_a_cidr_block
  availability_zone = var.availability_zone_a
  tags = {
    Name        = "BenchmarkSubnetA"
    Environment = "Benchmark"
  }
}

# 在基准测试VPC内创建子网B
resource "aws_subnet" "benchmark_subnet_b" {
  vpc_id            = aws_vpc.benchmark_vpc.id
  cidr_block        = var.subnet_b_cidr_block
  availability_zone = var.availability_zone_b
  tags = {
    Name        = "BenchmarkSubnetB"
    Environment = "Benchmark"
  }
}

# 创建互联网网关
resource "aws_internet_gateway" "benchmark_igw" {
  vpc_id = aws_vpc.benchmark_vpc.id
  tags = {
    Name        = "BenchmarkIGW"
    Environment = "Benchmark"
  }
}

# 创建路由表
resource "aws_route_table" "benchmark_route_table" {
  vpc_id = aws_vpc.benchmark_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.benchmark_igw.id
  }
  tags = {
    Name        = "BenchmarkRouteTable"
    Environment = "Benchmark"
  }
}

# 将子网A关联到路由表
resource "aws_route_table_association" "benchmark_subnet_a_route_association" {
  subnet_id      = aws_subnet.benchmark_subnet_a.id
  route_table_id = aws_route_table.benchmark_route_table.id
}

# 将子网B关联到路由表
resource "aws_route_table_association" "benchmark_subnet_b_route_association" {
  subnet_id      = aws_subnet.benchmark_subnet_b.id
  route_table_id = aws_route_table.benchmark_route_table.id
}

# 创建用于基准测试数据库的子网组
resource "aws_db_subnet_group" "benchmark_db_subnet_group" {
  name       = var.db_subnet_group_name
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
    cidr_blocks = [for ip in var.allowed_ips : contains(ip, "/") ? ip : "${ip}/32"]
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