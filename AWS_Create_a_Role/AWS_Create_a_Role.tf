resource "aws_iam_role" "ec2_full_iam_access" {
  name = "ec2_full_iam_access"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "RoleForEC2"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ec2_full_iam_access" {
  name = "ec2_full_iam_access"
  description = "Provides full access to resources in AWS account"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "iam:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_full_iam_access" {
  
  role       = aws_iam_role.ec2_full_iam_access.name
  policy_arn = aws_iam_policy.ec2_full_iam_access.arn
}

resource "aws_iam_instance_profile" "demo-instance" {
  name = "test_profile"
  role = aws_iam_role.ec2_full_iam_access.name
}

resource "aws_instance" "demo-instance" {
  ami           = "ami-094125af156557ca2" #us-west2
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.demo-instance.name
  key_name = "mytf"
  security_groups = [ aws_security_group.mysecgroup.name ]
}
resource "aws_security_group" "mysecgroup" {
  name = "mysecgroup"

 #Security group inbound rule that allow SSH traffic
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #Open to anyone
  }
  

  #Outgoing traffic
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
  output "public_ip" {
  value = aws_instance.demo-instance.public_ip
}
