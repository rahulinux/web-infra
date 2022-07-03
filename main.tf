locals {
  azs = [for i in ["a", "b", "c"] : "${var.region}${i}"]
  tags = {
    Owner       = "user"
    Environment = var.environment
    Project     = var.project
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.1"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = local.azs
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  single_nat_gateway = true

  tags = local.tags

  vpc_tags = {
    Name = "my-vpc"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key-${var.environment}"
  public_key = tls_private_key.rsa_key.public_key_openssh
}

resource "aws_instance" "web" {
  count           = var.create_instance ? 1 : 0
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  subnet_id       = element(module.vpc.public_subnets, 0)
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.web_infra.id]
  user_data = templatefile("./files/userdata.sh", {
    region = var.region
    az     = element(module.vpc.azs, 0)
  })
  tags = {
    Name = "web-${var.project}-${var.environment}"
  }

  lifecycle {
    ignore_changes = [security_groups]
  }
}

resource "aws_security_group" "web_infra" {
  name        = "web_infra"
  description = "Allow inbound traffic on web-infra"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP from myip"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["82.170.153.137/32"]
  }

  ingress {
    description = "SSH from myip"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["82.170.153.137/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = local.tags
}
