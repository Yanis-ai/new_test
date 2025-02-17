# 生成密钥对
resource "tls_private_key" "benchmark_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 将私钥保存到项目文件夹
resource "local_file" "private_key" {
  content  = tls_private_key.benchmark_key.private_key_pem
  filename = "${path.module}/private_key_${var.key_pair_name}.pem"
  file_permission = "0600"
}

# 在AWS上创建密钥对
resource "aws_key_pair" "benchmark_key_pair" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.benchmark_key.public_key_openssh
}

# 安装Docker和运行HammerDB的脚本
locals {
  install_hammerdb_script = <<EOT
#!/bin/bash
# 更新系统
apt-get update -y
# 安装必要的依赖
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
# 添加Docker的官方GPG密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
# 添加Docker的软件源
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# 更新软件包列表
apt-get update -y
# 安装Docker
apt-get install -y docker-ce docker-ce-cli containerd.io
# 拉取HammerDB镜像
docker pull tpcorg/hammerdb
# 运行HammerDB容器
docker run -d --name hammerdb tpcorg/hammerdb
EOT

  install_metabase_script = <<EOT
#!/bin/bash
# 更新系统
apt-get update -y
# 安装必要的依赖
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
# 添加Docker的官方GPG密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
# 添加Docker的软件源
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# 更新软件包列表
apt-get update -y
# 安装Docker
apt-get install -y docker-ce docker-ce-cli containerd.io
# 拉取Metabase镜像
docker pull metabase/metabase
# 运行Metabase容器，暴露3000端口
docker run -d -p 3000:3000 --name metabase metabase/metabase
EOT
}

# 创建两个EC2实例
resource "aws_instance" "benchmark_ec2_instances" {
  count         = 2
  ami           = var.ami_id
  instance_type = var.ec2_instance_type
  subnet_id     = element(var.subnet_ids, count.index % length(var.subnet_ids))
  vpc_security_group_ids = [var.security_group_id]
  key_name      = aws_key_pair.benchmark_key_pair.key_name
  associate_public_ip_address = true

  user_data = count.index == 0 ? local.install_hammerdb_script : local.install_metabase_script

  tags = {
    Name        = count.index == 0 ? "HammerDB-EC2-Instance" : "Metabase-EC2-Instance"
    Environment = "Benchmark"
  }
}