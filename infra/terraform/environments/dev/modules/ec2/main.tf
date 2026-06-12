resource "aws_security_group" "ec2_sg" {
  name        = "bootcamp-ec2-sg"
  description = "Allow SSH from my IP"
  vpc_id      = var.vpc_id
  ingress {
    description = "Nginx NodePort from my IP"
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = ["5.77.201.81/32"]
  }

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["5.77.201.81/32"]
  }

  ingress {
    description = "Kubernetes API from my IP"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["5.77.201.81/32"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bootcamp-ec2-sg"
  }
}

resource "aws_key_pair" "bootcamp" {
  key_name   = "bootcamp"
  public_key = file("~/.ssh/bootcamp-key.pub")
}

resource "aws_instance" "main" {
  ami                         = "ami-0c101f26f147fa7fd"
  instance_type               = "t3.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = aws_key_pair.bootcamp.key_name
  associate_public_ip_address = true
  iam_instance_profile        = var.instance_profile_name

  user_data_replace_on_change = true

  user_data = <<-EOF
#!/bin/bash
set -eux

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="v1.30.4+k3s1" sh -s - server \
  --disable servicelb \
  --disable traefik \
  --tls-san 3.230.130.236 \
  --write-kubeconfig-mode 644
EOF
}

resource "aws_eip" "main" {
  domain = "vpc"

  tags = {
    Name = "bootcamp-eip"
  }
}

resource "aws_eip_association" "main" {
  instance_id   = aws_instance.main.id
  allocation_id = aws_eip.main.id
}
