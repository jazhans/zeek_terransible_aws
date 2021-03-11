########
# DATA #
########
data "aws_availability_zones" "available" {}
#############
# RESOURCES #
#############
# Create VPC for Zeek in us-gov-west-1
resource "aws_vpc" "ise-vpc-zk" {
  provider             = aws.region-master
  cidr_block           = var.vpc-cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.business-unit}-${var.env-loc}-vpc-zk"
    business_unit = var.business-unit
    Environment   = var.env-loc
  }

}
# Iterate through subnets in each AZ based on subnet count
resource "aws_subnet" "ise-sn-zk" {
  count             = var.subnet-count
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  vpc_id            = aws_vpc.ise-vpc-zk.id
  cidr_block        = element(var.private-subnets, count.index)
  tags = {
    Name = "${var.business-unit}-${var.env-loc}-sn-zk-${count.index +1}"
    business_unit = var.business-unit
    Environment   = var.env-loc
  }
}
# Create IGW for Zeek in us-gov-west-1
resource "aws_internet_gateway" "ise-igw-zk" {
  provider = aws.region-master
  vpc_id   = aws_vpc.ise-vpc-zk.id
  tags = {
    Name          = "${var.business-unit}-${var.env-loc}-igw-zk"
    business_unit = var.business-unit
    Environment   = var.env-loc
  }
}
# Add IGW to RT
resource "aws_route_table" "internet_route" {
  provider = aws.region-master
  vpc_id   = aws_vpc.ise-vpc-zk.id
  route {
    cidr_block = var.external-ip
    gateway_id = aws_internet_gateway.ise-igw-zk.id
  }
  tags = {
    Name          = "${var.business-unit}-${var.env-loc}-rt-zk"
    business_unit = var.business-unit
    Environment   = var.env-loc
  }
}
# Overwrite default rt table of VPC
resource "aws_main_route_table_association" "set-master-default-rt-assoc" {
  provider       = aws.region-master
  vpc_id         = aws_vpc.ise-vpc-zk.id
  route_table_id = aws_route_table.internet_route.id
}
# Create Network Load Balancer for HA Zeek Cluster
resource "aws_lb" "ise-nlb-zk" {
  provider                         = aws.region-master
  name                             = "${var.business-unit}-${var.env-loc}-nlb-zk"
  internal                         = true
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  subnets                          = aws_subnet.ise-sn-zk.*.id
  tags = {
    Name          = "${var.business-unit}-${var.env-loc}-nlb-zk"
    business_unit = var.business-unit
    Environment   = var.env-loc
  }
}
# Create Target group
resource "aws_lb_target_group" "ise-tg-zk" {
  provider    = aws.region-master
  name        = "${var.business-unit}-${var.env-loc}-tg-zk"
  port        = var.vxlan-port
  target_type = "instance"
  vpc_id      = aws_vpc.ise-vpc-zk.id
  protocol    = "UDP"
  # health_check {
  #   enabled  = true
  #   interval = 10
  #   path     = "/"
  #   port     = var.health-port
  #   protocol = var.health-proto
  #   matcher  = "200-299"
  # }
  tags = {
    Name          = "${var.business-unit}-${var.env-loc}-tg-zk"
    business_unit = var.business-unit
    Environment   = var.env-loc
  }
}
# Create UDP listener on load balancer
resource "aws_lb_listener" "ise-vxlan-lst-zk" {
  provider          = aws.region-master
  load_balancer_arn = aws_lb.ise-nlb-zk.arn
  port              = var.vxlan-port
  protocol          = "UDP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ise-tg-zk.id
  }
}
# Attach ec2 instances to round robin lb logic
resource "aws_lb_target_group_attachment" "ise-zk-attach-sensors-a" {
  count            = var.instances-per-subnet
  provider         = aws.region-master
  target_group_arn = aws_lb_target_group.ise-tg-zk.arn
  target_id        = aws_instance.ise-ec2-zk-sensor-a[count.index].id
  port             = var.vxlan-port
}
resource "aws_lb_target_group_attachment" "ise-zk-attach-sensors-b" {
  count            = var.instances-per-subnet
  provider         = aws.region-master
  target_group_arn = aws_lb_target_group.ise-tg-zk.arn
  target_id        = aws_instance.ise-ec2-zk-sensor-b[count.index].id
  port             = var.vxlan-port
}
resource "aws_lb_target_group_attachment" "ise-zk-attach-sensors-c" {
  count            = var.instances-per-subnet
  provider         = aws.region-master
  target_group_arn = aws_lb_target_group.ise-tg-zk.arn
  target_id        = aws_instance.ise-ec2-zk-sensor-c[count.index].id
  port             = var.vxlan-port
}
