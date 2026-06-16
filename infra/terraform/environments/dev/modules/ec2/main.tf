data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "bootcamp-ec2-sg"
  description = "Allow SSH from my IP"
  vpc_id      = var.vpc_id

  ingress {
    description = "Nginx NodePort from my IP"
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = ["5.77.194.122/32"]
  }

  ingress {
    description = "Frontend NodePort from my IP"
    from_port   = 30081
    to_port     = 30081
    protocol    = "tcp"
    cidr_blocks = ["5.77.194.122/32"]
  }

  ingress {
    description = "API NodePort from my IP"
    from_port   = 30082
    to_port     = 30082
    protocol    = "tcp"
    cidr_blocks = ["5.77.194.122/32"]
  }

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["5.77.194.122/32"]
  }

  ingress {
    description = "Kubernetes API from my IP"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["5.77.194.122/32"]
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
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = aws_key_pair.bootcamp.key_name
  associate_public_ip_address = true
  iam_instance_profile        = var.instance_profile_name

  root_block_device {
    volume_size = 20    # GB — free tier allows up to 30GB gp3
    volume_type = "gp3"
    delete_on_termination = true
  }

  user_data_replace_on_change = true

  user_data = <<-EOF
#!/bin/bash
set -eux

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="v1.30.4+k3s1" sh -s - server \
  --disable servicelb \
  --disable traefik \
  --tls-san ${aws_eip.main.public_ip} \
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
