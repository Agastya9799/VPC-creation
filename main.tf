# Define the provider
provider "aws" {
  region = "your_aws_region"
}

# Create the first VPC
resource "aws_vpc" "vpc_chennai" {
  cidr_block       = "12.0.0.0/16"
  enable_ipv6     = false
  instance_tenancy = "default"
  
  tags = {
    Name = "vpc-chennai"
  }
}

# Create the second VPC
resource "aws_vpc" "vpc_nellore" {
  cidr_block       = "13.0.0.0/16"
  enable_ipv6     = false
  instance_tenancy = "default"
  
  tags = {
    Name = "vpc-nellore"
  }
}

# Create a route table for VPC Chennai
resource "aws_route_table" "rt_vpc_chennai" {
  vpc_id = aws_vpc.vpc_chennai.id
  
  tags = {
    Name = "rt-vpc-chennai"
  }
}

# Create a route table for VPC Nellore
resource "aws_route_table" "rt_vpc_nellore" {
  vpc_id = aws_vpc.vpc_nellore.id
  
  tags = {
    Name = "rt-vpc-nellore"
  }
}

# Create a subnet for VPC Chennai
resource "aws_subnet" "subnet_vpc_chennai_1a" {
  vpc_id            = aws_vpc.vpc_chennai.id
  availability_zone = "ap-south-1a"
  cidr_block        = "12.0.1.0/24"
  
  tags = {
    Name = "subnet-vpc-chennai-1a"
  }
}

# Create a subnet for VPC Nellore
resource "aws_subnet" "subnet_vpc_nellore_1a" {
  vpc_id            = aws_vpc.vpc_nellore.id
  availability_zone = "ap-south-1a"
  cidr_block        = "13.0.1.0/24"
  
  tags = {
    Name = "subnet-vpc-nellore-1a"
  }
}

# Associate the route table for VPC Chennai with the subnet
resource "aws_route_table_association" "associate_rt_chennai_subnet" {
  subnet_id      = aws_subnet.subnet_vpc_chennai_1a.id
  route_table_id = aws_route_table.rt_vpc_chennai.id
}

# Associate the route table for VPC Nellore with the subnet
resource "aws_route_table_association" "associate_rt_nellore_subnet" {
  subnet_id      = aws_subnet.subnet_vpc_nellore_1a.id
  route_table_id = aws_route_table.rt_vpc_nellore.id
}

# Create an internet gateway for VPC Chennai
resource "aws_internet_gateway" "igw_vpc_chennai" {
  vpc_id = aws_vpc.vpc_chennai.id
  
  tags = {
    Name = "igw-vpc-chennai"
  }
}

# Create an internet gateway for VPC Nellore
resource "aws_internet_gateway" "igw_vpc_nellore" {
  vpc_id = aws_vpc.vpc_nellore.id
  
  tags = {
    Name = "igw-vpc-nellore"
  }
}

# Attach the internet gateway to VPC Chennai
resource "aws_vpc_attachment" "attach_igw_to_vpc_chennai" {
  vpc_id             = aws_vpc.vpc_chennai.id
  internet_gateway_id = aws_internet_gateway.igw_vpc_chennai.id
}

# Attach the internet gateway to VPC Nellore
resource "aws_vpc_attachment" "attach_igw_to_vpc_nellore" {
  vpc_id             = aws_vpc.vpc_nellore.id
  internet_gateway_id = aws_internet_gateway.igw_vpc_nellore.id
}

# Add route to route table for VPC Chennai
resource "aws_route" "route_to_internet" {
  route_table_id         = aws_route_table.rt_vpc_chennai.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_vpc_chennai.id
}

# Add route to route table for VPC Nellore
resource "aws_route" "route_to_internet" {
  route_table_id         = aws_route_table.rt_vpc_nellore.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_vpc_nellore.id
}

# Create an EC2 instance
resource "aws_instance" "ec2_instance_chennai" {
  ami             = "ami-xxxxxxxxxxxxx" # Replace with the AMI ID of Amazon Linux 2023
  instance_type   = "t2.micro"
  key_name        = "vpc-chennai-ec2-key"
  subnet_id       = aws_subnet.subnet_vpc_chennai_1a.id
  associate_public_ip_address = true
  security_groups = [aws_security_group.sg_chennai.name]
  
  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }
  
  user_data = <<-EOF
              #!/bin/bash
              # Use this for your user data (script from top to bottom)
              # install httpd (Linux 2 version)
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
              EOF
  
  tags = {
    Name = "vpc-chennai-ec2-instance"
  }
}

# Create a security group for EC2 instance
resource "aws_security_group" "sg_chennai" {
  name        = "sg-chennai"
  description = "Security group for EC2 instance in VPC Chennai"
  vpc_id      = aws_vpc.vpc_chennai.id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance in Nellore
resource "aws_instance" "ec2_instance_nellore" {
  ami             = "ami-xxxxxxxxxxxxx" # Replace with the AMI ID of Amazon Linux 2023
  instance_type   = "t2.micro"
  key_name        = "vpc-nellore-ec2-key"
  subnet_id       = aws_subnet.subnet_vpc_nellore_1a.id
  associate_public_ip_address = true
  security_groups = [aws_security_group.sg_nellore.name]
  
  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }
  
  user_data = <<-EOF
              #!/bin/bash
              # Use this for your user data (script from top to bottom)
              # install httpd (Linux 2 version)
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
              EOF
  
  tags = {
    Name = "vpc-nellore-ec2-instance"
  }
}

# Create a security group for EC2 instance in Nellore
resource "aws_security_group" "sg_nellore" {
  name        = "sg-nellore"
  description = "Security group for EC2 instance in VPC Nellore"
  vpc_id      = aws_vpc.vpc_nellore.id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create VPC peering connection between vpc-chennai and vpc-nellore
resource "aws_vpc_peering_connection" "peering_connection" {
  provider                    = aws.my_provider
  peer_owner_id               = "your_account_id"
  peer_vpc_id                 = aws_vpc.vpc_nellore.id
  vpc_id                      = aws_vpc.vpc_chennai.id
  auto_accept                 = true
  
  tags = {
    Name = "peering-connection-between-vpc-chennai-and-vpc-nellore"
  }
}

# Add route to route table for VPC Chennai to reach VPC Nellore
resource "aws_route" "route_to_peering_nellore" {
  route_table_id         = aws_route_table.rt_vpc_chennai.id
  destination_cidr_block = "13.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection.id
}

# Add route to route table for VPC Nellore to reach VPC Chennai
resource "aws_route" "route_to_peering_chennai" {
  route_table_id         = aws_route_table.rt_vpc_nellore.id
  destination_cidr_block = "12.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection.id
}


