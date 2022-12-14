#create VPC
resource "aws_vpc" "bs-alb-vpc" { 
 cidr_block = "10.0.0.0/16"
 tags = { 
         
          Name = "My Demo VPC"
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
  
    Name = "private_subnet1" 
 }
}

#Create Route Table for subnet 1
resource "aws_route_table" "prv_sub1_rt" {
  vpc_id = aws_vpc.bs-alb-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id

   }
    tags = {
  
    Name = "route table" 
 }
}
# Create route table association of private subnet1
resource "aws_route_table_association" "internet_for_prv_sub1" {
  route_table_id = aws_route_table.prv_sub1_rt.id
  subnet_id      = aws_subnet.prv_sub1.id
}

#Create Route Table for subnet 2
resource "aws_route_table" "prv_sub2_rt" {
  vpc_id = aws_vpc.bs-alb-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id

   }
    tags = {
  
    Name = "route table" 
 }
}
# Create route table association of private subnet2
resource "aws_route_table_association" "internet_for_prv_sub2" {
  route_table_id = aws_route_table.prv_sub2_rt.id
  subnet_id      = aws_subnet.prv_sub2.id
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
# # Create security group for webserver
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
  
  }
}

# Create Target group 1
resource "aws_lb_target_group" "TG-tf" {
  name     = "Demo-TargetGroup-tf1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.bs-alb-vpc.id
  health_check {
    interval            = 10
    path                = "/"
    port                = 80
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             =3
    protocol            = "HTTP"
    matcher             = "200,202"
  }
}

# Create Target group 2
resource "aws_lb_target_group" "TG-tf2" {
  name     = "Demo-TargetGroup-tf2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.bs-alb-vpc.id
  health_check {
    interval            = 10
    path                = "/test"
    port                = 80
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             =3
    protocol            = "HTTP"
    matcher             = "200,202"
  }
}
#Create target group attachment
resource "aws_lb_target_group_attachment" "attach-web1" {
  target_group_arn = aws_lb_target_group.TG-tf.arn
  target_id = aws_instance.web1.id
  port = 80
}
#Create target group attachment for web 2
resource "aws_lb_target_group_attachment" "attach-web2" {
  target_group_arn = aws_lb_target_group.TG-tf.arn
  target_id = aws_instance.web2.id
  port = 80
}
#Create target group 2 attachment for test 
resource "aws_lb_target_group_attachment" "attach-test" {
  target_group_arn = aws_lb_target_group.TG-tf2.arn
  target_id = aws_instance.test1.id
  port = 80
}
#create webserver for test
resource "aws_instance" "test1" {
  ami           = "ami-094125af156557ca2" #us-west2
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.prv_sub1.id
 security_groups = [aws_security_group.webserver_sg.id]
  
  tags = {
    web = "test1"
  }
  user_data = <<EOF
  #!/bin/bash
  sudo yum update
  sudo yum install httpd -y
  sudo service httpd start
  echo "Hey, it's only a test..." > /var/www/html/test.html
EOF

}
#create webserver 1
resource "aws_instance" "web1" {
  ami           = "ami-094125af156557ca2" #us-west2
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id =  aws_subnet.prv_sub2.id
 security_groups = [aws_security_group.webserver_sg.id]
  
  tags = {
    web = "web-1"
  }
  user_data = <<EOF
  #!/bin/bash
  sudo yum update
  sudo yum install httpd -y
  sudo service httpd start
  echo "Hey, it's a me, WEB 1!" > /var/www/html/index.html
EOF

}
#create webserver 2
resource "aws_instance" "web2" {
  ami           = "ami-094125af156557ca2" #us-west2
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id =  aws_subnet.prv_sub2.id
 security_groups = [aws_security_group.webserver_sg.id]
  
  tags = {
    web = "web-2"
  }
  user_data = <<EOF
  #!/bin/bash
  sudo yum update
  sudo yum install httpd -y
  sudo service httpd start
  echo "Hey, it's a me, WEB 2!" > /var/www/html/index.html
EOF

}
# Create ALB
resource "aws_lb" "ALB-tf" {
   name              = "Demo-ALB-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups  = [aws_security_group.elb_sg.id]
  subnets          = [aws_subnet.prv_sub1.id,aws_subnet.prv_sub2.id]   
  #  target_group_arns = [aws_lb_target_group.TG-tf2.arn,aws_lb_target_group.TG-tf.arn]
  tags = {
        name  = "Demo-AppLoadBalancer-tf"
        
       }
}


# # Create ALB Listeners
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.ALB-tf.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    forward {
       target_group{
         arn= aws_lb_target_group.TG-tf.arn
       }
       target_group{
         arn= aws_lb_target_group.TG-tf2.arn
       }
    }
   
  }
}
  
#  }
#  # # Create ALB Listener for test
# resource "aws_lb_listener" "front_end_test" {
#   load_balancer_arn = aws_lb.ALB-tf.arn
#   port              = "80"
#   protocol          = "HTTP"
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.TG-tf2.arn
#   }
#  }
