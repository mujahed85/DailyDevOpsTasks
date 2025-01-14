provider "aws" {
  region = "us-east-1"  # Update the region as per your requirement
}

# -------------------------
# Step 1: Create EC2 Instances
# -------------------------

resource "aws_instance" "web_server_1" {
  ami             = "ami-0e2c8caa4b6378d8c"  # Update with the correct AMI ID (e.g., Ubuntu)
  instance_type   = "t2.micro"                # Choose instance type
  key_name        = "example"                 # Use your existing SSH key pair name
  security_groups = [aws_security_group.default_sg.name]

  tags = {
    Name = "WebServer1"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install apache2 -y
              systemctl start apache2
              systemctl enable apache2
              echo "Hello from Instance 1" > /var/www/html/index.html
            EOF
}

resource "aws_instance" "web_server_2" {
  ami             = "ami-0e2c8caa4b6378d8c"  # Update with the correct AMI ID (e.g., Ubuntu)
  instance_type   = "t2.micro"                # Choose instance type
  key_name        = "example"                 # Use your existing SSH key pair name
  security_groups = [aws_security_group.default_sg.name]

  tags = {
    Name = "WebServer2"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install apache2 -y
              systemctl start apache2
              systemctl enable apache2
              echo "Hello from Instance 2" > /var/www/html/index.html
            EOF
}

# -------------------------------
# Step 2: Create Security Group
# -------------------------------

resource "aws_security_group" "default_sg" {
  name        = "default_sg"
  description = "Allow HTTP traffic"

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


# -------------------------------
# Step 3: Create Target Group
# -------------------------------

resource "aws_lb_target_group" "nlb_target_group" {
  name     = "nlb-target-group"
  port     = 80
  protocol = "TCP"
  vpc_id   = "vpc-043232ff9f4b108ce"  # Replace with your VPC ID

  health_check {
    healthy_threshold   = 3
    interval            = 30
    timeout             = 5
    unhealthy_threshold = 3
    protocol            = "TCP"
  }
}

# Register EC2 instances as targets
resource "aws_lb_target_group_attachment" "web_server_1_attachment" {
  target_group_arn = "${aws_lb_target_group.nlb_target_group.arn}"
  target_id        = "${aws_instance.web_server_1.id}"
  port             = 80
}

resource "aws_lb_target_group_attachment" "web_server_2_attachment" {
  target_group_arn = "${aws_lb_target_group.nlb_target_group.arn}"
  target_id        = "${aws_instance.web_server_2.id}"
  port             = 80
}

# -------------------------------
# Step 4: Create Network Load Balancer
# -------------------------------

resource "aws_lb" "nlb" {
  name               = "my-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = ["subnet-075fab9a592fde14a", "subnet-07d1788aaa5003d8d", "subnet-0ea1001155a48ed3f"]  # Replace with your subnet IDs

  enable_deletion_protection = false
}

# -------------------------------
# Step 5: Create Listener for NLB
# -------------------------------

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = "${aws_lb.nlb.arn}"
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.nlb_target_group.arn}"
  }
}

# -------------------------------
# Step 6: Output EC2 Instance IDs and NLB DNS
# -------------------------------

output "web_server_1_id" {
  value = "${aws_instance.web_server_1.id}"
}

output "web_server_2_id" {
  value = "${aws_instance.web_server_2.id}"
}

output "nlb_dns_name" {
  value = "${aws_lb.nlb.dns_name}"
}