data "aws_secretsmanager_secret" "db_secret" {
  name = var.aws_secretsmanager_secret_name
}

data "aws_secretsmanager_secret_version" "db_secret" {
  secret_id = data.aws_secretsmanager_secret.db_secret.id
}

locals {
  secret = var.secret_value
}


resource "aws_db_subnet_group" "mysql_subnet_group" {
  name       = "mysql-subnet-group-${lower(var.env)}"
  subnet_ids = var.private_subnet_ids
  tags       = merge(var.tags, { Name = "mysql-subnet-group-${lower(var.env)}" })
}

resource "aws_db_instance" "mysql" {
  identifier     = "${lower(var.env)}-mysql-db"
  engine         = "mysql"
  engine_version = var.engine_version
  instance_class = var.instance_class
  # secret_value           = jsonencode({
  #   db_username = local.secret.db_username
  #   db_password = local.secret.db_password
  # })
  db_name                 = "mydatabase"
  port                    = 3306
  allocated_storage       = var.allocated_storage
  max_allocated_storage   = var.max_allocated_storage
  storage_encrypted       = true
  kms_key_id              = null
  backup_retention_period = var.backup_retention
  backup_window           = "02:00-03:00"
  maintenance_window      = "Mon:03:00-Mon:04:00"
  multi_az                = true
  publicly_accessible     = false
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.mysql_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.mysql_sg.id, var.bastion_sg_id]

  tags = merge(var.tags, {
    Name = "${lower(var.env)}-mysql"
  })
}

resource "aws_security_group" "mysql_sg" {
  name        = "${lower(var.env)}-mysql-sg"
  description = "Allow MySQL access from app servers"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.bastion_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${lower(var.env)}-mysql-sg"
  })
}
