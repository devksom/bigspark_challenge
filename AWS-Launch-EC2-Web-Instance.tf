resource "aws_instance" "web1" {
  ami           = "ami-094125af156557ca2" #us-west2
  instance_type = "t2.micro"
  associate_public_ip_address = true
  security_groups = ["bswebsecuritygroup"]
  
  
    
  tags = {
    web = "web-1"
  }
  user_data = <<EOF
  #!/bin/bash
  sudo yum update
  sudo yum install httpd -y
  sudo service httpd start
  echo “I made it! This is is awesome!” > /var/www/html/index.html
EOF

}

resource "aws_security_group" "bs_websg" {
  name = "bswebsecuritygroup"

  #Incoming traffic
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #replace it with your ip address
  }
  

  #Outgoing traffic
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

