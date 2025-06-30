# modules/vpc_peering/main.tf

# Fetch ACM certificate for VPN (e.g., *.devopsguru.world)
data "aws_acm_certificate" "devopsguru_cert" {
  domain      = "*.devopsguru.world"
  statuses    = ["ISSUED"]
  most_recent = true
}


data "aws_vpc" "main" {
  # Assuming the VPC is already created and you have its ID
  id = var.vpc_id
}

data "aws_subnet" "public" {
  for_each = toset(var.public_subnet_ids)
  id       = each.value
}

data "aws_subnet" "private" {
  for_each = toset(var.private_subnet_ids)
  id       = each.value
}



# locals {
#   public_az_subnets = {
#     for id, subnet in data.aws_subnet.public :
#     subnet.availability_zone => subnet
#     if !contains(keys({ for az, _ in data.aws_subnet.public : az => true }), subnet.availability_zone)
#   }

#   private_az_subnets = {
#     for id, subnet in data.aws_subnet.private :
#     subnet.availability_zone => subnet
#     if !contains(keys({ for az, _ in data.aws_subnet.private : az => true }), subnet.availability_zone)
#   }
# }






# VPN resources
resource "aws_ec2_client_vpn_endpoint" "vpn_endpoint" {
  description            = "Example Client VPN endpoint"
  server_certificate_arn = data.aws_acm_certificate.devopsguru_cert.arn
  client_cidr_block      = "172.16.0.0/22"

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = data.aws_acm_certificate.devopsguru_cert.arn
  }

  connection_log_options {
    enabled = false
  }

  tags = var.tags
}

# Attach VPN to public subnets
resource "aws_ec2_client_vpn_network_association" "public" {
  for_each               = data.aws_subnet.public
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint.id
  subnet_id              = each.value.id
  depends_on             = [data.aws_vpc.main]
}

# Attach VPN to private subnets
resource "aws_ec2_client_vpn_network_association" "private" {
  for_each               = data.aws_subnet.private
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint.id
  subnet_id              = each.value.id
  depends_on             = [data.aws_vpc.main]
}


# Route VPN traffic to all subnets
resource "aws_ec2_client_vpn_route" "vpn_routes_public" {
  for_each               = data.aws_subnet.public
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint.id
  destination_cidr_block = "0.0.0.0/0"
  target_vpc_subnet_id   = each.key

  depends_on = [
    aws_ec2_client_vpn_network_association.public,
    data.aws_vpc.main

  ]
}

resource "aws_ec2_client_vpn_route" "vpn_routes_private" {
  for_each               = data.aws_subnet.private
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint.id
  destination_cidr_block = "0.0.0.0/0"
  target_vpc_subnet_id   = each.key

  depends_on = [
    data.aws_vpc.main,
    aws_ec2_client_vpn_network_association.private
  ]
}

resource "aws_ec2_client_vpn_authorization_rule" "auth_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint.id
  target_network_cidr    = var.vpc_cidr_block
  authorize_all_groups   = true
}
