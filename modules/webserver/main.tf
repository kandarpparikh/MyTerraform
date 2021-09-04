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

resource "aws_security_group" "alpha-sg" {
  name        = "alpha-sg"
  description = "Allow inbound traffic on port 22 and 8080"
  vpc_id      = var.vpc-id
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


resource "aws_instance" "alpha-instance" {
  ami                         = data.aws_ami.alpha-ami.id
  instance_type               = var.instance-type
  key_name                    = var.key-name
  vpc_security_group_ids      = [aws_security_group.alpha-sg.id]
  subnet_id                   = var.subnet-id
  availability_zone           = var.avail_zone
  associate_public_ip_address = true

  user_data = file("entry-script.sh")

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
