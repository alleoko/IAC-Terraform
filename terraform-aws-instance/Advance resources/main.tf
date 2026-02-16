provider "aws" {
  region = "us-east-1"  // Define the AWS region where resources will be created
}

# IAM Role: Allows EC2 to assume this role
resource "aws_iam_role" "ec2_role" {
  name = "ec2-s3-ssh-role"  // Name of the IAM role

  // Trust policy: allows EC2 service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"  // Who is allowed to assume the role
      }
      Effect = "Allow"
    }]
  })
}

# Attach S3 read-only policy to the role
resource "aws_iam_policy_attachment" "ec2_policy_attachment" {
  name       = "attach-s3-access"
  roles      = [aws_iam_role.ec2_role.name]  // Role to attach policy to
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"  // Policy that grants S3 access
}

# VPC: Define a virtual private cloud
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"  // CIDR block for the VPC
}

# Subnet: Define a subnet inside the VPC
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id  // Which VPC this subnet belongs to
  cidr_block        = "10.0.1.0/24"  // Subnet range
  availability_zone = "us-east-1a"  // AZ to place the subnet
}

# Security Group: Allow SSH access
resource "aws_security_group" "ssh_access" {
  name        = "ssh-access-group"
  description = "Allow SSH from anywhere"
  vpc_id     = aws_vpc.main.id  // The VPC this security group belongs to

  ingress {
    from_port   = 22    // Allow SSH on port 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  // Allow from any IP (restrict this in production!)
  }
}

# Key Pair: SSH key to access the instance
resource "aws_key_pair" "deployer_key" {
  key_name   = "deployer-key"  // Name of the key pair
  public_key = file("~/.ssh/id_rsa.pub")  // Your public SSH key file
}

# EC2 Instance Profile: Links the IAM role to the instance
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"  // Instance profile name
  role = aws_iam_role.ec2_role.name  // Role associated with this profile
}

# EC2 Instance: The actual compute resource
resource "aws_instance" "web" {
  ami           = "ami-0c55b4f5c6c0e9"  // The AMI ID for the EC2 (e.g., Ubuntu or Amazon Linux)
  instance_type = "t2.micro"  // Instance type
  subnet_id    = aws_subnet.main.id  // Where the instance will be launched
  security_groups = [aws_security_group.ssh_access.name]  // Attach the security group for SSH
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name  // Attach the IAM profile for role
  key_name    = aws_key_pair.deployer_key.key_name  // SSH key to access this instance
}
