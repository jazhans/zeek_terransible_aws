################
# DEFAULT VARS #
################
provider "aws" {
  profile = "default"
  region  = "us-gov-west-1" # aws region here 
  alias   = "region-master"
}
variable "env-loc" {
  type    = string
  default = "dev" # stg / prd
}
variable "external-ip" {
  type    = string
  default = "0.0.0.0/0"
}
variable "business-unit" {
  type    = string
  default = "ise" # information security engineering
}
###################
# NETWORKING VARS #
###################
variable "subnet-count" {
  type     = number
  default  = 3
}
variable "vpc-cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "private-subnets" {
  type    = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"] # Mirror with subnet-count var
}
variable "health-proto" {
  type    = string
  default = "TCP"
}
variable "health-port" {
  type    = number
  default = 80 # pending on what can be used for health checks
}
variable "vxlan-port" {
  type    = number
  default = 4789
}
#######################
# SECURITY GROUP VARS #
#######################
variable "my-cidr-ssh-allow-in" {
  type    = list(string)
  default = ["199.68.205.0/24"] # your cidr here for ssh conns into sensor cluster
}
variable "vxlan-cidr-allow-in" {
  type    = list(string)
  default = ["0.0.0.0/0"] # allow vxlan inbound to nlb 
}
variable "cidr-allow-out" {
  type    = list(string)
  default = ["0.0.0.0/0"] # allow outbound 
}
############
# EC2 VARS #
############
variable "instances-per-subnet" {
  type    = number
  default = 1 # If changing, ensure outputs reflect this 
}
variable "volume-space" {
  type    = number
  default = 10 # tune for gig amount
}
variable "iops-num" {
  type    = number
  default = 150
}
variable "device-name" {
  type    = string
  default = "/dev/sdz" # ebs vol dev name here 
}
variable "ebs-type" {
  type    = string
  default = "io1" # rapid log writing ebs-type 
}
variable "instance-type" {
  type    = string
  default = "c5a.2xlarge" # instance type is tailored towards a 4 core cpu architecture for pinning zeek processes in node.cfg config 
}
variable "default-ami" {
  type    = string
  default = "ami-07c3ad15254f47892" # ami id for image leveraged 
}