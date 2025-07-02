## VPN Module

# Fetch ACM certificate for VPN (e.g., *.devopsguru.world)
data "aws_acm_certificate" "devopsguru_cert" {
  domain      = "*.devopsguru.world"
  statuses    = ["ISSUED"]
  most_recent = true
}

# data "aws_vpc" "main" {
#   id = var.vpc_id

# }

# Lookup existing subnets
data "aws_subnet" "public" {
  for_each = toset(var.public_subnet_ids)
  id       = each.value
}


data "aws_subnet" "private" {
  for_each = toset(var.private_subnet_ids)
  id       = each.value
}

# locals {
#   unique_public_subnets = {
#     for id, subnet in data.aws_subnet.public :
#     subnet.availability_zone => id... if !subnet.availability_zone in (keys({ for k, _ in data.aws_subnet.public : k => true }))
# }

#   unique_private_subnets = {
#     for id, subnet in data.aws_subnet.private :
#     subnet.availability_zone => id... if !subnet.availability_zone in (keys({ for k, _ in data.aws_subnet.private : k => true }))
#   }
# }

locals {
  unique_public_subnets = {
    for k, subnet in data.aws_subnet.public :
    subnet.availability_zone => subnet
    if !contains(keys({ for az, _ in data.aws_subnet.public : az => true }), subnet.availability_zone)
  }

  unique_private_subnets = {
    for k, subnet in data.aws_subnet.private :
    subnet.availability_zone => subnet
    if !contains(keys({ for az, _ in data.aws_subnet.private : az => true }), subnet.availability_zone)
  }
}







# VPN Endpoint
resource "aws_ec2_client_vpn_endpoint" "vpn_endpoint" {
  description            = "${var.env} Client VPN endpoint"
  server_certificate_arn = data.aws_acm_certificate.devopsguru_cert.arn
  client_cidr_block      = "172.16.0.0/22"

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = data.aws_acm_certificate.devopsguru_cert.arn
  }

  connection_log_options {
    enabled = false
  }
  vpc_id             = var.vpc_id
  security_group_ids = [var.vpn_aws_security_group]

  tags = merge(var.tags, { Name = "${var.env}-vpn-endpoint" })
}

# VPN Network Associations - one subnet per AZ
resource "aws_ec2_client_vpn_network_association" "public" {
  for_each = { for id in var.public_subnet_ids : id => id }

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint.id
  subnet_id              = each.value
}

resource "aws_ec2_client_vpn_network_association" "private" {
  for_each = local.unique_private_subnets

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint.id
  subnet_id              = each.value
}

# VPN Routes
resource "aws_ec2_client_vpn_route" "vpn_routes_public" {
  for_each = local.unique_public_subnets

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint.id
  destination_cidr_block = "0.0.0.0/0"
  target_vpc_subnet_id   = each.value

  depends_on = [aws_ec2_client_vpn_network_association.public]
}

resource "aws_ec2_client_vpn_route" "vpn_routes_private" {
  for_each = local.unique_private_subnets

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint.id
  destination_cidr_block = "0.0.0.0/0"
  target_vpc_subnet_id   = each.value

  depends_on = [aws_ec2_client_vpn_network_association.private]
}

# Authorization Rule
resource "aws_ec2_client_vpn_authorization_rule" "auth_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint.id
  target_network_cidr    = var.vpc_cidr_block
  authorize_all_groups   = true
}


