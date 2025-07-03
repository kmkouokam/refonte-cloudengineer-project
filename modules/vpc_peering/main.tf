# Requester's side of the connection.
resource "aws_vpc_peering_connection" "peer" {
  vpc_id      = var.vpc_id
  peer_vpc_id = var.peer_vpc_id
  peer_region = var.peer_aws_region
  auto_accept = var.auto_accept

  tags = {
    Side = "Requester"
  }
}

# # Accepter's side of the connection.
# resource "aws_vpc_peering_connection_accepter" "peer" {
#   #   peer_region               = var.peer_aws_region
#   vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
#   auto_accept               = true

#   tags = {
#     Side = "Accepter"
#   }
# }

# Requester side route additions (public + private)
resource "aws_route" "requester_public_routes" {
  for_each = toset(var.public_route_table_ids)

  route_table_id            = each.value
  destination_cidr_block    = var.peer_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "requester_private_routes" {
  for_each = toset(var.private_route_table_ids)

  route_table_id            = each.value
  destination_cidr_block    = var.peer_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

# Accepter side route additions (public + private)
resource "aws_route" "accepter_public_routes" {
  for_each = toset(var.peer_public_route_table_ids)

  route_table_id            = each.value
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "accepter_private_routes" {
  for_each = toset(var.peer_private_route_table_ids)

  route_table_id            = each.value
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}
