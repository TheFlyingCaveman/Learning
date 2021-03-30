resource "aws_security_group" "db" {
  name        = "allow_mysql"
  description = "Allow MySQL inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "MySQL from VPC"
    from_port   = "3306"
    to_port     = "3306"
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

locals {
  count_of_database_subnets = length(var.database_subnets)
}

resource "aws_subnet" "database" {
  count             = local.count_of_database_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnets[count.index].cidr_block
  availability_zone = var.database_subnets[count.index].availability_zone

  tags = {
    Name        = "LiquibaseSubnet"
    Environment = "PoC"
    Experiment  = "Liquibase"
  }
}

resource "aws_db_subnet_group" "db" {
  # name       = "LiquibaseSubnetGroup"
  subnet_ids = aws_subnet.database.*.id
  tags = {
    Name        = "LiquibaseSubnetGroup"
    Environment = "PoC"
    Experiment  = "Liquibase"
  }
}

resource "aws_db_instance" "db" {
  allocated_storage      = 5
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  name                   = "db1"
  username               = "user"
  password               = "hello_mysql"
  identifier             = "liquibasetests"
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.db.id

  tags = {
    Name        = "LiquibaseDatabase"
    Environment = "PoC"
    Experiment  = "Liquibase"
  }

  // TODO: WARNGING: DO NOT LEAVE THIS IN FOR PRODUCTION DATABASES!
  skip_final_snapshot = true
}

output "database_endpoint" {
  value = aws_db_instance.db.endpoint
}
