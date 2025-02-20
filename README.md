variable "master_password" {
  description = "Master password for the RDS cluster"
  type        = string
  sensitive   = true
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MyVPC"
    Environment = "Development"
  }
}

resource "aws_subnet" "aws_subnet_a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "SubnetA"
    Environment = "Development"
  }
}

resource "aws_subnet" "aws_subnet_b" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1b"
  tags = {
    Name = "SubnetB"
    Environment = "Development"
  }
}

resource "aws_db_subnet_group" "aurrora_subnet_group" {
  name       = "aurrora-subnet-group"
  subnet_ids = [aws_subnet.aws_subnet_a.id, aws_subnet.aws_subnet_b.id]
  tags = {
    Name = "AuroraSubnetGroup"
    Environment = "Development"
  }
}

resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 替换为允许的IP地址
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "AuroraSecurityGroup"
    Environment = "Development"
  }
}

resource "aws_rds_cluster" "aurora_postgresql" {
  cluster_identifier = "aurora-postgresql-cluster"
  engine             = "aurora-postgresql"
  engine_version     = "10.14"
  database_name      = "mydb"
  master_username    = "master"
  master_password    = var.master_password
  db_subnet_group_name = aws_db_subnet_group.aurrora_subnet_group.name
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  tags = {
    Name = "AuroraPostgreSQLCluster"
    Environment = "Development"
  }
}

resource "aws_rds_cluster_instance" "aurora_postgresql_instance" {
  count = 1
  identifier = "aurora-postgresql-instance"
  cluster_identifier = aws_rds_cluster.aurora_postgresql.id
  instance_class = "db.t3.medium"
  engine = aws_rds_cluster.aurora_postgresql.engine
  engine_version = aws_rds_cluster.aurora_postgresql.engine_version
  db_subnet_group_name = aws_db_subnet_group.aurrora_subnet_group.name
  publicly_accessible = false
  tags = {
    Name = "AuroraPostgreSQLInstance"
    Environment = "Development"
  }
}

output "endpoint" {
  value = aws_rds_cluster.aurora_postgresql.endpoint
}variable "master_password" {
  description = "Master password for the RDS cluster"
  type        = string
  sensitive   = true
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MyVPC"
    Environment = "Development"
  }
}

resource "aws_subnet" "aws_subnet_a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "SubnetA"
    Environment = "Development"
  }
}

resource "aws_subnet" "aws_subnet_b" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1b"
  tags = {
    Name = "SubnetB"
    Environment = "Development"
  }
}

resource "aws_db_subnet_group" "aurrora_subnet_group" {
  name       = "aurrora-subnet-group"
  subnet_ids = [aws_subnet.aws_subnet_a.id, aws_subnet.aws_subnet_b.id]
  tags = {
    Name = "AuroraSubnetGroup"
    Environment = "Development"
  }
}

resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 替换为允许的IP地址
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "AuroraSecurityGroup"
    Environment = "Development"
  }
}

resource "aws_rds_cluster" "aurora_postgresql" {
  cluster_identifier = "aurora-postgresql-cluster"
  engine             = "aurora-postgresql"
  engine_version     = "10.14"
  database_name      = "mydb"
  master_username    = "master"
  master_password    = var.master_password
  db_subnet_group_name = aws_db_subnet_group.aurrora_subnet_group.name
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  tags = {
    Name = "AuroraPostgreSQLCluster"
    Environment = "Development"
  }
}

resource "aws_rds_cluster_instance" "aurora_postgresql_instance" {
  count = 1
  identifier = "aurora-postgresql-instance"
  cluster_identifier = aws_rds_cluster.aurora_postgresql.id
  instance_class = "db.t3.medium"
  engine = aws_rds_cluster.aurora_postgresql.engine
  engine_version = aws_rds_cluster.aurora_postgresql.engine_version
  db_subnet_group_name = aws_db_subnet_group.aurrora_subnet_group.name
  publicly_accessible = false
  tags = {
    Name = "AuroraPostgreSQLInstance"
    Environment = "Development"
  }
}

output "endpoint" {
  value = aws_rds_cluster.aurora_postgresql.endpoint
}









provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "aws_subnet_a" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
}

resource "aws_subnet" "aws_subnet_b" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-1b"
}

resource "aws_db_subnet_group" "aurrora_subnet_group" {
  name = "aurrora-subnet-group"
  subnet_ids = [aws_subnet.aws_subnet_a.id, aws_subnet.aws_subnet_b.id]
}

resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.my_vpc.id
  ingress = {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress = {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_rds_cluster" "auraro_postgresql" {
  cluster_identifier = "aurora-postgresql-cluster"
  engine = "aurora-postgresql"
  engine_version = "10.14"
  database_name = "mydb"
  master_username = "master"
  master_password = "password"
  db_subnet_group_name = aws_db_subnet_group.aurrora_subnet_group.name
  vpc_security_group_ids = [aws_security_group.my_sg.id]
}

resource "aws_rds_cluster_instance" "aurora_postgresql_instance" {
  count = 1
  identifier = "aurora-postgresql-instance"
  cluster_identifier = aws_rds_cluster.auraro_postgresql.id
  instance_class = "db.t3.medium"
  engine = aws_rds_cluster.auraro_postgresql.engine
  engine_version = aws_rds_cluster.auraro_postgresql.engine_version
  db_subnet_group_name = aws_db_subnet_group.aurrora_subnet_group.name
  publicly_accessible = false
}

output "endpoint" {
  value = aws_rds_cluster.auraro_postgresql.endpoint
}










