output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "ids" {
  value = {
    vpc_a      = aws_vpc.a.id
    vpc_b      = aws_vpc.b.id
    subnets    = [aws_subnet.a_public.id, aws_subnet.a_private.id, aws_subnet.b_private.id]
    igw        = aws_internet_gateway.a.id
    bastion    = aws_instance.bastion.id
    app_a      = aws_instance.app_a.id
    app_b      = aws_instance.app_b.id
    peering_id = var.enable_peering ? aws_vpc_peering_connection.ab[0].id : "not created yet"
  }
}
