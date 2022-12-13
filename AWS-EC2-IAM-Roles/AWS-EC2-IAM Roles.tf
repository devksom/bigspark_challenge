#create an iam role- for EC2 access
resource "aws_iam_role" "ec2_readonly_iam_access" {
  name = "ec2_readonly_iam_access"

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
      "Sid": ""
    }
  ]
}
EOF
}
#Create an IAM policy that allows read access (List and Get)
resource "aws_iam_policy" "ec2_readonly_iam_access" {
  name = "ec2_readonly_iam_access"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "iam:List*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "iam:Get*",
      "Resource": "*"
    }
  ]
}
EOF
}


#Attach role and policy to each other
resource "aws_iam_role_policy_attachment" "ec2_readonly_iam_access" {
  role       = aws_iam_role.ec2_readonly_iam_access.name
  policy_arn = aws_iam_policy.ec2_readonly_iam_access.arn
}

#create an instance profile to be attached to the EC2 instance
resource "aws_iam_instance_profile" "demo-instance" {
  name = "test_profile"
  role = aws_iam_role.ec2_readonly_iam_access.name
}

#Create EC2 instance and attach instance profile to it
resource "aws_instance" "example" {
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
