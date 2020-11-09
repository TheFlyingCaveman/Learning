resource "aws_iam_group" "codedeploygroup" {
  name = var.codedeploy_user_iam_object.groupName
  path = var.codedeploy_user_iam_object.path
}

resource "aws_iam_group_policy_attachment" "codedeploygroup_ec2" {
  group      = aws_iam_group.codedeploygroup.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_policy_attachment" "codedeploygroup_s3" {
  group      = aws_iam_group.codedeploygroup.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_group_policy_attachment" "codedeploygroup_codedeploy" {
  group      = aws_iam_group.codedeploygroup.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
}

resource "aws_iam_user" "codedeploy" {
  name          = var.codedeploy_user_iam_object.userName
  path          = var.codedeploy_user_iam_object.path
  force_destroy = var.force_destroy_items
  tags = {
    usage = "Azure DevOps"
  }
}

resource "aws_iam_user_group_membership" "codedeploy" {
  user = aws_iam_user.codedeploy.name

  groups = [
    aws_iam_group.codedeploygroup.name
  ]
}
