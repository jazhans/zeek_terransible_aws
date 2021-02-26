#Create SG for allowing TCP/80 from my IP and TCP/22 from my IP
resource "aws_security_group" "ise-sg-zk" {
  provider    = aws.region-master
  name        = "${var.business-unit}-${var.env-loc}-sg-zk"
  description = "Security Group for Zeek Environment - Managed via Terraform"
  vpc_id      = aws_vpc.ise-vpc-zk.id
  tags = {
    Name          = "${var.business-unit}-${var.env-loc}-sg-zk"
    business_unit = var.business-unit
    Environment   = var.env-loc
  }
  ingress {
    description = "Allow 22 from our public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.my-cidr-ssh-allow-in
  }
  ingress {
    description = "Allow VXLAN Traffic"
    from_port   = var.vxlan-port
    to_port     = var.vxlan-port
    protocol    = "udp"
    cidr_blocks = var.vxlan-cidr-allow-in
  }
  # Allow intercommunication for nodes in subnet (crucial for mirrored traffic, could be port restricted)
  ingress {
    from_port   = var.health-port
    to_port     = var.health-port
    protocol    = var.health-proto
    cidr_blocks = [var.private-subnets[0]]
  }
  ingress {
    from_port   = var.health-port
    to_port     = var.health-port
    protocol    = var.health-proto
    cidr_blocks = [var.private-subnets[1]]
  }
  ingress {
    from_port   = var.health-port
    to_port     = var.health-port
    protocol    = var.health-proto
    cidr_blocks = [var.private-subnets[2]]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr-allow-out
  }
}
