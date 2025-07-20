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

#-------------VPC and Internet Gateway in us-east-1-----------------------------------------
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



#-------------peer VPC and Internet Gateway in us-east-2-----------------------------------------
data "aws_availability_zones" "peer_azs" {
  provider = aws.us_east_2
  state    = "available"
}

resource "aws_vpc" "peer_vpc" {
  provider   = aws.us_east_2
  cidr_block = "10.1.0.0/16"

  tags = merge(var.tags, {
    Name = "${var.env}-peer-vpc-us-east-2"
  })
}


resource "aws_internet_gateway" "peer_igw" {
  provider   = aws.us_east_2
  vpc_id     = aws_vpc.peer_vpc.id
  tags       = merge(var.tags, { Name = "${var.env}-peer-igw-us-east-2" })
  depends_on = [aws_vpc.peer_vpc]
}

#-------------Public Subnets and Routing----------------------------------------
resource "aws_subnet" "peer_public_subnets" {
  provider                = aws.us_east_2
  count                   = length(var.peer_public_subnet_cidrs)
  vpc_id                  = aws_vpc.peer_vpc.id
  cidr_block              = element(var.peer_public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.peer_azs.names[count.index]
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { Name = "${var.env}-peer-public-${count.index + 1}" })
}


resource "aws_route_table" "peer_public_subnets" {
  count    = length(var.peer_public_subnet_cidrs)
  provider = aws.us_east_2
  vpc_id   = aws_vpc.peer_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.peer_igw.id
  }
  tags = merge(var.tags, { Name = "${var.env}-peer-route-public-subnets" })
}


resource "aws_route_table_association" "peer_public_routes" {
  provider       = aws.us_east_2
  count          = length(aws_subnet.peer_public_subnets[*].id)
  route_table_id = aws_route_table.peer_public_subnets[count.index].id
  subnet_id      = aws_subnet.peer_public_subnets[count.index].id
}


#-----NAT Gateways with Elastic IPs--------------------------
resource "aws_eip" "peer_nat" {
  provider = aws.us_east_2
  count    = length(var.peer_private_subnet_cidrs)
  domain   = "vpc"
  tags     = merge(var.tags, { Name = "${var.env}-peer-nat-gw-${count.index + 1}" })
}


resource "aws_nat_gateway" "peer_nat" {
  provider      = aws.us_east_2
  depends_on    = [aws_internet_gateway.peer_igw]
  count         = length(var.peer_private_subnet_cidrs)
  allocation_id = aws_eip.peer_nat[count.index].id
  subnet_id     = aws_subnet.peer_public_subnets[count.index].id
  tags          = merge(var.tags, { Name = "${var.env}-peer-nat-gw-${count.index + 1}" })
}

#--------------Private Subnets and Routing-------------------------
resource "aws_subnet" "peer_private_subnets" {
  provider          = aws.us_east_2
  depends_on        = [aws_vpc.peer_vpc, aws_internet_gateway.peer_igw]
  count             = length(var.peer_private_subnet_cidrs)
  vpc_id            = aws_vpc.peer_vpc.id
  cidr_block        = var.peer_private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.peer_azs.names[count.index]
  tags              = merge(var.tags, { Name = "${var.env}-peer-private-${count.index + 1}" })
}


resource "aws_route_table" "peer_private_subnets" {
  provider = aws.us_east_2
  count    = length(var.peer_private_subnet_cidrs)
  vpc_id   = aws_vpc.peer_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.peer_nat[count.index].id
  }
  tags = merge(var.tags, { Name = "${var.env}-peer.route-private-subnet-${count.index}" })
}


resource "aws_route_table_association" "peer_private_routes" {
  provider   = aws.us_east_2
  depends_on = [aws_vpc.peer_vpc, aws_internet_gateway.peer_igw]
  # Ensure the VPC and IGW are created before associating routes
  count          = length(aws_subnet.peer_private_subnets[*].id)
  route_table_id = aws_route_table.peer_private_subnets[count.index].id
  subnet_id      = aws_subnet.peer_private_subnets[count.index].id
}











## modeles/iam_roles/
module "iam_roles" {
  source = "./modules/iam_roles"


  env = var.env
}

module "kms" {
  source = "./modules/kms"
  env    = var.env
}

module "secrets_manager" {
  source = "./modules/secrets_manager"
  #
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
    cidr_blocks = ["0.0.0.0/0"] # Allow access from private subnets
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
#  This module creates an RDS MySQL instance with the specified parameters on multiple availability zones.
module "rds_mysql" {
  # for_each = data.aws_availability_zones.available
  source = "./modules/rds-mysql"
  env    = var.env

  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  storage_size            = 20
  kms_key_id              = module.kms.rds_kms_key_arn
  security_group_ids      = [aws_security_group.rds_sg.id, aws_security_group.jenkins_sg.id, aws_security_group.bastion_sg.id, aws_security_group.nginx_sg.id]
  rds_monitoring_role_arn = [module.iam_roles.rds_monitoring_role_arn]
  rds_instances = {
    "mysql-a" = {
      db_name            = "accounts"
      db_username        = "admin"
      db_password        = module.secrets_manager.password
      private_subnet_ids = aws_subnet.private_subnets[*].id

      az_name = data.aws_availability_zones.available.names[0]

    },
    "mysql-b" = {
      db_name            = "accounts"
      db_username        = "admin"
      db_password        = module.secrets_manager.password
      private_subnet_ids = aws_subnet.private_subnets[*].id
      az_name            = data.aws_availability_zones.available.names[1]
    }
  }

  depends_on = [
    aws_security_group.rds_sg,
    aws_security_group.bastion_sg,
    aws_security_group.nginx_sg,
    aws_security_group.jenkins_sg,
    aws_subnet.private_subnets,
    module.secrets_manager,
    module.kms,
    module.iam_roles
  ]
}







# Call the RDS MySQL module 1 az deployment
# module "rds_mysql" {
#   source         = "./modules/rds-mysql"
#   env            = var.env
#   db_name        = "accounts"
#   db_username    = "admin"
#   db_password    = module.secrets_manager.password
#   instance_class = "db.t3.micro"
#   engine_version = "8.0"
#   storage_size   = 20
#   multi_az       = true
#   # db_subnet_group_name = "${var.env}-rds-subnet-group"

#   private_subnet_ids = aws_subnet.private_subnets[*].id
#   security_group_ids = [aws_security_group.rds_sg.id,
#     aws_security_group.bastion_sg.id, # Allow access from bastion security group
#     aws_security_group.nginx_sg.id    # Allow access from nginx security group

#   ]
#   kms_key_id = module.kms.rds_kms_key_arn

#   rds_monitoring_role_arn = module.iam_roles.rds_monitoring_role_arn

#   depends_on = [
#     aws_security_group.rds_sg,
#     aws_subnet.private_subnets,
#     module.secrets_manager,
#     module.kms,
#     aws_security_group.bastion_sg,
#     aws_security_group.nginx_sg
#   ]

# }

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

# Call the Bastion module
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
    aws_security_group.bastion_sg,
    module.iam_roles,
    module.rds_mysql
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

# Call the NGINX Frontend module
module "nginx_frontend" {
  source                 = "./modules/nginx_frontend"
  env                    = var.env
  key_name               = var.key_name
  forntend_instance_type = var.forntend_instance_type

  iam_instance_profile_name  = module.iam_roles.ec2_instance_profile_name
  xray_instance_profile_name = module.iam_roles.xray_instance_profile_name
  public_subnet_ids          = aws_subnet.public_subnets[*].id

  elb_security_group_ids     = [aws_security_group.elb_sg.id]
  nginx_security_group_ids   = [aws_security_group.nginx_sg.id]
  vpc_id                     = aws_vpc.main.id
  cloudwatch_agent_role_name = module.iam_roles.cloudwatch_agent_role_name
  desired_capacity           = var.desired_capacity
  min_size                   = var.min_size
  max_size                   = var.max_size

  depends_on = [
    aws_security_group.elb_sg,
    aws_security_group.nginx_sg,
    aws_subnet.public_subnets,
    module.rds_mysql
  ]
}

# Call the S3 bucket module
module "s3_logs_bucket" {
  source      = "./modules/s3_logs"
  bucket_name = "refonte-jenkins-artifacts-2025${var.env}"
  tags        = var.tags
  env         = var.env
}


# Call the CloudTrail module
module "cloudtrail" {
  source         = "./modules/cloudtrail"
  env            = var.env
  s3_bucket_name = module.s3_logs_bucket.bucket_name
  tags           = var.tags

  depends_on = [module.s3_logs_bucket]
}


##SNS Topic for Alarms
resource "aws_sns_topic" "alerts" {
  name = "${var.env}-cloudwatch-alerts"
}

resource "aws_sns_topic_subscription" "sns_email" {
  for_each  = toset(var.notification_emails)
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = each.value

}

# #call cloudwatch module
module "cloudwatch" {
  source = "./modules/cloudwatch"
  env    = var.env

  aws_sns_topic_arn         = aws_sns_topic.alerts.arn
  iam_instance_profile_name = module.iam_roles.cloudwatch_agent_profile_name
  rds_instance_names        = module.rds_mysql.rds_instance_identifiers # Map of RDS instance names

  frontend_instance_name        = module.nginx_frontend.frontend_instance_name[*]
  cloudwatch_agent_role_name    = module.iam_roles.cloudwatch_agent_role_name
  cloudwatch_agent_profile_name = module.iam_roles.cloudwatch_agent_profile_name
  lambda_function_name          = module.lambda_cleanup.lambda_function_name

  aws_region = var.aws_region

  depends_on = [module.iam_roles]
}

module "waf" {
  source = "./modules/waf"

  waf_logging_role_arn  = module.iam_roles.waf_logging_role_arn
  waf_logging_group_arn = module.cloudwatch.waf_logging_group_arn
  nginx_alb_arn         = module.nginx_frontend.nginx_alb_arn

  env   = var.env
  scope = "REGIONAL"
  tags  = var.tags

  depends_on = [
    module.cloudwatch,
    module.iam_roles,
    module.nginx_frontend,
    aws_security_group.elb_sg,
  aws_security_group.nginx_sg]
}

# Call the Cost Optimization module
# This module sets up budget alerts and cost optimization strategies

# module "cost_optimization" {
#   source = "./modules/cost_optimization"

#   env = var.env

# }
#security group for VPN
resource "aws_security_group" "vpn_sg" {
  name        = "${var.env}-vpn-sg"
  description = "Allow VPN traffic"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = ["443", "80", "22"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-vpn-sg"
  }
}

module "vpn" {
  source                 = "./modules/vpn"
  vpc_id                 = aws_vpc.main.id
  public_subnet_ids      = var.public_subnet_ids
  private_subnet_ids     = var.private_subnet_ids
  vpc_cidr_block         = aws_vpc.main.cidr_block
  vpn_aws_security_group = aws_security_group.vpn_sg.id
  tags                   = var.tags
  env                    = var.env

  depends_on = [
    aws_vpc.main,
    aws_subnet.public_subnets,
    aws_subnet.private_subnets,
    module.iam_roles
  ]

}


## VPC Peering Module
# This module sets up VPC peering between the main VPC and a peer VPC
module "vpc_peering" {
  source = "./modules/vpc_peering"

  vpc_id                       = aws_vpc.main.id
  peer_aws_region              = var.peer_aws_region
  peer_vpc_id                  = aws_vpc.peer_vpc.id
  peer_vpc_cidr                = var.peer_vpc_cidr
  auto_accept                  = var.auto_accept
  public_route_table_ids       = var.public_route_table_ids
  private_route_table_ids      = var.private_route_table_ids
  peer_public_route_table_ids  = var.peer_public_route_table_ids
  peer_private_route_table_ids = var.peer_private_route_table_ids
  vpc_cidr                     = var.vpc_cidr
  env                          = var.env


  depends_on = [
    aws_vpc.peer_vpc,
    aws_vpc.main,
    aws_internet_gateway.peer_igw,
    aws_subnet.peer_public_subnets,
    aws_subnet.peer_private_subnets,
    aws_eip.peer_nat,
    aws_nat_gateway.peer_nat,
    aws_route_table.peer_public_subnets,
    aws_route_table.peer_private_subnets,
    aws_route_table.public_subnets,
    aws_route_table.private_subnets,
    aws_route_table.peer_public_subnets,
    aws_route_table.peer_private_subnets

  ]

}


module "lambda_cleanup" {
  source            = "./modules/lambda_cleanup"
  env               = var.env
  aws_sns_topic_arn = aws_sns_topic.alerts.arn



}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow HTTP for Jenkins UI"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # for testing only, restrict in prod
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Call the Jenkins module
# This module sets up Jenkins on EC2 instances in the specified public subnets

module "jenkins" {
  source             = "./modules/jenkins"
  env                = var.env
  instance_type      = var.jenkins_instance_type
  public_subnet_ids  = aws_subnet.public_subnets[*].id
  key_name           = var.key_name
  bucket_name        = var.bucket_name
  security_group_ids = [aws_security_group.jenkins_sg.id]

  # vpc_id = aws_vpc.main.id
  depends_on = [
    aws_security_group.jenkins_sg,
    aws_subnet.public_subnets,

    module.rds_mysql,
    module.s3_logs_bucket
  ]

}
