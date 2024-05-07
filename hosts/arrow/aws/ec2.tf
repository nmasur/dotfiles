resource "aws_instance" "instance" {
  ami                    = aws_ami.image.id
  instance_type          = var.ec2_size
  vpc_security_group_ids = [aws_security_group.instance.id]

  tags = {
    Name = "aws-nixos"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_vpc" "vpc" {
  default = true
}

resource "aws_security_group" "instance" {
  name        = "aws-nixos"
  description = "Allow SSH and HTTPS"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
