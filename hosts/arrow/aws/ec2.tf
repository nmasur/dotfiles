resource "aws_instance" "instance" {
  ami                    = aws_ami.image.id
  iam_instance_profile   = aws_iam_instance_profile.instance.name
  instance_type          = var.ec2_size
  vpc_security_group_ids = [aws_security_group.instance.id]

  tags = {
    Name = "aws-nixos"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ec2_instance_state" "instance" {
  instance_id = aws_instance.instance.id
  state       = "running"
}

data "aws_vpc" "vpc" {
  default = true
}

resource "aws_security_group" "instance" {
  name        = "aws-nixos"
  description = "Allow SSH and HTTPS"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description = "Ping"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

# Setup IAM for the instance to use SSM
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "instance_profile" {
  statement {
    actions = [
      "s3:ListAllMyBuckets",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "instance_profile" {
  name               = "nixos"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  inline_policy {
    name   = "instance-profile"
    policy = data.aws_iam_policy_document.instance_profile.json
  }
}
resource "aws_iam_role_policy_attachment" "instance_ssm" {
  role       = aws_iam_role.instance_profile.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "instance" {
  name = "nixos"
  role = aws_iam_role.instance_profile.name
}
