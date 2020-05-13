provider "aws" {
  region  = "us-east-2"
}


resource "aws_key_pair" "example" {
  key_name   = "terraform"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZC9j+OPWV2g/VKhtVK4zBU63fNeIYVVkVWLim3mnIuNxMGFK2v1p1Q3GWPXv0Y5HDBoGbGyTIfLJVwc4+E5vJqpUAd+yBLsXycOfGFxUiYsZyNG9Bg4hKEL+kpFlaYUl5P3+QxArfNTe83gti8+1R1VE25MVsGMkReGUEQGGFqiBoj6lsEl8x54zL/GLglpYZeFJoVZjHA5zpTxGKla9wI8tk2u6F21i+YI0qBDibOG+DdVJ5t2Hk6wv/DlOKwqu/5VSDqSgwpvDtnGK+Etmh2dCGJC1vQ911vxjnukyPq4J5QdmQR732N/tLMwpaOLAwlitFYmcFtwFNIeeS8cvjTC8PleqNitR0BXYaXXPMuOnuUVZ1wTTKFD2Tzf49kW8A19bdxkRw4GL69mV5tueWkLG2tesb/LoZfYT2NAExui66og7FGy5J+v0m8YL0RvEHebHlHkmem01DmGsLzbs2q6P212BGUjFrDtQ4OM3oJLEqNStxgNokRjQahJ10sHU= arpit.shah@M09-ArpitS.local"
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

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # All TCP access from anywhere
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # All ICMP access from anywhere
  ingress {
    protocol    = "icmp"
    from_port = -1
    to_port = -1
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
  ami           = "ami-00138b07206d4ceaf"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.moogsg.name]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/terraform.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
   inline = [
      "sudo yum -y install nginx",
      "sudo systemctl start nginx"
    ]
  }
}
