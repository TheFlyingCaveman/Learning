resource "aws_codedeploy_app" "app" {
  compute_platform = "Server"
  name             = "TestingAwsCodeDeploy"
}

resource "aws_iam_role" "codedeploy_service_role" {
  name        = "Service-Role-CodeDeploy-EC2"
  path        = "/"
  description = "Allows CodeDeploy to call AWS services such as Auto Scaling on your behalf."

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codedeploy_codedeployrole" {
  role       = aws_iam_role.codedeploy_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_codedeploy_deployment_group" "group" {
  app_name               = aws_codedeploy_app.app.name
  deployment_group_name  = "TestingAgain"
  service_role_arn       = aws_iam_role.codedeploy_service_role.arn
  deployment_config_name = "CodeDeployDefault.HalfAtATime"

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  load_balancer_info {
    target_group_info {
      name = aws_lb_target_group.test.name
    }
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Environment"
      type  = "KEY_AND_VALUE"
      value = "Dev"
    }

    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "TestingCodeDeploy"
    }
  }

}

resource "aws_s3_bucket" "onebucket" {
  bucket = "testingcodedeploy1245"
  versioning {
    enabled = true
  }
  # TODO: Don't leave this in for production use cases
  force_destroy = true
  tags = {
    Name        = "CodeDeployBucket"
    Environment = "Test"
  }
  object_lock_configuration {
    object_lock_enabled = "Enabled"
    rule {
      default_retention {
        mode = "GOVERNANCE"
        days = 45
      }
    }
  }
}
