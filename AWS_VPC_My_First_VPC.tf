resource "aws_vpc" "bsvpc" {
   
  cidr_block = "10.10.0.0/16" #65536 hosts
  enable_dns_support = true
  enable_dns_hostnames= true
}
