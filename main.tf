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

module "bastion" {
  source = "./modules/bastion"
  # bastion_ami           = var.bastion_ami
  bastion_instance_type = var.bastion_instance_type
  public_subnet_id      = aws_subnet.public_subnets[0].id
  vpc_id                = aws_vpc.main.id
  key_name              = var.key_name
  allowed_ssh_cidrs     = var.allowed_ssh_cidrs
  tags                  = var.tags
  env                   = var.env
}



/*

data "aws_region" "current" {}








resource "aws_instance" "bastion_ec2" {
  count                       = length(var.public_subnet_cidrs)
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = "virg.keypair"
  vpc_security_group_ids      = [aws_security_group.simple-ec2_sg.id]
  subnet_id                   = aws_subnet.public_subnets[count.index].id
  depends_on                  = [aws_vpc.main]

  tags = {
    Name    = "${var.env}-bastion-${count.index + 1}"
    Owner   = "Ernestine D Motouom"
    Project = "refonte_class"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Allow ssh"
  vpc_id      = aws_vpc.main.id
  ingress {
    description      = "allow ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.public_subnet_cidrs //Must be edited to allow traffic from Myip via port 22
    ipv6_cidr_blocks = [var.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = [var.ipv6_cidr_block]
  }
  depends_on = [aws_vpc.main]

  tags = {
    Name    = "${var.env}-bastion_sg"
    Owner   = "Ernestine D Motouom"
    Project = "refonte_class"
  }
}

*/
