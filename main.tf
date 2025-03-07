# 配置AWS提供者，指定区域
provider "aws" {
  region = "ap-northeast-1"
}

# 调用网络模块
module "benchmark_db_network" {
  source = "./modules/benchmark-db-network"
  vpc_cidr_block = var.vpc_cidr_block
  subnet_a_cidr_block = var.subnet_a_cidr_block
  subnet_b_cidr_block = var.subnet_b_cidr_block
  availability_zone_a = var.availability_zone_a
  availability_zone_b = var.availability_zone_b
  db_subnet_group_name = var.db_subnet_group_name
  allowed_ips = var.allowed_ips
}

# 调用基准测试数据库模块
module "benchmark_db" {
  source = "./modules/benchmark-db"
  benchmark_db_master_password = var.benchmark_db_master_password
  db_subnet_group_name = module.benchmark_db_network.db_subnet_group_name
  security_group_id = module.benchmark_db_network.security_group_id
  cluster_identifier = var.cluster_identifier
  engine = var.engine
  engine_version = var.engine_version
  database_name = var.database_name
  master_username = var.master_username
  instance_count = var.instance_count
  instance_identifier = var.instance_identifier
  instance_class = var.instance_class
  publicly_accessible = var.publicly_accessible
#   vpc_id = module.benchmark_db_networ
}

# 调用EC2模块
module "benchmark_ec2" {
  source = "./modules/benchmark-ec2"
  vpc_id = module.benchmark_db_network.vpc_id
  subnet_ids = [module.benchmark_db_network.subnet_a_id, module.benchmark_db_network.subnet_b_id]
  security_group_id = module.benchmark_db_network.security_group_id
  key_pair_name = var.key_pair_name
  ec2_instance_count = var.ec2_instance_count
  ec2_instance_type = var.ec2_instance_type
  ami_id = var.ami_id
}### **Terraform 构筑 AWS 多租户环境的测试文档设计**
本测试文档旨在确保 **Terraform 部署的 AWS 多租户架构** 在 **性能、可用性、扩展性、安全性、运维、缺陷修正** 等方面符合预期要求。以下是 **各测试类别的测试文档及测试项目详细设计**。

---

## **1. 测试文档列表**
| **测试分类** | **测试项目** | **测试文档名称（中文）** | **测试文档名称（日语）** | **文件名** |
|-------------|------------|----------------|-----------------|-------------|
| **性能测试** | 在线处理性能测试 | 系统基盘性能测试项书 | システム基盤テスト試験項目書 | `performance_test_cases.md` |
|  | 批处理性能测试 | 系统基盘性能测试项书 | システム基盤テスト試験項目書 | `performance_test_cases.md` |
|  | 数据库处理性能测试 | 系统基盘性能测试项书 | システム基盤テスト試験項目書 | `performance_test_cases.md` |
| **可用性测试** | Web 服务器故障恢复 | 系统基盘可用性测试项书 | システム基盤テスト試験項目書 | `availability_test_cases.md` |
|  | 数据库故障恢复 | 系统基盘可用性测试项书 | システム基盤テスト試験項目書 | `availability_test_cases.md` |
| **扩展性测试** | 微服务水平扩展（Scale-out） | 系统基盘扩展性测试项书 | システム基盤テスト試験項目書 | `scalability_test_cases.md` |
|  | 微服务缩容（Scale-in） | 系统基盘扩展性测试项书 | システム基盤テスト試験項目書 | `scalability_test_cases.md` |
|  | 数据库扩展（Scale-up） | 系统基盘扩展性测试项书 | システム基盤テスト試験項目書 | `scalability_test_cases.md` |
| **安全性测试** | 网络安全测试 | 系统基盘安全性测试项书 | システム基盤テスト試験項目書 | `security_test_cases.md` |
|  | 其他安全性测试 | 系统基盘安全性测试项书 | システム基盤テスト試験項目書 | `security_test_cases.md` |
| **运维测试** | 系统监控 | 系统基盘运维测试项书 | システム基盤テスト試験項目書 | `maintenance_test_cases.md` |
|  | 发布流程测试 | 系统基盘运维测试项书 | システム基盤テスト試験項目書 | `maintenance_test_cases.md` |
|  | 备份与恢复 | 系统基盘运维测试项书 | システム基盤テスト試験項目書 | `maintenance_test_cases.md` |
|  | 日志管理 | 系统基盘运维测试项书 | システム基盤テスト試験項目書 | `maintenance_test_cases.md` |
| **缺陷管理** | 缺陷修复验证 | 缺陷修复记录 | バグ票 | `bug_fix_report.md` |
|  | 复测 | 系统基盘复测项书 | システム基盤テスト試験項目書 | `retest_cases.md` |

---

## **2. 详细测试项目与测试观点数量**
每个测试文档包含多个 **测试项目**，每个测试项目包含 **多个测试观点（测试 Case）**。以下是详细设计：

### **1. 性能测试（150 Case）**
| **测试项目** | **测试观点数量** | **测试内容** |
|-------------|----------------|-------------|
| 在线处理性能测试 | 50 | - API Gateway 处理 TPS（每秒事务数） <br> - Lambda 并发执行限制 <br> - Terraform 资源部署时间评估 |
| 批处理性能测试 | 50 | - SQS 任务队列吞吐量 <br> - Step Functions 并发流程测试 <br> - AWS Batch 任务执行性能 |
| 数据库处理性能测试 | 50 | - RDS 并发查询性能 <br> - DynamoDB 读写吞吐能力 <br> - Aurora Auto Scaling 测试 |

---

### **2. 可用性测试（100 Case）**
| **测试项目** | **测试观点数量** | **测试内容** |
|-------------|----------------|-------------|
| Web 服务器故障恢复 | 50 | - ALB 负载均衡故障恢复 <br> - Route53 备份 DNS 解析测试 <br> - 自动扩展策略触发条件 |
| 数据库故障恢复 | 50 | - RDS 故障转移（Multi-AZ） <br> - Read Replica 负载均衡 <br> - Aurora Cluster 自动恢复 |

---

### **3. 扩展性测试（90 Case）**
| **测试项目** | **测试观点数量** | **测试内容** |
|-------------|----------------|-------------|
| 微服务水平扩展（Scale-out） | 30 | - ECS/EKS Pod 自动扩展测试 <br> - EC2 Auto Scaling 触发验证 |
| 微服务缩容（Scale-in） | 30 | - 无流量时 ECS/EKS 是否自动缩容 <br> - SQS 队列任务清空后的自动缩容 |
| 数据库扩展（Scale-up） | 30 | - RDS 规格变更测试 <br> - Aurora 读写实例自动扩展 |

---

### **4. 安全性测试（80 Case）**
| **测试项目** | **测试观点数量** | **测试内容** |
|-------------|----------------|-------------|
| 网络安全测试 | 40 | - AWS WAF 规则验证 <br> - VPC Security Group 访问限制 <br> - SSH 端口扫描防护 |
| 其他安全性测试 | 40 | - IAM 最小权限验证 <br> - API Gateway 鉴权测试 <br> - 数据加密（S3、RDS） |

---

### **5. 运维测试（80 Case）**
| **测试项目** | **测试观点数量** | **测试内容** |
|-------------|----------------|-------------|
| 系统监控 | 20 | - CloudWatch 监控规则 <br> - CloudTrail 日志采集 |
| 发布流程测试 | 20 | - CodePipeline 自动化部署 <br> - Blue/Green Deployment |
| 备份与恢复 | 20 | - S3 数据备份验证 <br> - RDS 备份恢复 |
| 日志管理 | 20 | - Lambda 执行日志 <br> - VPC Flow Logs 分析 |

---

### **6. 缺陷管理（50 Case）**
| **测试项目** | **测试观点数量** | **测试内容** |
|-------------|----------------|-------------|
| 缺陷修复验证 | 25 | - 记录修复的 Terraform 代码变更 <br> - 回归测试 |
| 复测 | 25 | - Bug 修复后进行二次验证 <br> - 确保所有模块可用 |

---

## **3. 总结**
| **测试类别** | **测试 Case 数量** |
|------------|---------------|
| 性能测试 | **150** |
| 可用性测试 | **100** |
| 扩展性测试 | **90** |
| 安全性测试 | **80** |
| 运维测试 | **80** |
| 缺陷管理 | **50** |
| **总计** | **550 Case** |

这些测试文档 **覆盖 Terraform 部署的 AWS 多租户架构的所有关键点**，确保架构具备 **高性能、高可用性、扩展性、安全性、稳定性**。
