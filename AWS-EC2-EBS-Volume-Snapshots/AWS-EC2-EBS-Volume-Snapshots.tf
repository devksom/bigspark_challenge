# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

#extra ebs volume
resource "aws_ebs_volume" "bs-ebs-volume" {

  availability_zone = "us-west-2a"
  type              = "gp2"
  size              = 4
  tags = {
    Name = "Extra Volume"
  }
}

#Instance located in availability zone us-west-2a
resource "aws_instance" "bs-ebs-instance" {
  ami               = "ami-005e54dee72cc1d00"
  instance_type     = "t2.micro"
  availability_zone = "us-west-2a"

}

resource "aws_ebs_snapshot" "example_snapshot" {
 volume_id   = aws_ebs_volume.bs-ebs-volume.id
                                                                                                                                                                                                                                                                                                                      
  tags = {
    Name = "HelloWorld_snap"
  }
}
