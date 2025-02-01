##########################
# Provider and Variables #
##########################

provider "aws" {
  region = var.region
  profile = "user1"
}

variable "region" {
  description = "AWS region to deploy into"
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "The availability zone to use"
  default     = "us-east-1a"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances (Amazon Linux 2 is used here)"
  default     = "ami-04b4f1a9cf54c11d0"
}

variable "key_name" {
  description = "Name of the AWS key pair to use for SSH access"
  default     = "mujahed"  # Replace with your existing key pair name
}

variable "jenkins_instance_type" {
  description = "Instance type for Jenkins server"
  default     = "t2.micro"
}

variable "docker_instance_type" {
  description = "Instance type for Docker host"
  default     = "t2.micro"
}

##################
# Networking     #
##################

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ci-cd-vpc"
  }
}

# Create a public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ci-cd-igw"
  }
}

# Create a public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Associate the public subnet with the route table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

###########################
# Security Groups         #
###########################

# Security group for Jenkins server
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and Jenkins (port 8080) access"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins Web UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

# Security group for Docker host
resource "aws_security_group" "docker_sg" {
  name        = "docker-host-sg"
  description = "Allow SSH and HTTP (port 80) access"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "docker-host-sg"
  }
}

###########################
# EC2 Instances           #
###########################

# Jenkins Server Instance
resource "aws_instance" "jenkins" {
  ami                    = var.ami_id
  instance_type          = var.jenkins_instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  tags = {
    Name = "Jenkins-Server"
  }
}

# Docker Host Instance
resource "aws_instance" "docker_host" {
  ami                    = var.ami_id
  instance_type          = var.docker_instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.docker_sg.id]

  tags = {
    Name = "Docker-Host"
  }
}

###########################
# Outputs                 #
###########################

output "jenkins_public_ip" {
  description = "Public IP of the Jenkins server"
  value       = aws_instance.jenkins.public_ip
}

output "docker_host_public_ip" {
  description = "Public IP of the Docker host"
  value       = aws_instance.docker_host.public_ip
}
