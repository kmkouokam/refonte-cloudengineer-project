resource "aws_db_subnet_group" "rds_subnet_group" {
  for_each    = var.rds_instances
  name        = "${each.key}-subnet-group"
  description = "RDS Subnet Group for ${each.key}"
  subnet_ids  = each.value.private_subnet_ids

  tags = {
    Name = "${each.key}-subnet-group"
  }
}

resource "aws_db_instance" "rds_instance" {
  for_each             = var.rds_instances
  identifier           = "${each.key}-mysql-db"
  engine               = "mysql"
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  allocated_storage    = var.storage_size
  storage_type         = "gp2"
  multi_az             = false
  db_name              = each.value.db_name
  username             = each.value.db_username
  password             = each.value.db_password
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group[each.key].name
  availability_zone    = each.value.az_name
  # availability_zone      = data.aws_availability_zones.available.names[each.value.az_index
  vpc_security_group_ids  = var.security_group_ids
  backup_retention_period = 7
  skip_final_snapshot     = true
  storage_encrypted       = true
  kms_key_id              = var.kms_key_id

  timeouts {
    create = "60m"
    update = "60m"
  }

  tags = {
    Name = "${each.key}-rds"
  }
}




















# resource "aws_db_instance" "rds_instance" {
#   # for_each                = toset(var.db_subnet_group_name)
#   identifier              = "${var.env}-mysql-db"
#   engine                  = "mysql"
#   engine_version          = var.engine_version
#   instance_class          = var.instance_class
#   allocated_storage       = var.storage_size
#   storage_type            = "gp2"
#   multi_az                = true
#   db_name                 = var.db_name
#   username                = var.db_username
#   password                = var.db_password
#   db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
#   vpc_security_group_ids  = var.security_group_ids
#   backup_retention_period = 7
#   skip_final_snapshot     = true
#   storage_encrypted       = true
#   kms_key_id              = var.kms_key_id
#   timeouts {
#     create = "60m" # or longer if needed
#     update = "60m"
#   }

#   tags = {
#     Name        = "${var.env}-mysql"
#     Environment = var.env
#   }
# }

