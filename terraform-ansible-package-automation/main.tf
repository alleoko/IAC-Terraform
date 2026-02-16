provider "aws" {
  region = "us-east-1"  # Adjust region as needed
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f"  # Example AMI (Amazon Linux 2)
  instance_type = "t2.micro"
  key_name      = "your-key-pair"  # Replace with your key
  tags = {
    Name = "WebServer"
  }
}

resource "null_resource" "ansible" {
  depends_on = [aws_instance.web]

  provisioner "local-exec" {
    command = "ansible-playbook -i ${self.private_ip}, ansible/playbook.yml"
  }
}

