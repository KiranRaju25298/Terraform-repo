terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "publicsubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "publicsubnet"
  }
}

resource "aws_subnet" "privatesubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "privatesubnet"
  }
}

resource "aws_internet_gateway" "tigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "tigw"
  }
}

 resource "aws_route_table" "pubrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tigw.id
  }
  tags = {
    Name = "pubrt"
  }
}

resource "aws_route_table_association" "publicasso" {
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.pubrt.id
}

resource "aws_security_group" "pubsg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 3389
    to_port          = 3389
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pubsg"
  }
}

resource "aws_security_group" "prisg"   {
  name        = "allow_ssh"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 3389
    to_port          = 3389
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "prisg"
  }
}

resource "aws_instance" "webserver"{
 ami                           = "ami-074dc0a6f6c764218"
 instance_type                 = "t2.micro"
 subnet_id                     = aws_subnet.publicsubnet.id
 vpc_security_group_ids        = [aws_security_group.pubsg.id]
 key_name                      = "LINUXNEW"
 associate_public_ip_address   = true
}

resource "aws_instance" "dbserver"{
 ami                           = "ami-074dc0a6f6c764218"
 instance_type                 = "t2.micro"
 subnet_id                     = aws_subnet.privatesubnet.id
 vpc_security_group_ids        = [aws_security_group.prisg.id]
 key_name                      = "LINUXNEW"
 associate_public_ip_address  = false
 }
