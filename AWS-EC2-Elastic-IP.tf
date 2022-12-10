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
resource "aws_eip" "my_eip" {
  instance = aws_instance.web1.id
  vpc      = true
}
