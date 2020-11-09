locals {
  count_of_public_subnets = length(var.public_subnets)
  count_of_instances      = var.count_of_ec2_instances_per_zone * local.count_of_public_subnets
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20200917.0-x86_64-gp2"]
  }

  owners = ["amazon"]
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cdir_block
  enable_dns_hostnames = true

  tags = {
    Name = "My VPC"
  }
}

resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "My VPC - Internet Gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_vpc_igw.id
  }

  tags = {
    Name = "Public Subnet Route Table."
  }
}

resource "aws_subnet" "public" {
  count      = local.count_of_public_subnets
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnets[count.index].cidr_block

  availability_zone       = var.public_subnets[count.index].availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_route_table_association" "public" {
  count          = local.count_of_public_subnets
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow All"
  vpc_id      = aws_vpc.main.id

  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0"
      ]
      description      = "Allow all. Use only for short lived testing!!"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow all testing CodeDeploy"
  }
}

resource "aws_iam_policy" "codedeploy_ec2_s3_policy" {
  name        = "CodeDeploy_EC2_S3_Policy"
  path        = "/"
  description = "CodeDeploy_EC2_S3_Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Action": [
            "s3:Get*",
            "s3:List*"
        ],
        "Effect": "Allow",
        "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "codedeploy_ec2_role" {
  name = "CodeDeploy-EC2-S3-Access"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codedeploy_attach" {
  role       = aws_iam_role.codedeploy_ec2_role.name
  policy_arn = aws_iam_policy.codedeploy_ec2_s3_policy.arn
}

resource "aws_iam_instance_profile" "codedeploy_profile" {
  name = "CodeDeploy-EC2-S3-Access"
  role = aws_iam_role.codedeploy_ec2_role.name
}

resource "aws_instance" "web" {
  count                       = local.count_of_instances
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public[(count.index % local.count_of_public_subnets)].id
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.codedeploy_profile.name

  key_name = module.key_pair.this_key_pair_key_name

  user_data = file("start.sh")

  tags = {
    Name        = "TestingCodeDeploy"
    Environment = "Dev"
  }

  vpc_security_group_ids = [
    aws_security_group.allow_all.id
  ]
}

resource "aws_lb" "main" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"

  // should have its own security group
  security_groups = [aws_security_group.allow_all.id]
  subnets         = aws_subnet.public.*.id
}

resource "aws_lb_target_group" "test" {
  name        = "tf-example-lb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    timeout  = 2
    interval = 5
  }
}

resource "aws_lb_target_group_attachment" "group" {
  count            = local.count_of_instances
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

resource "aws_lb_listener" "test" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}

module "pretty_domain" {
  count = var.pretty_domain == null ? 0 : 1
  source = "./pretty_domain"

  aws_route53_zone_name   = var.pretty_domain.aws_route53_zone_name
  aws_route53_record_name = var.pretty_domain.aws_route53_record_name
  lb = {
    dns_name = aws_lb.main.dns_name
    zone_id = aws_lb.main.zone_id
  }
}

module "service_connection_user" {
  count = var.codedeploy_user_iam_object == null ? 0 : 1
  source = "./service_connection_user"

  codedeploy_user_iam_object = {
    groupName : var.codedeploy_user_iam_object.groupName
    userName : var.codedeploy_user_iam_object.userName
    path : var.codedeploy_user_iam_object.path
  }

  force_destroy_items = var.force_destroy_items
}