
resource "aws_instance" "ec2_instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnets[0].id
  vpc_security_group_ids      = [aws_security_group.security_group.id]
  disable_api_termination     = true
  user_data_replace_on_change = true
  iam_instance_profile        = aws_iam_instance_profile.EC2-CSYE6225_instance_profile.name
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
  user_data = <<EOF
    #!/bin/bash
    sed -i 's/POSTGRES_USER ?= webapp/POSTGRES_USER ?= '${var.db_username}'/g' /home/ec2-user/webapp/Makefile
    sed -i 's/POSTGRES_PASSWORD ?= webapp/POSTGRES_PASSWORD ?= '${var.db_password}'/g' /home/ec2-user/webapp/Makefile
    sed -i 's/POSTGRES_HOST ?= 127.0.0.1/POSTGRES_HOST ?= '${aws_db_instance.main.address}'/g' /home/ec2-user/webapp/Makefile
    sed -i 's/POSTGRES_DB ?= webapp/POSTGRES_DB ?= '${var.db_name}'/g' /home/ec2-user/webapp/Makefile
    sed -i 's/S3_BUCKET ?= test/S3_BUCKET ?= '${aws_s3_bucket.private.id}'/g' /home/ec2-user/webapp/Makefile
  EOF
}

resource "aws_iam_instance_profile" "EC2-CSYE6225_instance_profile" {
  name = "EC2-CSYE6225_Role_Instance_profile"
  role = aws_iam_role.EC2-CSYE6225.name
}



resource "null_resource" "reboot_instance" {

  provisioner "local-exec" {
    on_failure  = fail
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
        sleep 20
        aws ec2 reboot-instances --instance-ids ${aws_instance.ec2_instance.id} --profile ${var.profile}
     EOT
  }
  #   this setting will trigger script every time,change it something needed
  triggers = {
    always_run = "${timestamp()}"
  }
}