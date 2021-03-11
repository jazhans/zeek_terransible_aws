###########################################################
# Create a key pair for logging into EC2 in us-gov-west-1 #
###########################################################
resource "aws_key_pair" "ise-ky-zk" {
  provider   = aws.region-master
  key_name   = "${var.business-unit}-${var.env-loc}-ky-zk"
  public_key = file("~/.ssh/id_rsa.pub")
}
##########################################################
# Sensors tuneable to have multiple instances per subnet #
##########################################################
##################
# Sensor group A #
##################
resource "aws_instance" "ise-ec2-zk-sensor-a" {
  count                       = var.instances-per-subnet
  provider                    = aws.region-master
  ami                         = var.default-ami
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.ise-ky-zk.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ise-sg-zk.id]
  subnet_id                   = aws_subnet.ise-sn-zk[0].id
  tags = {
    Name = "${var.business-unit}-${var.env-loc}-ec2-sensor-zk-a-${count.index + 1}"
    business_unit = var.business-unit
    Environment   = var.env-loc
  }
}
resource "aws_ebs_volume" "ise-ebs-zk-a" {
  count             = var.instances-per-subnet
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.available.names, 0)
  type              = var.ebs-type
  iops              = var.iops-num
  size              = var.volume-space
  tags = {
    Name = "${var.business-unit}-${var.env-loc}-ebs-sensor-zk-a-${count.index + 1}"
    business_unit = var.business-unit
    Environment   = var.env-loc
  }
}
resource "aws_volume_attachment" "ise-ec2-ebs-att-zk-a" {
  count       = var.instances-per-subnet
  provider    = aws.region-master
  device_name = var.device-name
  volume_id   = aws_ebs_volume.ise-ebs-zk-a[count.index].id
  instance_id = aws_instance.ise-ec2-zk-sensor-a[count.index].id
}
##################
# Sensor group B #
##################
resource "aws_instance" "ise-ec2-zk-sensor-b" {
  count                       = var.instances-per-subnet
  provider                    = aws.region-master
  ami                         = var.default-ami
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.ise-ky-zk.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ise-sg-zk.id]
  subnet_id                   = aws_subnet.ise-sn-zk[1].id
  tags = {
    Name = "${var.business-unit}-${var.env-loc}-ec2-sensor-zk-b-${count.index + 1}"
    business_unit = var.business-unit
    Environment   = var.env-loc
  }
}
resource "aws_ebs_volume" "ise-ebs-zk-b" {
  count             = var.instances-per-subnet
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.available.names, 1)
  type              = var.ebs-type
  iops              = var.iops-num
  size              = var.volume-space
  tags = {
    Name = "${var.business-unit}-${var.env-loc}-ebs-sensor-zk-b-${count.index + 1}"
    business_unit = var.business-unit
    Environment   = var.env-loc
  }
}
resource "aws_volume_attachment" "ise-ec2-ebs-att-zk-b" {
  count       = var.instances-per-subnet
  provider    = aws.region-master
  device_name = var.device-name
  volume_id   = aws_ebs_volume.ise-ebs-zk-b[count.index].id
  instance_id = aws_instance.ise-ec2-zk-sensor-b[count.index].id
}
################## 
# Sensor group C #
##################
resource "aws_instance" "ise-ec2-zk-sensor-c" {
  count                       = var.instances-per-subnet
  provider                    = aws.region-master
  ami                         = var.default-ami
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.ise-ky-zk.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ise-sg-zk.id]
  subnet_id                   = aws_subnet.ise-sn-zk[2].id
  tags = {
    Name = "${var.business-unit}-${var.env-loc}-ec2-sensor-zk-c-${count.index + 1}"
    business_unit = var.business-unit
    Environment   = var.env-loc
  }
}
resource "aws_ebs_volume" "ise-ebs-zk-c" {
  count             = var.instances-per-subnet
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.available.names, 2)
  type              = var.ebs-type
  iops              = var.iops-num
  size              = var.volume-space
  tags = {
    Name = "${var.business-unit}-${var.env-loc}-ebs-sensor-zk-c-${count.index + 1}"
    business_unit = var.business-unit
    Environment   = var.env-loc
  }
}
resource "aws_volume_attachment" "ise-ec2-ebs-att-zk-c" {
  count       = var.instances-per-subnet
  provider    = aws.region-master
  device_name = var.device-name
  volume_id   = aws_ebs_volume.ise-ebs-zk-c[count.index].id
  instance_id = aws_instance.ise-ec2-zk-sensor-c[count.index].id
}
