## List all Cost Management resources
#  - VPC
#  - Internet Gateway
#  - XX Public Subnets
#  - XX Private Subnets
#  - XX NAT Gateways in Public Subnets to give Internet access from Private Subnets
#  - XX EC2 Instances in Public Subnets
#
# Developed by Ernestine D Motouom
#----------------------------------------------------------




data "aws_availability_zones" "available" {}

#-------------VPC and Internet Gateway------------------------------------------
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags       = merge(var.tags, { Name = "${var.env}-vpc" })
}


resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "${var.env}-igw" })
}

#-------------Public Subnets and Routing----------------------------------------
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { Name = "${var.env}-public-${count.index + 1}" })
}


resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(var.tags, { Name = "${var.env}-route-public-subnets" })
}


resource "aws_route_table_association" "public_routes" {
  count          = length(aws_subnet.public_subnets[*].id)
  route_table_id = aws_route_table.public_subnets.id
  subnet_id      = aws_subnet.public_subnets[count.index].id
}


#-----NAT Gateways with Elastic IPs--------------------------
resource "aws_eip" "nat" {
  count  = length(var.private_subnet_cidrs)
  domain = "vpc"
  tags   = merge(var.tags, { Name = "${var.env}-nat-gw-${count.index + 1}" })
}


resource "aws_nat_gateway" "nat" {
  count         = length(var.private_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id
  tags          = merge(var.tags, { Name = "${var.env}-nat-gw-${count.index + 1}" })
}

#--------------Private Subnets and Routing-------------------------
resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags              = merge(var.tags, { Name = "${var.env}-private-${count.index + 1}" })
}


resource "aws_route_table" "private_subnets" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = merge(var.tags, { Name = "${var.env}-route-private-subnet-${count.index}" })
}


resource "aws_route_table_association" "private_routes" {
  count          = length(aws_subnet.private_subnets[*].id)
  route_table_id = aws_route_table.private_subnets[count.index].id
  subnet_id      = aws_subnet.private_subnets[count.index].id
}










## modeles/iam_roles/
module "iam_roles" {
  source = "./modules/iam_roles"
  env    = var.env
}

module "kms" {
  source = "./modules/kms"
  env    = var.env
}

module "secrets_manager" {
  source = "./modules/secrets_manager"

  secret_name = var.secret_name
  description = var.description
  kms_key_id  = module.kms.secrets_manager_kms_key_id
  env         = var.env

}




# RDS Security Group in root
resource "aws_security_group" "rds_sg" {
  name        = "${var.env}-rds-sg"
  description = "Allow MySQL traffic"
  vpc_id      = aws_vpc.main.id # VPC from your root-level VPC module

  ingress {
    description = "Allow MySQL from app or bastion"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs # Allow access from private subnets
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.env}-rds-sg"
    Environment = var.env
  }
}

# Call the RDS MySQL module
module "rds_mysql" {
  source         = "./modules/rds-mysql"
  env            = var.env
  db_name        = "accounts"
  db_username    = "admin"
  db_password    = module.secrets_manager.password
  instance_class = "db.t3.micro"
  engine_version = "8.0"
  storage_size   = 20
  multi_az       = true
  # db_subnet_group_name = "${var.env}-rds-subnet-group"

  private_subnet_ids = aws_subnet.private_subnets[*].id
  security_group_ids = [aws_security_group.rds_sg.id]
  kms_key_id         = module.kms.rds_kms_key_arn
  depends_on = [
    aws_security_group.rds_sg,
    module.secrets_manager,
    module.kms
  ]

}

##bastion security group
resource "aws_security_group" "bastion_sg" {
  name        = "${var.env}-bastion-sg"
  description = "Allow SSH access"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.env}-bastion-sg"
  })
}

module "bastion" {
  source                    = "./modules/bastion"
  bastion_instance_type     = var.bastion_instance_type
  public_subnet_ids         = aws_subnet.public_subnets[*].id
  key_name                  = var.key_name
  allowed_ssh_cidrs         = var.allowed_ssh_cidrs
  iam_instance_profile_name = module.iam_roles.ec2_instance_profile_name

  security_group_ids = [aws_security_group.bastion_sg.id]
  env                = var.env
  aws_region         = var.aws_region
  depends_on = [
    aws_subnet.public_subnets,
    aws_security_group.bastion_sg
  ]
  tags = merge(var.tags, {
    Name = "${var.env}-bastion"
  })
}

# ELB Security Group
resource "aws_security_group" "elb_sg" {
  name        = "${var.env}-elb-sg"
  description = "Allow inbound HTTP from the internet to ELB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-elb-sg"
  }
}

# NGINX EC2 Security Group
resource "aws_security_group" "nginx_sg" {
  name        = "${var.env}-nginx-sg"
  description = "Allow traffic from ELB to NGINX"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from ELB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.elb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-nginx-sg"
  }
}

module "nginx_frontend" {
  source                 = "./modules/nginx_frontend"
  env                    = var.env
  key_name               = var.key_name
  forntend_instance_type = var.forntend_instance_type

  iam_instance_profile_name = module.iam_roles.ec2_instance_profile_name
  public_subnet_ids         = aws_subnet.public_subnets[*].id

  elb_security_group_ids   = [aws_security_group.elb_sg.id]
  nginx_security_group_ids = [aws_security_group.nginx_sg.id]


  # desired_capacity = 2
  # min_size         = 1
  # max_size         = 3
}



