provider "aws" {
  region  = "us-west-2"
}


resource "aws_key_pair" "example" {
  key_name   = "terraform"
  public_key = file("~/.ssh/terraform.pub")
}

resource "aws_security_group" "moogsg" {
  name        = "moogsg"


  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  key_name      = aws_key_pair.example.key_name
  ami           = "ami-04590e7389a6e577c"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.moogsg.name]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/terraform.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras enable nginx1.12",
      "sudo yum -y install nginx",
      "sudo systemctl start nginx"
    ]
  }
}
