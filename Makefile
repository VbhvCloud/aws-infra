SHELL := /bin/zsh

init: 
	cd terraform && terraform init

fmt: init
	cd terraform && terraform fmt

plan: init fmt
	cd terraform && terraform plan

apply: init fmt
	cd terraform && terraform apply

destroy:
	cd terraform && terraform destroy
