terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project = "EWB-VPC-Peering"
      Student = var.student_name
    }
  }
}

locals {
  common_tags = {
    Project = "EWB-VPC-Peering"
    Student = var.student_name
  }
}

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# ---------- VPC A ----------
resource "aws_vpc" "a" {
  cidr_block = "10.10.0.0/16"
  tags       = { Name = "ewb-vpc-a" }
}

resource "aws_subnet" "a_public" {
  vpc_id            = aws_vpc.a.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = var.az
  tags              = { Name = "ewb-a-public" }
}

resource "aws_subnet" "a_private" {
  vpc_id            = aws_vpc.a.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = var.az
  tags              = { Name = "ewb-a-private" }
}

resource "aws_internet_gateway" "a" {
  vpc_id = aws_vpc.a.id
  tags   = { Name = "ewb-igw-a" }
}

resource "aws_route_table" "a_public" {
  vpc_id = aws_vpc.a.id
  tags   = { Name = "ewb-rt-a-public" }
}

resource "aws_route" "a_public_internet" {
  route_table_id         = aws_route_table.a_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.a.id
}

resource "aws_route_table_association" "a_public" {
  subnet_id      = aws_subnet.a_public.id
  route_table_id = aws_route_table.a_public.id
}

resource "aws_route_table" "a_private" {
  vpc_id = aws_vpc.a.id
  tags   = { Name = "ewb-rt-a-private" }
}

resource "aws_route_table_association" "a_private" {
  subnet_id      = aws_subnet.a_private.id
  route_table_id = aws_route_table.a_private.id
}

# ---------- VPC B (no internet gateway) ----------
resource "aws_vpc" "b" {
  cidr_block = "10.20.0.0/16"
  tags       = { Name = "ewb-vpc-b" }
}

resource "aws_subnet" "b_private" {
  vpc_id            = aws_vpc.b.id
  cidr_block        = "10.20.1.0/24"
  availability_zone = var.az
  tags              = { Name = "ewb-b-private" }
}

resource "aws_route_table" "b_private" {
  vpc_id = aws_vpc.b.id
  tags   = { Name = "ewb-rt-b-private" }
}

resource "aws_route_table_association" "b_private" {
  subnet_id      = aws_subnet.b_private.id
  route_table_id = aws_route_table.b_private.id
}

# ---------- Security groups ----------
resource "aws_security_group" "bastion" {
  name        = "ewb-sg-bastion"
  description = "Bastion SSH from my IP"
  vpc_id      = aws_vpc.a.id
  tags        = { Name = "ewb-sg-bastion" }
}

resource "aws_security_group" "app_a" {
  name        = "ewb-sg-app-a"
  description = "App-A SSH from bastion, ICMP echo from App-B"
  vpc_id      = aws_vpc.a.id
  tags        = { Name = "ewb-sg-app-a" }
}

resource "aws_security_group" "app_b" {
  name        = "ewb-sg-app-b"
  description = "App-B SSH from bastion, ICMP echo from App-A"
  vpc_id      = aws_vpc.b.id
  tags        = { Name = "ewb-sg-app-b" }
}

resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.my_ip_cidr
}

resource "aws_vpc_security_group_ingress_rule" "app_a_ssh" {
  security_group_id = aws_security_group.app_a.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "10.10.1.10/32"
}

resource "aws_vpc_security_group_ingress_rule" "app_a_icmp" {
  security_group_id = aws_security_group.app_a.id
  ip_protocol       = "icmp"
  from_port         = 8 # ICMP type 8 = echo request
  to_port           = 0 # ICMP code 0
  cidr_ipv4         = "10.20.1.10/32"
}

resource "aws_vpc_security_group_ingress_rule" "app_b_ssh" {
  security_group_id = aws_security_group.app_b.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "10.10.1.10/32"
}

resource "aws_vpc_security_group_ingress_rule" "app_b_icmp" {
  security_group_id = aws_security_group.app_b.id
  ip_protocol       = "icmp"
  from_port         = 8
  to_port           = 0
  cidr_ipv4         = "10.10.2.10/32"
}

# Keep default allow-all outbound (Terraform removes it unless declared)
resource "aws_vpc_security_group_egress_rule" "bastion_all" {
  security_group_id = aws_security_group.bastion.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "app_a_all" {
  security_group_id = aws_security_group.app_a.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "app_b_all" {
  security_group_id = aws_security_group.app_b.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# ---------- Instances ----------
resource "aws_instance" "bastion" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.a_public.id
  private_ip                  = "10.10.1.10"
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true
  depends_on                  = [aws_internet_gateway.a]

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags        = { Name = "ewb-bastion" }
  volume_tags = merge(local.common_tags, { Name = "ewb-bastion-root" })
}

resource "aws_instance" "app_a" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.a_private.id
  private_ip                  = "10.10.2.10"
  vpc_security_group_ids      = [aws_security_group.app_a.id]
  associate_public_ip_address = false

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags        = { Name = "ewb-app-a" }
  volume_tags = merge(local.common_tags, { Name = "ewb-app-a-root" })
}

resource "aws_instance" "app_b" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.b_private.id
  private_ip                  = "10.20.1.10"
  vpc_security_group_ids      = [aws_security_group.app_b.id]
  associate_public_ip_address = false

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags        = { Name = "ewb-app-b" }
  volume_tags = merge(local.common_tags, { Name = "ewb-app-b-root" })
}

# ---------- Peering (switch on with enable_peering = true) ----------
resource "aws_vpc_peering_connection" "ab" {
  count       = var.enable_peering ? 1 : 0
  vpc_id      = aws_vpc.a.id
  peer_vpc_id = aws_vpc.b.id
  auto_accept = true # same account and Region
  tags        = { Name = "ewb-a-b-peer" }
}

resource "aws_route" "a_private_to_b" {
  count                     = var.enable_peering ? 1 : 0
  route_table_id            = aws_route_table.a_private.id
  destination_cidr_block    = "10.20.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.ab[0].id
}

resource "aws_route" "a_public_to_b" {
  count                     = var.enable_peering ? 1 : 0
  route_table_id            = aws_route_table.a_public.id
  destination_cidr_block    = "10.20.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.ab[0].id
}

resource "aws_route" "b_private_to_a" {
  count                     = var.enable_peering ? 1 : 0
  route_table_id            = aws_route_table.b_private.id
  destination_cidr_block    = "10.10.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.ab[0].id
}
