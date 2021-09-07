# Output variable definitions

output "vpc_id" {
  description = "The ID of the VPC"
  value       = data.aws_vpc.main.id
}

output "ecs_fargate_cluster_name" {
  description = "name of ecs fargate cluster"
  value       = aws_ecs_cluster.c.name
}

output "ecs_fargate_service_name" {
  description = "name of ecs fargate service"
  value       = aws_ecs_service.svc.name
}

output "ecs_fargate_task_definition_arn" {
  description = "name of ecs fargate task"
  value       = aws_ecs_task_definition.td.arn
}

output "ecs_fargate_task_definition_detail" {
  description = "name of ecs fargate task detail"
  value       = aws_ecs_task_definition.td.container_definitions
}

output "ecr_repository_name" {
  description = "name of ecr repository"
  value       = aws_ecr_repository.r.name
}

output "iam-role-task" {
  description = "ecs tsk role"
  value       = data.aws_iam_role.task.id
}

output "iam-role-exec-task" {
  description = "ecs exec tsk role"
  value       = data.aws_iam_role.task-exec.id
}

output "aws_lb_eni_priv_ips" {
  description = "private ips of nlb"
  value       = flatten([data.aws_network_interface.ifs.*.private_ips])
}

output "fargate_security_group_ingress" {
  description = "ecs fargate security group - ingress"
  value       = aws_security_group.svc-sg.*.ingress
}

output "nlb_dns" {
  description = "nlb dns"
  value       = aws_lb.nlb.dns_name
}


