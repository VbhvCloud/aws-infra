resource "aws_instance" "ec2_instance" {
  ami                     = var.ami_id
  instance_type           = var.instance_type
  subnet_id               = aws_subnet.public_subnets[0].id
  vpc_security_group_ids  = [aws_security_group.security_group.id]
  disable_api_termination = false
  depends_on = [
    aws_security_group.security_group
  ]
  root_block_device {
    volume_size = var.instance_volume_size
    volume_type = var.instance_volume_type
  }
  tags = {
    Name = "Webapp EC2 Instance"
  }
}