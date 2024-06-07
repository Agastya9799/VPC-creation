# Define the provider
provider "aws" {
  region = "ap-south-1"
}

# Create the first VPC
resource "aws_vpc" "vpc_chennai" {
  cidr_block       = "12.0.0.0/16"
  instance_tenancy = "default"
  
  tags = {
    Name = "vpc-chennai"
  }
}

# Create the second VPC
resource "aws_vpc" "vpc_nellore" {
  cidr_block       = "13.0.0.0/16"
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

# Create a subnet for VPC Chennai (Public Subnet)
resource "aws_subnet" "subnet_vpc_chennai_public" {
  vpc_id            = aws_vpc.vpc_chennai.id
  availability_zone = "ap-south-1a"
  cidr_block        = "12.0.1.0/24"
  
  tags = {
    Name = "subnet-vpc-chennai-public"
  }
}

# Create a subnet for VPC Chennai (Private Subnet)
resource "aws_subnet" "subnet_vpc_chennai_private" {
  vpc_id            = aws_vpc.vpc_chennai.id
  availability_zone = "ap-south-1a"
  cidr_block        = "12.0.2.0/24"
  
  tags = {
    Name = "subnet-vpc-chennai-private"
  }
}

# Create a subnet for VPC Nellore (Private Subnet)
resource "aws_subnet" "subnet_vpc_nellore_private" {
  vpc_id            = aws_vpc.vpc_nellore.id
  availability_zone = "ap-south-1a"
  cidr_block        = "13.0.1.0/24"
  
  tags = {
    Name = "subnet-vpc-nellore-private"
  }
}

# Associate the route table for VPC Chennai with the public subnet
resource "aws_route_table_association" "associate_rt_chennai_public_subnet" {
  subnet_id      = aws_subnet.subnet_vpc_chennai_public.id
  route_table_id = aws_route_table.rt_vpc_chennai.id
}

# Associate the route table for VPC Chennai with the private subnet
resource "aws_route_table_association" "associate_rt_chennai_private_subnet" {
  subnet_id      = aws_subnet.subnet_vpc_chennai_private.id
  route_table_id = aws_route_table.rt_vpc_chennai.id
}

# Associate the route table for VPC Nellore with the subnet
resource "aws_route_table_association" "associate_rt_nellore_subnet" {
  subnet_id      = aws_subnet.subnet_vpc_nellore_private.id
  route_table_id = aws_route_table.rt_vpc_nellore.id
}

# Create an internet gateway for VPC Chennai
resource "aws_internet_gateway" "igw_vpc_chennai" {
  vpc_id = aws_vpc.vpc_chennai.id
  
  tags = {
    Name = "igw-vpc-chennai"
  }
}

# Attach the internet gateway to VPC Chennai
resource "aws_vpc_attachment" "attach_igw_to_vpc_chennai" {
  vpc_id             = aws_vpc.vpc_chennai.id
  internet_gateway_id = aws_internet_gateway.igw_vpc_chennai.id
}

# Add route to route table for VPC Chennai
resource "aws_route" "route_to_internet" {
  route_table_id         = aws_route_table.rt_vpc_chennai.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_vpc_chennai.id
}

# Create an EC2 instance in the public subnet of VPC Chennai
resource "aws_instance" "ec2_instance_chennai" {
  ami             = "ami-00fa32593b478ad6e" # Replace with the AMI ID of Amazon Linux 2023
  instance_type   = "t2.micro"
  key_name        = "vpc-chennai-ec2-key"
  subnet_id       = aws_subnet.subnet_vpc_chennai_public.id
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance in the private subnet of VPC Chennai
resource "aws_instance" "ec2_instance_chennai_private" {
  ami             = "ami-00fa32593b478ad6e" # Replace with the AMI ID of Amazon Linux 2023
  instance_type   = "t2.micro"
  key_name        = "vpc-chennai-ec2-key"
  subnet_id       = aws_subnet.subnet_vpc_chennai_private.id
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
    Name = "vpc-chennai-ec2-instance-private"
  }
}

# Create an EC2 instance in Nellore
resource "aws_instance" "ec2_instance_nellore" {
  ami             = "ami-00fa32593b478ad6e" # Replace with the AMI ID of Amazon Linux 2023
  instance_type   = "t2.micro"
  key_name        = "vpc-nellore-ec2-key"
  subnet_id       = aws_subnet.subnet_vpc_nellore_private.id
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
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create VPC Peering Connection
resource "aws_vpc_peering_connection" "vpc_peering" {
  vpc_id        = aws_vpc.vpc_chennai.id
  peer_vpc_id   = aws_vpc.vpc_nellore.id
  peer_region   = "ap-south-1"
  auto_accept   = true
  
  tags = {
    Name = "vpc-peering-chennai-nellore"
  }
}

# Add a route to Chennai VPC's route table for Nellore VPC
resource "aws_route" "route_nellore_in_chennai" {
  route_table_id         = aws_route_table.rt_vpc_chennai.id
  destination_cidr_block = aws_vpc.vpc_nellore.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}

# Add a route to Nellore VPC's route table for Chennai VPC
resource "aws_route" "route_chennai_in_nellore" {
  route_table_id         = aws_route_table.rt_vpc_nellore.id
  destination_cidr_block = aws_vpc.vpc_chennai.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "eip_nat_chennai" {
  vpc = true
}

# Create NAT Gateway for Private Subnet in Chennai VPC
resource "aws_nat_gateway" "nat_gateway_chennai" {
  allocation_id = aws_eip.eip_nat_chennai.id
  subnet_id     = aws_subnet.subnet_vpc_chennai_public.id
  
  tags = {
    Name = "nat-gateway-chennai"
  }
}

# Route Table for Private Subnet in Chennai VPC
resource "aws_route_table" "rt_vpc_chennai_private" {
  vpc_id = aws_vpc.vpc_chennai.id
  
  tags = {
    Name = "rt-vpc-chennai-private"
  }
}

# Route Table Association for Private Subnet in Chennai VPC
resource "aws_route_table_association" "associate_rt_chennai_private_subnet_nat" {
  subnet_id      = aws_subnet.subnet_vpc_chennai_private.id
  route_table_id = aws_route_table.rt_vpc_chennai_private.id
}

# Add route to NAT Gateway for Private Subnet in Chennai VPC
resource "aws_route" "route_to_nat_gateway" {
  route_table_id         = aws_route_table.rt_vpc_chennai_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_chennai.id
}

# Create Bastion Host in Public Subnet of Chennai VPC
resource "aws_instance" "bastion_host_chennai" {
  ami               = "ami-00fa32593b478ad6e" # Replace with valid AMI ID
  instance_type     = "t2.micro"
  key_name          = "vpc-chennai-ec2-key"
  subnet_id         = aws_subnet.subnet_vpc_chennai_public.id
  security_groups   = [aws_security_group.sg_chennai_bastion.name]
  associate_public_ip_address = true

  tags = {
    Name = "vpc-chennai-bastion-host"
  }
}

# Security Group for Bastion Host
resource "aws_security_group" "sg_chennai_bastion" {
  name        = "sg-chennai-bastion"
  description = "Security group for Bastion Host in VPC Chennai"
  vpc_id      = aws_vpc.vpc_chennai.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["your_ip_address/32"] # Replace with your IP address
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Network ACL for Chennai VPC
resource "aws_network_acl" "nacl_vpc_chennai" {
  vpc_id = aws_vpc.vpc_chennai.id

  tags = {
    Name = "nacl-vpc-chennai"
  }
}

# Allow inbound traffic for SSH and HTTP
resource "aws_network_acl_rule" "inbound_allow_ssh_http" {
  network_acl_id = aws_network_acl.nacl_vpc_chennai.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  egress         = false
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 80
}

# Allow all outbound traffic
resource "aws_network_acl_rule" "outbound_allow_all" {
  network_acl_id = aws_network_acl.nacl_vpc_chennai.id
  rule_number    = 100
  protocol       = "-1"
  rule_action    = "allow"
  egress         = true
  cidr_block     = "0.0.0.0/0"
}

# Enhanced Security Group Rules for Chennai EC2 instance with restricted SSH access
resource "aws_security_group" "sg_chennai_enhanced" {
  name        = "sg-chennai-enhanced"
  description = "Enhanced Security group for EC2 instance in VPC Chennai"
  vpc_id      = aws_vpc.vpc_chennai.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["your_ip_address/32"] # Replace with your IP address
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
