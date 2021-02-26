# Resources ingesting mirrored Traffic
resource "aws_ec2_traffic_mirror_target" "zeek_target" {
  provider                  = aws.region-master
  description               = "VPC Tap for Zeek"
  network_load_balancer_arn = aws_lb.ise-nlb-zk.arn
  tags = {
    Name = "NLB Mirror Target for Zeek Cluster"
    business_unit = var.business-unit
    Environment   = var.env-loc
  }
}
resource "aws_ec2_traffic_mirror_filter" "zeek_filter" {
  provider    = aws.region-master
  description = "Zeek Mirror Filter - Allow All"
}
# THESE RULES WILL GRAB ALL INBOUND AND OUTBOUND TRAFFIC FOR MIRRORING OFF OF THE MIRRORED INSTANCES ENIS
# Filter rules, all common ports to and fro
resource "aws_ec2_traffic_mirror_filter_rule" "zeek_outbound" {
  provider                 = aws.region-master
  description              = "Zeek Outbound Rule"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.zeek_filter.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 1
  rule_action              = "accept"
  traffic_direction        = "egress"
}
resource "aws_ec2_traffic_mirror_filter_rule" "zeek_inbound" {
  provider                 = aws.region-master
  description              = "Zeek Inbound Rule"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.zeek_filter.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 1
  rule_action              = "accept"
  traffic_direction        = "ingress"
  # SHOWING FOR EXAMPLE OF HOW TO TUNE TRAFFIC FILTERS BY PROTOCOL AND PORT RANGES
  #protocol                 = -1
  # destination_port_range {
  #   from_port = 1
  #   to_port   = 65535
  # }
  # source_port_range {
  #   from_port = 1
  #   to_port   = 65535
  # }
}
# EXAMPLE OF ADDING TRAFFIC SOURCES AND MIRRORING SESSIONS
# command to verify VXLAN traffic is populating sudo tcpdump -i eth0 udp port 4789
# resource "aws_ec2_traffic_mirror_session" "zeek_session1" {
#   provider                 = aws.region-master
#   description              = "Zeek Mirror Session 1"
#   traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.zeek_filter.id
#   traffic_mirror_target_id = aws_ec2_traffic_mirror_target.zeek_target.id
#   network_interface_id     = aws_instance.# your ec2 traffic source instance name here #.primary_network_interface_id
#   session_number           = var.session-number
# }
# resource "aws_ec2_traffic_mirror_session" "zeek_session2" {
#   provider                 = aws.region-master
#   description              = "Zeek Mirror Session 2"
#   traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.zeek_filter.id
#   traffic_mirror_target_id = aws_ec2_traffic_mirror_target.zeek_target.id
#   network_interface_id     = aws_instance.# your ec2 traffic source instance name here # .primary_network_interface_id
#   session_number           = var.session-number + 1
# }