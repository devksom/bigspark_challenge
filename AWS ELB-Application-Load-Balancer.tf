# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}
#create VPC
resource "aws_vpc" "bs-alb-vpc" { 
 cidr_block = "10.0.0.0/16"
 tags = { 
         
          Name = "My Demo VPC"
        }
}

# Create Public Subnet1
resource "aws_subnet" "pub_sub1" {  
vpc_id                  = aws_vpc.bs-alb-vpc.id  
cidr_block              = "10.0.1.0/24" 
availability_zone       = "us-west-2c" 
map_public_ip_on_launch = true  
tags = {    
         
         Name = "public_subnet1"
      }
} 
# Create Public Subnet2
resource "aws_subnet" "pub_sub2" {  
vpc_id                  = aws_vpc.bs-alb-vpc.id  
cidr_block              = "10.0.4.0/24" 
availability_zone       = "us-west-2a" 
map_public_ip_on_launch = true  
tags = {    
          
         Name = "public_subnet1"
      }
} 
# Create Internet Gateway 
resource "aws_internet_gateway" "igw" {  
   vpc_id = aws_vpc.bs-alb-vpc.id   
   tags = {    
            
            Name = "internet gateway"
          }
}

# Create Private Subnet1
resource "aws_subnet" "prv_sub1" {
  vpc_id                  = aws_vpc.bs-alb-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = false
tags = {
    Project = "demo-assignment"
    Name = "private_subnet1" 
 }
}
# Create Private Subnet2
resource "aws_subnet" "prv_sub2" {
  vpc_id                  = aws_vpc.bs-alb-vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false
tags = {
    Project = "demo-assignment"
    Name = "private_subnet1" 
 }
}

# Create Public Route Table
resource "aws_route_table" "pub_sub1_rt" {
  vpc_id = aws_vpc.bs-alb-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
   }
    tags = {
    Project = "demo-assignment"
    Name = "public subnet route table" 
 }
}
# Create route table association of public subnet1
resource "aws_route_table_association" "internet_for_pub_sub1" {
  route_table_id = aws_route_table.pub_sub1_rt.id
  subnet_id      = aws_subnet.pub_sub1.id
}


# Create security group for load balancer
resource "aws_security_group" "elb_sg" {
  name        = "loadbalancer_sg"
  description = "Security Group for Load Balancer"
  vpc_id      = aws_vpc.bs-alb-vpc.id
ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }
egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

 tags = {
    Name = "ELB Security Group"
    
  } 
}
# Create security group for webserver
resource "aws_security_group" "webserver_sg" {
  name        = "webserver_security_grp"
  description = "Security Group for webserver"
  vpc_id      = aws_vpc.bs-alb-vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
   }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "webserver_sg"
    Project = "demo-assignment"
  }
}
# Create Auto Scaling Group
resource "aws_autoscaling_group" "Demo-ASG-tf" {
  name       = "Demo-ASG-tf"
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1
  force_delete       = true
  depends_on         = [aws_lb.ALB-tf]
  target_group_arns  =  ["${aws_lb_target_group.TG-tf.arn}"]
  health_check_type  = "EC2"
  launch_configuration = aws_launch_configuration.webserver_launch_config.name
  #vpc_zone_identifier = ["${aws_subnet.prv_sub1.id}","${aws_subnet.prv_sub2.id}"]
  vpc_zone_identifier = [aws_subnet.prv_sub1.id,aws_subnet.prv_sub2.id]
  
 tag {
       key                 = "Name"
       value               = "Demo-ASG-tf"
       propagate_at_launch = true
    }
}
# variable "server_port" {
#   description = "The port the server will use for HTTP requests"
#   type        = number
# }
resource "aws_launch_configuration" "webserver_launch_config" {
  image_id        = "ami-094125af156557ca2" #us-west2
  instance_type = "t2.micro"
  associate_public_ip_address = true
  security_groups = [aws_security_group.webserver_sg.id]

  user_data = <<EOF
  #!/bin/bash
  sudo yum update
  sudo yum install httpd -y
  sudo service httpd start
  echo “I made it! This is is awesome!” > /var/www/html/index.html
EOF

}

# resource "aws_launch_configuration" "webserver_launch_config" {
#   image_id        = "ami-094125af156557ca2"
#   instance_type   = "t2.micro"
#   security_groups = [aws_security_group.webserver_sg.id]

#   user_data = <<-EOF
#               #!/bin/bash
#               echo "Hello, World" > index.html
#               nohup busybox httpd -f -p ${var.server_port} &
#               EOF
# }
# Create Target group
resource "aws_lb_target_group" "TG-tf" {
  name     = "Demo-TargetGroup-tf"
  depends_on = [aws_vpc.bs-alb-vpc]
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.bs-alb-vpc.id
  health_check {
    interval            = 20
    path                = "/index.html"
    port                = 80
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             =10
    protocol            = "HTTP"
    matcher             = "200,202"
  }
}
# Create ALB
resource "aws_lb" "ALB-tf" {
   name              = "Demo-ALG-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups  = [aws_security_group.elb_sg.id]
  subnets          = [aws_subnet.pub_sub1.id,aws_subnet.pub_sub2.id]       
  tags = {
        name  = "Demo-AppLoadBalancer-tf"
        
       }
}
# Create ALB Listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.ALB-tf.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG-tf.arn
  }
 }
