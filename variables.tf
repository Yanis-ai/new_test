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
}以下是每个阶段的进一步详细拆分，细化到可执行的子任务层级，并确保总工时控制在200人日范围内（含缓冲）：

---

### **阶段1：现行环境调查与分析（15人日）**
| 编号 | 详细任务 | 交付物 | 工时 |
|------|----------|--------|-----|
| **1.1 资源清单导出** |
| 1.1.1 | 使用AWS CLI导出所有EC2/RDS/S3/SQS/Lambda/StepFunction资源列表 | `resources_raw.json` | 1 |
| 1.1.2 | 编写Python脚本过滤非必要资源（如默认VPC） | `filter_resources.py` | 1 |
| 1.1.3 | 生成分类资源清单（按服务、标签归类） | `resources_classified.xlsx` | 1 |
| **1.2 架构依赖分析** |
| 1.2.1 | 手动检查EC2→SQS→Lambda→StepFunction调用链 | `call_chain_diagram.drawio` | 2 |
| 1.2.2 | 使用AWS X-Ray分析服务间延迟与错误率 | `xray_report.pdf` | 2 |
| **1.3 共享服务识别** |
| 1.3.1 | 确认CloudTrail/Config是否为全局服务 | `shared_services.md` | 1 |
| 1.3.2 | 检查S3桶是否跨租户共享（桶策略分析） | `s3_bucket_policy_audit.csv` | 2 |
| **1.4 安全策略评估** |
| 1.4.1 | 导出所有IAM角色策略并标记高风险权限 | `iam_high_risk_roles.csv` | 3 |
| 1.4.2 | 验证WAF规则是否包含租户专属ACL | `waf_rules_audit.log` | 2 |

---

### **阶段2：多租户架构设计（25人日）**
| 编号 | 详细任务 | 交付物 | 工时 |
|------|----------|--------|-----|
| **2.1 租户隔离设计** |
| 2.1.1 | 定义VPC隔离方案（每个租户独立VPC+跨账号共享） | `vpc_per_tenant_design.md` | 3 |
| 2.1.2 | 设计资源标签策略（`tenant:company-a`, `env:prod`） | `tagging_policy.json` | 2 |
| 2.1.3 | 确定敏感数据加密方式（KMS多租户CMK） | `kms_key_design.md` | 1 |
| **2.2 网络架构细化** |
| 2.2.1 | 为每个租户规划CIDR范围（避免重叠） | `cidr_allocation_table.xlsx` | 2 |
| 2.2.2 | 设计共享服务的VPC端点（S3/Gateway） | `vpc_endpoints_design.drawio` | 2 |
| **2.3 Terraform策略** |
| 2.3.1 | 选择目录结构隔离环境（`envs/dev/`, `envs/prod/`） | `code_structure.md` | 2 |
| 2.3.2 | 设计变量注入方式（通过`tfvars` + 环境变量） | `variables_injection_flow.png` | 2 |
| **2.4 数据库隔离** |
| 2.4.1 | 对比RDS多实例 vs. Schema隔离的成本/性能 | `rds_isolation_analysis.xlsx` | 3 |
| 2.4.2 | 设计跨租户备份策略（S3按租户分目录） | `backup_policy.md` | 2 |

---

### **阶段3：Terraform模块开发（60人日）**
| 编号 | 详细任务 | 交付物 | 工时 |
|------|----------|--------|-----|
| **3.1 核心模块** |
| 3.1.1 | 开发VPC模块（含子网、路由表、NAT网关） | `modules/network/vpc` | 5 |
| 3.1.2 | 实现EC2自动伸缩组（基于租户标签选择AMI） | `modules/compute/asg` | 4 |
| 3.1.3 | 创建RDS模块（支持多租户分库分表） | `modules/database/rds` | 6 |
| **3.2 无状态服务** |
| 3.2.1 | 封装Lambda部署模块（含权限与VPC绑定） | `modules/serverless/lambda` | 3 |
| 3.2.2 | 设计StepFunction状态机模板（JSON/YAML） | `templates/stepfunction_def` | 4 |
| **3.3 多环境配置** |
| 3.3.1 | 生成基础环境变量文件（dev/staging/prod） | `envs/base.tfvars` | 2 |
| 3.3.2 | 实现租户专属覆盖配置（`company-a/dev.tfvars`） | `envs/tenants/` | 3 |
| **3.4 状态隔离** |
| 3.4.1 | 配置S3后端模板（按租户分Bucket+动态命名） | `backend_tenant.hcl` | 3 |
| 3.4.2 | 开发状态锁的DynamoDB表（租户级锁机制） | `modules/backend/dynamodb` | 2 |
| **3.5 自动化脚本** |
| 3.5.1 | 编写租户初始化脚本（生成TF变量+目录结构） | `scripts/init_tenant.sh` | 4 |
| 3.5.2 | 开发批量部署工具（并行部署多个租户） | `scripts/deploy_all_tenants.py` | 6 |

---

### **阶段4：CI/CD与测试（50人日）**
| 编号 | 详细任务 | 交付物 | 工时 |
|------|----------|--------|-----|
| **4.1 CI/CD流水线** |
| 4.1.1 | 配置GitHub Actions多租户部署流程（矩阵策略） | `.github/workflows/deploy.yml` | 5 |
| 4.1.2 | 实现Terraform Plan人工审批步骤 | `workflows/with_approval.yml` | 3 |
| **4.2 自动化测试** |
| 4.2.1 | 编写Terratest验证VPC网络隔离性 | `test/vpc_isolation_test.go` | 6 |
| 4.2.2 | 测试Lambda跨租户权限泄漏（模拟攻击） | `test/lambda_security_test.go` | 4 |
| **4.3 测试环境** |
| 4.3.1 | 部署模拟租户A/B/C环境（完整调用链） | `测试环境URL列表` | 5 |
| 4.3.2 | 注入模拟流量（使用AWS Device Farm） | `load_test_data.json` | 3 |
| **4.4 性能压测** |
| 4.4.1 | 针对ALB的每秒请求数测试（5000 RPS） | `alb_load_test_report.pdf` | 4 |
| 4.4.2 | 验证SQS消息堆积时的Lambda扩展能力 | `sqs_scaling_logs.log` | 3 |

---

### **阶段5：文档与交付（30人日）**
| 编号 | 详细任务 | 交付物 | 工时 |
|------|----------|--------|-----|
| **5.1 运维手册** |
| 5.1.1 | 编写租户故障转移步骤（RDS备份恢复） | `docs/disaster_recovery.md` | 4 |
| 5.1.2 | 记录监控指标阈值（CloudWatch报警规则） | `docs/monitoring_thresholds.csv` | 2 |
| **5.2 用户指南** |
| 5.2.1 | 制作租户控制台截图（AWS Console操作指引） | `docs/console_guide/` | 3 |
| 5.2.2 | 编写API调用示例（Postman集合） | `postman/tenant_api_collection.json` | 2 |
| **5.3 成本分摊** |
| 5.3.1 | 开发按租户过滤Cost Explorer的脚本 | `scripts/cost_by_tenant.py` | 4 |
| 5.3.2 | 设计成本报告模板（月度PDF/Excel） | `templates/cost_report.xlsx` | 3 |

---

### **阶段6：缓冲与风险管理（20人日）**
| 风险场景 | 应对措施 | 预留工时 |
|----------|----------|----------|
| **模块重构** | 如发现VPC模块需支持IPv6，重构并更新测试用例 | 8人日 |
| **测试延迟** | 增加性能压测迭代次数（额外2轮测试） | 6人日 |
| **安全漏洞** | 紧急修复IAM策略错误（如过度权限） | 6人日 |

---

### **执行节奏（按周拆分）**
```markdown
| 周   | 重点任务                                |
|------|---------------------------------------|
| 1-2  | 完成资源清单导出与架构依赖分析         |
| 3-4  | 确定VPC隔离方案与Terraform目录结构      |
| 5-8  | 开发核心模块（VPC/EC2/RDS）             |
| 9-10 | 实现CI/CD流水线与自动化测试框架         |
| 11-12| 部署测试环境并执行性能压测              |
| 13-14| 编写最终文档与客户培训                  |
| 15-16| 缓冲期（风险应对与验收优化）            |
```

### **关键检查点**
1. **里程碑1（第4周）**：完成架构设计评审，确认隔离方案与Terraform策略。
2. **里程碑2（第8周）**：核心模块通过基础测试（VPC创建、EC2部署）。
3. **里程碑3（第12周）**：测试环境通过安全审计与性能压测。
4. **里程碑4（第16周）**：客户签署验收报告并完成知识转移。

---

### **设计细节示例（Terraform多租户目录结构）**
```
environments/
├── tenants/
│   ├── company-a/
│   │   ├── dev/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── company-a-dev.tfvars
│   │   └── prod/
│   └── company-b/
└── modules/
    ├── network/
    ├── compute/
    └── serverless/
```

通过此拆分，团队可并行开发不同模块（如1人负责网络，1人负责无服务架构，0.5人协调测试），确保4个月内交付。

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
