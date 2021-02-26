# Public Sensor IPs
output "Zeek-Sensor-Public-IPs-A" {
  value = aws_instance.ise-ec2-zk-sensor-a.*.public_ip
}
output "Zeek-Sensor-Public-IPs-B" {
  value = aws_instance.ise-ec2-zk-sensor-b.*.public_ip
}
output "Zeek-Sensor-Public-IPs-C" {
  value = aws_instance.ise-ec2-zk-sensor-c.*.public_ip
}
# Private Sensor IPs
output "Zeek-Sensor-Private-IPs-A" {
  value = aws_instance.ise-ec2-zk-sensor-a.*.private_ip
}
output "Zeek-Sensor-Private-IPs-B" {
  value = aws_instance.ise-ec2-zk-sensor-b.*.private_ip
}
output "Zeek-Sensor-Private-IPs-C" {
  value = aws_instance.ise-ec2-zk-sensor-c.*.private_ip
}
# Dynamic Ansible Inventory Creation
resource "local_file" "AnsibleInventory" {
  count   = var.instances-per-subnet  
  content = templatefile("inventory.tmpl",
    {
      sensor-a_ip1  = aws_instance.ise-ec2-zk-sensor-a[count.index].public_ip,
      sensor-b_ip1  = aws_instance.ise-ec2-zk-sensor-b[count.index].public_ip,
      sensor-c_ip1  = aws_instance.ise-ec2-zk-sensor-c[count.index].public_ip,
      #sensor-a_ip2  = aws_instance.ise-ec2-zk-sensor-c[count.index].public_ip,
      #sensor-b_ip2  = aws_instance.ise-ec2-zk-sensor-c[count.index].public_ip,
      #sensor-c_ip2  = aws_instance.ise-ec2-zk-sensor-c[count.index].public_ip,
    }
  )
  filename        = "../ansible/inventory.yml"
  file_permission = "0644"
}
# NLB IP Info
data "aws_network_interface" "ise-nlb-zk" {
  provider = aws.region-master
  count    = var.subnet-count
  filter {
    name   = "description"
    values = ["ELB ${aws_lb.ise-nlb-zk.arn_suffix}"]
  }
  filter {
    name   = "subnet-id"
    values = toset([aws_subnet.ise-sn-zk[count.index].id])
  }
}
# Dynamic Ansible Variables Creation
resource "local_file" "AnsibleVars" {
  content = templatefile("vars.tmpl",
    {
      nlb_priv_ip_a = data.aws_network_interface.ise-nlb-zk[0].private_ip
      nlb_priv_ip_b = data.aws_network_interface.ise-nlb-zk[1].private_ip
      nlb_priv_ip_c = data.aws_network_interface.ise-nlb-zk[2].private_ip
    }
  )
  filename        = "../ansible/zeek/vars/main.yml"
  file_permission = "0644"
}
# Zeek node.cfg creation for 3 sensors
resource "local_file" "zeekConfig1" {
  content = templatefile("node.cfg.tmpl",
    {
      sensor_priv_ip1  = aws_instance.ise-ec2-zk-sensor-a[0].private_ip,
      #sensor_priv_ip2 = aws_instance.ise-ec2-zk-sensor-a[1].private_ip,
    }
  )
  filename        = "../ansible/zeek/files/node1.cfg"
  file_permission = "0644"
}
resource "local_file" "zeekConfig2" {
  content = templatefile("node.cfg.tmpl",
    {
      sensor_priv_ip1 = aws_instance.ise-ec2-zk-sensor-b[0].private_ip,
      #sensor_priv_ip2 = aws_instance.ise-ec2-zk-sensor-b[1].private_ip,
    }
  )
  filename        = "../ansible/zeek/files/node2.cfg"
  file_permission = "0644"
}
resource "local_file" "zeekConfig3" {
  content = templatefile("node.cfg.tmpl",
    {
      sensor_priv_ip1 = aws_instance.ise-ec2-zk-sensor-c[0].private_ip,
      #sensor_priv_ip2 = aws_instance.ise-ec2-zk-sensor-c[1].private_ip,
    }
  )
  filename        = "../ansible/zeek/files/node3.cfg"
  file_permission = "0644"
}
