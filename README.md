# Terraform Configuration for Creating an AWS VPC with Networking Resources

This Terraform configuration file sets up a Virtual Private Cloud (VPC) in AWS with the following networking resources:

- 3 public subnets and 3 private subnets, each in a different availability zone in the same region in the same VPC
- An Internet Gateway resource attached to the VPC
- A public route table with all public subnets attached to it
- A private route table with all private subnets attached to it
- A public route in the public route table with the destination CIDR block 0.0.0.0/0 and the internet gateway created above as the target.


## Prerequisites

- An AWS account and access keys with permissions to create VPCs and related resources.
- Terraform installed on your local machine.
- AWS CLI installed on your local machine.

## Configuration

- Clone the repository to your local machine.
- In the command line, navigate to the directory where the main.tf file is located.
- create terraform.tfvars file and set the following variables.
   1. profile
   2. public_subnet_count
   3. private_subnet_count
   4. vpc_cidr_block
   5. region
   6. create_cidr
- Run the terraform init command to initialize the Terraform configuration file.

      terraform init
- Run the terraform plan command to see a preview of the resources that will be created.

      terraform plan
- Run the terraform apply command to create the resources.

      terraform apply
- After you are finished, run the terraform destroy command to delete the resources.

      terraform destroy

## Conclusion

This Terraform configuration file provides an easy and repeatable way to create a VPC with networking resources in AWS. By using this configuration file, you can create multiple VPCs with the same resources in the same AWS account and region.


