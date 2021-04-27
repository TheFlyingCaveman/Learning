locals {
  service_name    = "${var.app_name}-${var.environment}"
  hasLoadBalancer = var.lb_target_group_arn == null ? [] : [1]
}
