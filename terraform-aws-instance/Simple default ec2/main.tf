#Simple deployment of instance ec2 in aws
provider "aws" {
  region = "us-east-1"  // Choose your desired region
}

# Security Group: Allow all inbound traffic (not recommended for production)
resource "aws_security_group" "allow_all" {
  name        = "allow-all-traffic"
  description = "Allow all inbound traffic"
  vpc_id     = aws_vpc.main.id  // We'll use a default VPC for simplicity

  ingress {
    from_port   = 0    // Allow all ports
    to_port     = 0
    protocol    = "-1"  // All protocols
    cidr_blocks = ["0.0.0.0/0"]  // Allow all IPs (public access)
  }
}

# EC2 Instance: Simple instance deployment
resource "aws_instance" "web" {
  ami           = "ami-0c55b4f5c6c0e9"  // Replace with a valid AMI for your region
  instance_type = "t2.micro"  // Choose a small instance type
  security_groups = [aws_security_group.allow_all.name]  // Attach security group
}

# Optional: Use the default VPC (for simplicity)
data "aws_vpc" "main" {
  default = true  // Use the default VPC
}