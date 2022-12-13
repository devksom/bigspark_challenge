resource "aws_vpc" "bsvpc" {

  cidr_block           = "10.0.0.0/16" #65536 hosts
  enable_dns_support   = true
  enable_dns_hostnames = true
}

data "aws_availability_zones" "available" {
  state = "available"
}
resource "aws_subnet" "Newsubnet1" {
  vpc_id            = aws_vpc.bsvpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

}
resource "aws_subnet" "Newsubnet2" {
  vpc_id            = aws_vpc.bsvpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]


}
resource "aws_subnet" "Newsubnet3" {
  vpc_id            = aws_vpc.bsvpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]


}
