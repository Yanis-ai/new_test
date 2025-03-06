好的，下面我将提供完整的代码结构和每个文件的具体代码，基于您的需求：根据 S3 中压缩文件的数量来动态决定启动多少个 ECS 容器镜像进行解压处理。

---

## **📁 目录结构**

```
📂 terraform-unzip
├── 📂 lambda
│   ├── 📜 lambda_function.py           # 触发 AWS Batch 任务的 Lambda 函数
│   ├── 📜 calculate_time_lambda.py     # 计算解压总时间的 Lambda 函数
│   ├── 📜 requirements.txt             # Lambda 依赖包
│   ├── 📜 zip_lambda.sh                # 打包 Lambda 代码脚本
├── 📂 ecs-unzip
│   ├── 📜 Dockerfile                   # ECS 容器镜像的 Dockerfile
│   ├── 📜 unzip.py                     # 解压逻辑脚本
│   ├── 📜 requirements.txt             # ECS 依赖包
│   ├── 📜 entrypoint.sh                # ECS 任务启动脚本
├── 📂 terraform
│   ├── 📜 main.tf                      # Terraform 主配置文件
│   ├── 📜 variables.tf                 # 变量定义
│   ├── 📜 outputs.tf                   # 输出配置
│   ├── 📜 provider.tf                  # AWS Provider 配置
│   ├── 📜 iam.tf                       # IAM 角色与权限配置
│   ├── 📜 batch.tf                     # AWS Batch 任务配置
│   ├── 📜 s3.tf                        # S3 资源创建
```

---

## **📜 `terraform/main.tf`** (Terraform 主配置文件)

```hcl
provider "aws" {
  region = "us-east-1"
}

module "s3" {
  source = "./s3.tf"
}

module "iam" {
  source = "./iam.tf"
}

module "batch" {
  source     = "./batch.tf"
  ecs_role   = module.iam.ecs_task_role
  s3_bucket  = module.s3.s3_output_bucket
}
```

---

## **📜 `terraform/s3.tf`** (S3 资源)

```hcl
resource "aws_s3_bucket" "s3input" {
  bucket = "my-batch-input-bucket"
}

resource "aws_s3_bucket" "s3output" {
  bucket = "my-batch-output-bucket"
}
```

---

## **📜 `terraform/iam.tf`** (IAM 角色与权限)

```hcl
resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
```

---

## **📜 `terraform/batch.tf`** (AWS Batch 任务配置)

```hcl
resource "aws_batch_job_definition" "unzip_job" {
  name = "unzip-job"
  type = "container"

  container_properties = jsonencode({
    image = "ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/unzip-processor:latest"
    vcpus = 1
    memory = 512
    jobRoleArn = aws_iam_role.ecs_task_role.arn
    environment = [
      { name = "S3_INPUT_BUCKET", value = "my-batch-input-bucket" },
      { name = "S3_OUTPUT_BUCKET", value = "my-batch-output-bucket" },
      { name = "FILES_TO_PROCESS", value = "" }  # From Lambda dynamically injected
    ]
  })
}
```

---

## **📜 `ecs-unzip/Dockerfile`** (ECS 容器镜像 Dockerfile)

```dockerfile
FROM python:3.9

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY unzip.py .
COPY entrypoint.sh .

ENTRYPOINT ["/bin/bash", "entrypoint.sh"]
```

---

## **📜 `ecs-unzip/requirements.txt`** (ECS 依赖)

```
boto3
```

---

## **📜 `ecs-unzip/unzip.py`** (解压逻辑 Python 脚本)

```python
import os
import tarfile
import boto3

s3 = boto3.client("s3")
input_bucket = os.environ["S3_INPUT_BUCKET"]
output_bucket = os.environ["S3_OUTPUT_BUCKET"]

# 从环境变量获取要处理的文件
files_to_process = os.environ["FILES_TO_PROCESS"].split(",")

def extract_files():
    for file_key in files_to_process:
        # 下载文件到临时目录
        local_file = f"/tmp/{file_key.split('/')[-1]}"
        s3.download_file(input_bucket, file_key, local_file)

        # 解压文件
        with tarfile.open(local_file, "r:gz") as tar:
            tar.extractall("/tmp/extracted")

        # 上传解压后的文件到 S3
        for file_name in os.listdir("/tmp/extracted"):
            s3.upload_file(f"/tmp/extracted/{file_name}", output_bucket, file_name)

def main():
    extract_files()

if __name__ == "__main__":
    main()
```

---

## **📜 `ecs-unzip/entrypoint.sh`** (ECS 任务启动脚本)

```bash
#!/bin/bash

# 执行解压任务
python3 /app/unzip.py
```

---

## **📜 `lambda/lambda_function.py`** (触发 AWS Batch 任务的 Lambda 函数)

```python
import boto3
import json
import math

# S3 和 AWS Batch 客户端
s3 = boto3.client("s3")
batch = boto3.client("batch")

S3_BUCKET = "my-batch-input-bucket"
BATCH_JOB_QUEUE = "unzip-queue"
BATCH_JOB_DEFINITION = "unzip-job"

def lambda_handler(event, context):
    # 获取 S3 中所有 tar.gz 文件
    response = s3.list_objects_v2(Bucket=S3_BUCKET)
    files = [item["Key"] for item in response.get("Contents", []) if item["Key"].endswith(".tar.gz")]

    # 计算需要多少个任务，每个任务最多处理2个文件
    num_files = len(files)
    num_tasks = math.ceil(num_files / 2)

    # 提交多个 AWS Batch 任务
    job_ids = []
    for i in range(num_tasks):
        # 每个任务将处理两个文件，确保最多处理 2 个文件
        task_files = files[i * 2: (i + 1) * 2]
        
        # 提交 Batch 任务
        response = batch.submit_job(
            jobName=f"unzip-job-{i}",
            jobQueue=BATCH_JOB_QUEUE,
            jobDefinition=BATCH_JOB_DEFINITION,
            containerOverrides={
                "environment": [
                    {"name": "FILES_TO_PROCESS", "value": ",".join(task_files)},
                    {"name": "S3_INPUT_BUCKET", "value": S3_BUCKET},
                    {"name": "S3_OUTPUT_BUCKET", "value": "my-batch-output-bucket"}
                ]
            }
        )
        job_ids.append(response["jobId"])

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Batch jobs submitted successfully.",
            "job_ids": job_ids
        })
    }
```

---

## **📜 `lambda/calculate_time_lambda.py`** (计算解压总时间的 Lambda 函数)

```python
import boto3
import json
import time

s3 = boto3.client("s3")
S3_BUCKET = "my-batch-output-bucket"

def lambda_handler(event, context):
    # 获取开始时间
    start_obj = s3.get_object(Bucket=S3_BUCKET, Key="unzip_status/start_time.json")
    start_time = json.loads(start_obj["Body"].read().decode("utf-8"))["start_time"]

    # 获取所有任务结束时间
    response = s3.list_objects_v2(Bucket=S3_BUCKET, Prefix="unzip_status/")
    end_times = []
    
    for item in response.get("Contents", []):
        if "start_time.json" not in item["Key"]:
            obj = s3.get_object(Bucket=S3_BUCKET, Key=item["Key"])
            job_data = json.loads(obj["Body"].read().decode("utf-8"))
            end_times.append(job_data["end_time"])

    # 计算最长结束时间
    if end_times:
        total_time = max(end_times) - start_time
    else:
        total_time = None

    # 生成 CSV 结果
    csv_content = f"Start_Time,End_Time,Total_Time\n{start_time},{max(end_times)},{total_time}\n"
    s3.put_object(Bucket=S3_BUCKET, Key="unzip_results.csv", Body=csv_content)

    return {"start_time": start_time, "end_time": max(end_times), "total_time": total_time}
```

---

## **📜 `lambda/zip_lambda.sh`** (打包 Lambda 代码脚本)

```sh
cd lambda
zip -r lambda_function.zip lambda_function
