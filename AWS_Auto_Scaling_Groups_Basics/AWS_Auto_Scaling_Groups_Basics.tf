# Creating the autoscaling launch configuration that contains AWS EC2 instance details
resource "aws_launch_configuration" "aws_autoscale_conf" {
  name            = "web_config"
  image_id        = "ami-0f5e8a042c8bfcd5e"
  instance_type   = "t2.micro"
  security_groups = ["bswebsecuritygroup"]
  # Defining the Key that will be used to access the AWS EC2 instance
  # key_name = "automateinfra"
  user_data = <<EOF
    #!/bin/bash
    yum install -y httpd
systemctl start httpd
systemctl enable httpd

EOF
}


resource "aws_security_group" "bs_websg" {
  name = "bswebsecuritygroup"

  #Incoming traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #Open to anyone
  }


  #Outgoing traffic
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Creating the autoscaling group within us-east-1a availability zone
resource "aws_autoscaling_group" "mygroup" {
  # Defining the availability Zone in which AWS EC2 instance will be launched
  availability_zones = ["us-west-1b", "us-west-1c"]
  # Specifying the name of the autoscaling group
  name = "autoscalegroup"

  max_size = 2

  min_size = 0

  health_check_grace_period = 30

  health_check_type = "EC2"

  force_delete = true

  termination_policies = ["OldestInstance"]

  launch_configuration = aws_launch_configuration.aws_autoscale_conf.name

  desired_capacity = 1

}



# Creating the autoscaling policy of the autoscaling group
resource "aws_autoscaling_policy" "mygroup_policy" {
  name = "autoscalegroup_policy"
  # The number of instances by which to scale.
  scaling_adjustment = 2
  adjustment_type    = "ChangeInCapacity"
  # The amount of time (seconds) after a scaling completes and the next scaling starts.
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.mygroup.name
}
