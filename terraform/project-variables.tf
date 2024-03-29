
variable "region" {
  type        = string
  description = "AWS region to use"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR block"
}

variable "profile" {
  type        = string
  description = "Profile to use for deployment"
}

variable "public_subnet_count" {
  type = number
}

variable "private_subnet_count" {
  type = number
}

variable "create_cidr" {
  type = bool
}

variable "public_subnet_cidr" {
  type    = list(any)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidr" {
  type    = list(any)
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "instance_type" {
  type    = string
  default = "t2.micro"

}

variable "instance_volume_size" {
  type    = number
  default = 50
}

variable "app_port" {
  type    = number
  default = 8000
}

variable "instance_volume_type" {
  type    = string
  default = "gp2"
}

variable "db_engine" {
  type    = string
  default = "postgres"
}

variable "db_instance" {
  type    = string
  default = "db.t3.micro"
}

variable "db_multi_az" {
  type    = bool
  default = false
}

variable "db_instance_identifier" {
  type    = string
  default = "csye6225"
}

variable "db_username" {
  type    = string
  default = "csye6225"
}

variable "db_password" {
  type = string
}

variable "db_name" {
  type    = string
  default = "csye6225"
}

variable "a_record_name" {
  type    = string
  default = "dev.vaibhavmahajan.me"
}

variable "mailgun_api_key" {
  type = string
}

variable "mailgun_domain" {
  type = string
}

variable "mailgun_sender" {
  type = string
}

locals {
  public_subnets  = var.create_cidr ? [for i in range(1, var.public_subnet_count + 1) : cidrsubnet(var.vpc_cidr_block, 8, i)] : var.public_subnet_cidr
  private_subnets = var.create_cidr ? [for i in range(1, var.private_subnet_count + 1) : cidrsubnet(var.vpc_cidr_block, 8, i + var.public_subnet_count)] : var.private_subnet_cidr
}