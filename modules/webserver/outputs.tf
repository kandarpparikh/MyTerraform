output "ami-id" {
  value = data.aws_ami.alpha-ami.id
}

output "instance-id" {
  value = aws_instance.alpha-instance.id
}