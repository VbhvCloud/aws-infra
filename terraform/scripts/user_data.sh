#!/bin/bash

echo "vaibhav"
sed -i 's/POSTGRES_USER ?= webapp/POSTGRES_USER ?= '${db_username}'/g' /home/ec2-user/webapp/Makefile
sed -i 's/POSTGRES_PASSWORD ?= webapp/POSTGRES_PASSWORD ?= '${db_password}'/g' /home/ec2-user/webapp/Makefile
sed -i 's/POSTGRES_HOST ?= 127.0.0.1/POSTGRES_HOST ?= '${db_host}'/g' /home/ec2-user/webapp/Makefile
sed -i 's/POSTGRES_DB ?= webapp/POSTGRES_DB ?= '${db_name}'/g' /home/ec2-user/webapp/Makefile
sed -i 's/S3_BUCKET ?= test/S3_BUCKET ?= '${aws_s3_bucket}'/g' /home/ec2-user/webapp/Makefile
echo "vaibhav end"