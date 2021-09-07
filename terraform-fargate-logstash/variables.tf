# Input variable definitions

variable "vpc_id" {
  description = "vpc_id where we put fargate cluster"
  type        = string
  #default     = "vpc-02fda1ad9b61c51a2"  # security_test account
  default     = "vpc-0f9cf196d5cd2a4ba"   # security
}

variable "region" {
  description = "aws region"
  type        = string
  default     = "us-west-2"
}

variable "account" {
  description = "aws account number"
  type        = string
  #default     = "377028479240"    # security_test account
  default     = "281422882725"   # security account
}

variable "environment" {
  description = "environment"
  type        = string
  #default     = "test"       # security_test
  default     = "production"  # security
}

variable "public_subnets" {
  description = "Public subnets"
  type        = list(string)
  #default     = ["subnet-0c28e356543ecb34f", "subnet-0e079f901c4c4c8e2"]   # security_test
  default     = ["subnet-0449bc467616a3e30", "subnet-004251dbaa23acad5"]    # security
}

variable "private_subnets" {
  description = "Private subnets"
  type        = list(string)
  #default     = ["subnet-0ede8398cfefb8f26", "subnet-0257f223cec9f12d6"] # security_test
  default     = ["subnet-00b2c365157209181", "subnet-0597449e59c08c1ef"]  # security
}

variable "cortex_cidr" {
  description = "cortex dl cidr_block"
  type        = string
  default     = "34.67.106.64/28"
}

variable "ecs_cluster_name" {
  description = "The name of the cluster"
  type        = string
  default     = "logstash-cluster-terraform"
}

variable "ecs_svc_name" {
  description = "The name of the ecs service"
  type        = string
  default     = "svc-terraform"
}

variable "container_name" {
  description = "The name of the ecs container"
  type        = string
  default     = "logstash-container-terraform"  # ecs/cortex-logstash-container-terraform
}

variable "container_port" {
  description = "container tcp port"
  type        = string
  default     = "6514"
}

variable "lb_target_group_name" {
  description = "nlb target group name"
  type        = string
  default     = "nlb-tg-terraform"
}

variable "ecs_svc_sg_name" {
  description = "security group for ecs service"
  type        = string
  default     = "ecs-svc-sg-terraform"
}

#variable "nlb_logs_bucket_name" {
#  description = "bucket name for nlb log"
#  type        = string
#  default     = "nlb-log-terraform"
#}

variable "nlb_name" {
  description = "NLB name"
  type        = string
  default     = "nlb-terraform"
}

variable "ssl_cert_arn" {
  description = "ssl cert for the nlb"
  type        = string
  default     =  "arn:aws:acm:us-east-1:526262051452:certificate/57029a36-9c9d-4c38-b3ad-c020e8531471"

}

variable "ecr_repo_name" {
  description = "The name of the ecr repository name"
  type        = string
  default     = "syslog-logstash-terraform"
}

variable "docker_path" {
  description = "where the Dockerfile resides"
  type        = string
  default     = "/Users/khong/Documents/AWS/SYSLOG/logstash-cortex/src/main/docker"
}

variable "docker_tag" {
  description = "tag for the Docker image"
  type        = string
  default     = "1.0.5"
}

variable "task_definition" {
  description = "The name of the task definition"
  type        = string
  default     = "logstash-td-terraform"
}

variable "docker_td_image_name" {
  description = "The name of the docker image"
  type        = string
  default     = "syslog-logstash-terraform"
}

variable "task_role_name" {
  description = "The name of the task role"
  type        = string
  #default     = "ecsTaskRole"                  # security_task
  default     = "ecsTaskExecutionRole-cortex"   # security
}

variable "task_exec_role_name" {
  description = "The name of the task exec role"
  type        = string
  #default     = "ecsTaskExecutionRole2"        # security_task
  default     = "ecsTaskExecutionRole-cortex"   # security_task
}

variable "s3_upload_bucket_name" {
  description = "S3 bucket name for syslog upload"
  type        = string
  default     = "sec-prisma"   # security account
}

variable "s3_upload_bucket_prefix_folder" {
  description = "S3 prefix folder for syslog upload bucket"
  type        = string
  default     = "cortex"
}

variable "s3_size_file" {
  description = "S3 uploading file size in bytes"
  type        = string
  default     = "1747626"
}

variable "s3_time_file" {
  description = "S3 uploading time interval in minutes"
  type        = string
  default     = "5"
}








