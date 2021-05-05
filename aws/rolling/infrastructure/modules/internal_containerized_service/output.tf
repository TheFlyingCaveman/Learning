output "ecs_security_group_ids" {
  value = local.distinct_security_group_ids

  depends_on = [
    aws_security_group.ecs_tasks
  ]
}