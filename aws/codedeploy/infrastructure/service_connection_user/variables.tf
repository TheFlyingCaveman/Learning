variable "codedeploy_user_iam_object" {
  type = object({
    groupName : string
    userName : string
    path : string
  })
  description = "If set, it creates an IAM group and user to with permissions to use CodeDeploy. If you do not with to use this, also remove the service_connection_user.tf file."
  default     = null
}

variable "force_destroy_items" {
  type    = bool
  description = "Highly recommend to only set this to true for PoC work!"
  default = false
}
