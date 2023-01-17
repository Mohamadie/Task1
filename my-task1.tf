provider "aws" {
  region = "us-east-1"
}
resource "aws_key_pair" "bastion-key" {
  key_name   = "bastion-key"
  public_key = file("~/.ssh/id_rsa.pub")

}
resource "aws_vpc" "VPC_Task1" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Project     = "VPC_Task"
    Environment = "Test"
    Team        = "DevOps"
    Created_by  = "Amina"
    Name        = "VPC_Task1"
  }
}
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.VPC_Task1.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Project     = "VPC_Task"
    Environment = "Test"
    Team        = "DevOps"
    Created_by  = "Amina"
    Name        = "subnet1"
  }
}


resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.VPC_Task1.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    Project     = "VPC_Task"
    Environment = "Test"
    Team        = "DevOps"
    Created_by  = "Amina"
    Name        = "subnet2"
  }
}

resource "aws_subnet" "subnet3" {
  vpc_id                  = aws_vpc.VPC_Task1.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1c"

  tags = {
    Project     = "VPC_Task"
    Environment = "Test"
    Team        = "DevOps"
    Created_by  = "Amina"
    Name        = "subnet3"
  }
}
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC_Task1.id

  tags = {
    Project     = "VPC_Task"
    Environment = "Test"
    Team        = "DevOps"
    Created_by  = "Amina"
    Name        = "IGW"
  }
}
resource "aws_security_group" "my_sg" {
  name   = "HTTP and SSH"
  vpc_id = aws_vpc.VPC_Task1.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project     = "VPC_Task"
    Environment = "Test"
    Team        = "DevOps"
    Created_by  = "Amina"
    Name        = "HTTP and SSH"
  }
}
resource "aws_lb" "alb" {
  name               = "task-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_sg.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id, aws_subnet.subnet3.id]

  enable_deletion_protection = true

  tags = {
    Project     = "VPC_Task"
    Environment = "Test"
    Team        = "DevOps"
    Created_by  = "Amina"
    Name        = "alb_task1"
  }
}
resource "aws_instance" "myinstance_Task1_1" {
  ami                         = "ami-0b5eea76982371e91"
  instance_type               = "t2.micro"
  key_name                    = "bastion-key"
  subnet_id                   = aws_subnet.subnet1.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.my_sg.id]


  user_data = <<EOF
   #!/bin/bash
   yum install httpd -y
   service httpd start
   chkconfig httpd on
   echo "Hello, world from EC2-1" > /var/www/html/index.html
   EOF


  tags = {
    Project     = "VPC_Task"
    Environment = "Test"
    Team        = "DevOps"
    Created_by  = "Amina"
    Name        = "Terraform_Task1_1"
  }
}

resource "aws_instance" "myinstance_Task1_2" {
  ami                         = "ami-0b5eea76982371e91"
  instance_type               = "t2.micro"
  key_name                    = "bastion-key"
  subnet_id                   = aws_subnet.subnet2.id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.my_sg.id]


  user_data = <<EOF
   #!/bin/bash
   yum install httpd -y
   service httpd start
   chkconfig httpd on
   echo "Hello, world from EC2-1" > /var/www/html/index.html
   EOF


  tags = {
    Project     = "VPC_Task"
    Environment = "Test"
    Team        = "DevOps"
    Created_by  = "Amina"
    Name        = "myinstance_Task1_2"
  }
}

resource "aws_instance" "Terraform_Task1_3" {
  ami                         = "ami-0b5eea76982371e91"
  instance_type               = "t2.micro"
  key_name                    = "bastion-key"
  subnet_id                   = aws_subnet.subnet3.id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.my_sg.id]

  user_data = <<EOF
   #!/bin/bash
   yum install httpd -y
   service httpd start
   chkconfig httpd on
   echo "Hello, world from EC2-1" > /var/www/html/index.html
   EOF

  tags = {
    Project     = "VPC_Task"
    Environment = "Test"
    Team        = "DevOps"
    Created_by  = "Amina"
    Name        = "Terraform_Task1_3"
  }
}
resource "aws_lb_target_group" "mytg-task1" {
  name     = "mytg-task1"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.VPC_Task1.id

  health_check {
    healthy_threshold   = 2
    interval            = 30
    protocol            = "HTTP"
    unhealthy_threshold = 2

  }
}

resource "aws_lb_target_group_attachment" "Instance1" {
  target_group_arn = aws_lb_target_group.mytg-task1.arn
  target_id        = aws_instance.myinstance_Task1_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "Instance2" {
  target_group_arn = aws_lb_target_group.mytg-task1.arn
  target_id        = aws_instance.myinstance_Task1_2.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "Instance3" {
  target_group_arn = aws_lb_target_group.mytg-task1.arn
  target_id        = aws_instance.Terraform_Task1_3.id
  port             = 80

}