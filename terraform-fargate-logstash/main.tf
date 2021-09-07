# Terraform configuration
terraform {
  required_version = ">=1"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket = "terraform-states-526262051452"  
    key    = "bogo/syslog/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
}

locals {
  app = "bogo"
}

locals {
  nlb_interface_ids = flatten([data.aws_network_interfaces.ni.ids])
}


data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_subnet" "pub" {
  for_each = toset(var.public_subnets)
  id       = each.value
}

data "aws_subnet" "priv" {
  for_each = toset(var.private_subnets)
  id       = each.value
}

data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

#data "aws_iam_role" "task" {
#  name = var.task_role_name
#}
# ecs task role
resource "aws_iam_role" "ecs-task-role" {
  name = "${local.app}-ecs-task-role-terraform"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "s3" {
  name    = "${local.app}-ecs-task-s3-policy-terraform"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": ["${aws_s3_bucket.up.arn}"]
        },
        {
            "Effect": "Allow",
            "Action": "s3:*Object",
            "Resource": ["${aws_s3_bucket.up.arn}/*"]
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role       = aws_iam_role.ecs-task-role.name
  policy_arn = aws_iam_policy.s3.arn
}



#data "aws_iam_role" "task-exec" {
#  name = var.task_exec_role_name
#}

# ecs task <exec> role
resource "aws_iam_role" "ecs-task-execution-role" {
  name               = "${local.app}-ecs-task-exec-role-terraform"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "esc-task-execution-role-policy-attachment-default" {
  role       = aws_iam_role.ecs-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "esc-task-execution-role-policy-attachment-s3readonly" {
  role       = aws_iam_role.ecs-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# the following data blocks is to get eni info that is needed to get private ips of nlb
data "aws_network_interfaces" "ni" {
  filter {
    name = "description"
    values = ["ELB net/${local.app}-${var.nlb_name}/*"]
  }

  filter {
    name = "vpc-id"
    values = ["${var.vpc_id}"]
  }

  filter {
    name = "status"
    values = ["in-use"]
  }

  filter {
    name = "attachment.status"
    values = ["attached"]
  }

  depends_on = [
    aws_lb.nlb,
  ] 
}

data "aws_network_interface" "ifs" {
  #count = length(local.nlb_interface_ids)
  count = length(var.public_subnets)
  id = local.nlb_interface_ids[count.index]
}

data "aws_s3_bucket" "up" {
  bucket = var.s3_upload_bucket_name
}


resource "aws_ecr_repository" "r" {
  name                 = "${local.app}-${var.ecr_repo_name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "null_resource" "push" {
  provisioner "local-exec" {
     command     = "${coalesce("./push.sh", "${path.module}/push.sh")} ${var.docker_path} ${aws_ecr_repository.r.repository_url} ${var.docker_tag}"
     interpreter = ["bash", "-c"]

     # sample:
     /*
     ["bash" "-c" "./push.sh <docker_path> \
     377028479240.dkr.ecr.us-west-2.amazonaws.com/prisma-syslog-logstash-terraform 1.0.1"]
     */
  }
}

resource "aws_ecs_cluster" "c" {
  name = "${local.app}-${var.ecs_cluster_name}"

  tags = {
    Environment = var.environment
    Name = "${local.app}-${var.ecs_cluster_name}"
  }
}

resource "aws_ecs_service" "svc" {
  name                               = "${local.app}-${var.ecs_svc_name}"
  cluster                            = aws_ecs_cluster.c.id
  task_definition                    = aws_ecs_task_definition.td.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = [aws_security_group.svc-sg.id]
    subnets          = var.private_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
  tags = {
    Environment = var.environment
    Name = "${local.app}-${var.ecs_svc_name}"
  }
}

resource "aws_security_group" "svc-sg" {
  name   = var.ecs_svc_sg_name
  vpc_id  = data.aws_vpc.main.id
 
  ingress {
    protocol         = "tcp"
    from_port        = 6514
    to_port          = 6514
    cidr_blocks     = [var.cortex_cidr]
    description      = "cortex data lake"
  }

  # to test logstash from a local laptop
  ingress {
    protocol         = "tcp"
    from_port        = 6514
    to_port          = 6514
    cidr_blocks     = ["165.1.213.17/32"]
    description      = "testing from laptop"
  }

  # ingress from public subnets - disabled
  #ingress {
  #  protocol         = "tcp"
  #  from_port        = 6514
  #  to_port          = 6514
  #  cidr_blocks      = values(data.aws_subnet.pub).*.cidr_block
  #  description      = "public subnet"
  #}

  # private ips for nlb eni (we need this for health check)
  ingress {
    protocol         = "tcp"
    from_port        = 6514
    to_port          = 6514
    cidr_blocks = formatlist("%s/32",[for ifs in data.aws_network_interface.ifs : ifs.private_ip])
    description      = "priv nlb ip"
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "all outbound traffic"
  }

  tags = {
    Environment = var.environment
    Name = "${local.app}-${var.ecs_svc_sg_name}"
  }
}

resource "aws_cloudwatch_log_group" "yada" {
  name = "ecs/${local.app}-${var.container_name}"
  tags = {
    Application = var.container_name
  }
}

resource "aws_ecs_task_definition" "td" {
  family = "${local.app}-${var.task_definition}"

  #task_role_arn = data.aws_iam_role.task.arn
  #execution_role_arn  = data.aws_iam_role.task-exec.arn
  task_role_arn   = aws_iam_role.ecs-task-role.arn
  execution_role_arn  = aws_iam_role.ecs-task-execution-role.arn


  network_mode    = "awsvpc"
  requires_compatibilities    = ["FARGATE"]   # launch types
  cpu       = 1024
  memory    = 2048
  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = "${var.account}.dkr.ecr.${var.region}.amazonaws.com/${local.app}-${var.docker_td_image_name}:${var.docker_tag}"
      memory    = 1024
      essential = true
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = 6514
          hostPort      = 6514
        }
      ]

      # no permission for delete => do not create this log group resource
      # instead using an existing log group
      logConfiguration =  {
                logDriver =  "awslogs"
                options = {
                    awslogs-region = "${var.region}"
                    awslogs-group = "ecs/${local.app}-${var.container_name}" 
                    awslogs-stream-prefix =  "ecs"
                }   
      }

      environment = [
            {"name": "REGION", "value": "${var.region}"},
            {"name": "S3_UPLOAD_BUCKET_NAME", "value": "${var.s3_upload_bucket_name}"}, 
            {"name": "S3_UPLOAD_BUCKET_PREFIX_FOLDER", "value": "${var.s3_upload_bucket_prefix_folder}"},
            {"name": "S3_SIZE_FILE", "value": "${var.s3_size_file}"},
            {"name": "S3_TIME_FILE", "value": "${var.s3_time_file}"}
        ],
      
    }
  ])
  depends_on = [
    null_resource.push,
  ] 
  tags = {
    Environment = var.environment
    Name = "${local.app}-${var.task_definition}"
  }
}
#
resource "aws_s3_bucket" "nlb-logs" {
  bucket = "${var.nlb_logs_bucket_name}-${var.account}"
  acl    = "private"
  force_destroy = true  

  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_elb_service_account.main.arn}"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.nlb_logs_bucket_name}-${var.account}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.nlb_logs_bucket_name}-${var.account}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
          "Service": "delivery.logs.amazonaws.com"
      },
      "Action": [
          "s3:GetBucketAcl"
      ],
      "Resource": "arn:aws:s3:::${var.nlb_logs_bucket_name}-${var.account}"
    }
  ]
}
POLICY
}

# block all pub accessyes
resource "aws_s3_bucket_public_access_block" "pub-access" {
  bucket = aws_s3_bucket.nlb-logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_lb" "nlb" {
  name               = "${local.app}-${var.nlb_name}"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.public_subnets

  enable_deletion_protection = false

  #access_logs {
  #  bucket  = "${var.nlb_logs_bucket_name}-${var.account}"
  #  prefix  = ""
  #  enabled = false
  #}

  tags = {
    Environment = var.environment
    Name = "${local.app}-${var.nlb_name}"
  }

  #depends_on = [
  #  aws_s3_bucket.nlb-logs
  #] 
}

# ip target group for NLB
resource "aws_lb_target_group" "tg" {
  name        = var.lb_target_group_name
  port        = 6514
  protocol    = "TCP"
  vpc_id      = data.aws_vpc.main.id
  target_type = "ip"

  preserve_client_ip = true
 
  health_check {
    protocol  = "TCP"
  }

  lifecycle {
      create_before_destroy = true
  }
  
  tags = {
    Environment = var.environment
    Name = "${local.app}-${var.lb_target_group_name}"
  }
}

resource "aws_lb_listener" "nlb" {
  load_balancer_arn = aws_lb.nlb.id
  port              = 6514
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.ssl_cert_arn
 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.id
  }
}





