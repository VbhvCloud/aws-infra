SHELL := /bin/zsh

file_name := variables-demo.tfvar

# =============================================================================

init: 
	cd terraform && terraform init

fmt: init
	cd terraform && terraform fmt

plan: init fmt
	echo $(file_name)
	cd terraform && terraform plan -var-file="$(file_name)"

apply: init fmt
	cd terraform && terraform apply -var-file="$(file_name)"

destroy:
	cd terraform && terraform destroy -var-file="$(file_name)"
