provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f"  # Amazon Linux example
  instance_type = "t2.micro"
  key_name      = "your-key-pair"
  tags = {
    Name = "PythonAutomationServer"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y python3",
      "python3 /home/ubuntu/tf-python-script.py"
    ]
  }
}
