resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.env}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.env}-rds-subnet-group"
    Environment = var.env
  }
}

resource "aws_db_instance" "rds_instance" {
  identifier              = "${var.env}-mysql-db"
  engine                  = "mysql"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.storage_size
  storage_type            = "gp2"
  multi_az                = true
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = var.security_group_ids
  backup_retention_period = 7
  skip_final_snapshot     = true
  storage_encrypted       = true
  kms_key_id              = var.kms_key_id
  timeouts {
    create = "60m" # or longer if needed
    update = "60m"
  }

  tags = {
    Name        = "${var.env}-mysql"
    Environment = var.env
  }
}

