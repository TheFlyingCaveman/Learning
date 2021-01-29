# Groups
# SSMUserGroup-Liquibase 
# AmazonSSMFullAccess policy

locals {
  count_of_private_subnet = length(var.private_subnet)
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cdir_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "LiquibaseVpc"
    Environment = "PoC"
    Experiment  = "Liquibase"
  }
}

resource "aws_subnet" "private" {
  count      = local.count_of_private_subnet
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet[count.index].cidr_block

  availability_zone       = var.private_subnet[count.index].availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name        = "LiquibaseSubnet"
    Environment = "PoC"
    Experiment  = "Liquibase"
  }
}

# data "aws_internet_gateway" "default" {
#   filter {
#     name   = "attachment.vpc-id"
#     values = [aws_vpc.main.id]
#   }
# }

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "LiquibaseSubnet"
    Environment = "PoC"
    Experiment  = "Liquibase"
  }
}

resource "aws_route_table" "routetable" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0" #aws_subnet[count.index].cidr_block
    #gateway_id = data.aws_internet_gateway.default.id #"igw-0616922d194f51843" 
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name        = "LiquibaseRouteTable"
    Environment = "PoC"
    Experiment  = "Liquibase"
  }
}

resource "aws_default_route_table" "main" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  default_route_table_id = aws_vpc.main.default_route_table_id
}

# The subnet does not have any route able for external internet access,
# which is needed for SSM to work (unless a Private Connection is configured)
resource "aws_route_table_association" "a" {
  count          = local.count_of_private_subnet
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.routetable.id
}

resource "aws_security_group" "private" {
  name        = "LiquibasePrivate"
  description = "LiquibasePrivate"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = "3306"
    to_port     = "3306"
    protocol    = "tcp"
    description = "To allow for external things to connect and pass through to MYSQL"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    description = "To allow for external things to connect and pass through to MYSQL"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "LiquibaseSecurityGroup"
    Environment = "PoC"
    Experiment  = "Liquibase"
  }
}

resource "aws_iam_role" "ssm" {
  name        = "EC2-Liquibase-SSM-Experiment"
  path        = "/"
  description = "Allows EC2 instances to call AWS Systems Manager on your behalf."

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

  tags = {
    Name        = "LiquibaseDeployer"
    Environment = "PoC"
    Experiment  = "Liquibase"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "EC2-Liquibase-SSM-Experiment"
  role = aws_iam_role.ssm.name
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20210126.0-x86_64-gp2"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "liquibase" {
  # The route table must be added FIRST so that the SSM Agent can communicate with SSM
  # If this is done out of order, a reboot would be needed as the SSM Agent would
  # most likely have failed to communicate its status.
  depends_on                  = [aws_route_table_association.a]
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.ec2type
  subnet_id                   = aws_subnet.private[0].id
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ssm.name

  key_name = module.key_pair.this_key_pair_key_name

  user_data = file("start.sh")

  tags = {
    Name        = "LiquibaseDeployer"
    Environment = "PoC"
    Experiment  = "Liquibase"
  }

  vpc_security_group_ids = [
    aws_security_group.private.id
  ]
}
