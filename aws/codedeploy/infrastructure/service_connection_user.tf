resource "aws_iam_group" "codedeploygroup" {
  name = "Testing_CodeDeploy_Access"
  path = "/testing_codedeploy/"
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
  name = "AzureDevOps_Service_Connection"
  path = "/testing_codedeploy/"
  # TODO: do not leave this in for anything but PoC work!
  force_destroy = true
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