terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "ap-south-1"
}


resource "aws_vpc" "alpha-vpc" {
  cidr_block       = var.vpc-cidr-blocks
  instance_tenancy = "default"
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

module "subnet-module" {
  source                 = "./modules/subnet"
  vpc-id                 = aws_vpc.alpha-vpc.id
  subnet-cidr-block      = var.subnet-cidr-block
  avail_zone             = var.avail_zone
  env_prefix             = var.env_prefix
  default-route-table-id = aws_vpc.alpha-vpc.default_route_table_id

}

resource "aws_security_group" "alpha-sg" {
  name        = "alpha-sg"
  description = "Allow inbound traffic on port 22 and 8080"
  vpc_id      = aws_vpc.alpha-vpc.id
  ingress = [{
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.myip]
    description      = ""
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = "true"
    },
    {
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      description      = ""
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = "true"
  }]

  egress = [{
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    prefix_list_ids  = []
    description      = ""
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = "true"
    }
  ]

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}


data "aws_ami" "alpha-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*x86_64-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}



resource "aws_instance" "alpha-instance" {
  ami                         = data.aws_ami.alpha-ami.id
  instance_type               = var.instance-type
  key_name                    = var.key-name
  vpc_security_group_ids      = [aws_security_group.alpha-sg.id]
  subnet_id                   = module.subnet-module.subnet-id.id
  availability_zone           = var.avail_zone
  associate_public_ip_address = true

  # user_data = file("entry-script.sh")

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private-key-location)

  }

  provisioner "remote-exec" {
    inline = [
      "mkdir kandarp",
      "mkdir parikh"
    ]
  }

  tags = {
    Name = "${var.env_prefix}-instance"
  }
}
/*
resource "aws_spot_instance_request" "alpha_spot_instance" {
  ami                            = "ami-04db49c0fb2215364"
  spot_price                     = "0.004"
  spot_type                      = "persistent"
  instance_interruption_behavior = "stop"
  instance_type                  = "t2.micro"

  tags = {
    Name = "${var.env_prefix}-spot-instance"
  }
}
resource "aws_ec2_tag" "alpha-spot-tag" {
  resource_id = aws_spot_instance_request.alpha_spot_instance.spot_instance_id
  key         = "Name"
  value       = "alpha-spot-instance"
}
*/
