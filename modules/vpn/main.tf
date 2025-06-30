# modules/vpc_peering/main.tf

# Fetch ACM certificate for VPN (e.g., *.devopsguru.world)
data "aws_acm_certificate" "devopsguru_cert" {
  domain      = "*.devopsguru.world"
  statuses    = ["ISSUED"]
  most_recent = true
}


data "aws_subnet" "public" {
  for_each = toset(var.public_subnet_ids)
  id       = each.value
}

data "aws_subnet" "private" {
  for_each = toset(var.private_subnet_ids)
  id       = each.value
}



locals {
  unique_public_az_subnets = {
    for subnet_id, subnet in data.aws_subnet.public :
    subnet.availability_zone => subnet.id...
  }

  unique_private_az_subnets = {
    for subnet_id, subnet in data.aws_subnet.private :
    subnet.availability_zone => subnet.id...
  }

  # Only keep one subnet per AZ
  public_vpn_subnets  = { for az, ids in local.unique_public_az_subnets : az => ids[0] }
  private_vpn_subnets = { for az, ids in local.unique_private_az_subnets : az => ids[0] }
}






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
  for_each               = local.public_vpn_subnets
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint.id
  subnet_id              = each.value
}

# Attach VPN to private subnets
resource "aws_ec2_client_vpn_network_association" "private" {
  for_each               = local.private_vpn_subnets
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint.id
  subnet_id              = each.value
}


# Route VPN traffic to all subnets
resource "aws_ec2_client_vpn_route" "vpn_routes" {
  for_each               = toset(concat(var.public_subnet_ids, var.private_subnet_ids))
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint.id
  destination_cidr_block = "0.0.0.0/0"
  target_vpc_subnet_id   = each.value

  depends_on = [
    aws_ec2_client_vpn_network_association.public,
    aws_ec2_client_vpn_network_association.private
  ]
}

resource "aws_ec2_client_vpn_authorization_rule" "auth_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint.id
  target_network_cidr    = var.vpc_cidr_block
  authorize_all_groups   = true
}
