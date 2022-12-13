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

#attach the created volume to the instance. Volume gets deleted on termination of instance
resource "aws_volume_attachment" "ebs-vol-attach" {
  device_name = "/dev/xvdh"
  volume_id   = aws_ebs_volume.bs-ebs-volume.id
  instance_id = aws_instance.bs-ebs-instance.id
}
