lint:
	terraform fmt --recursive

validate: lint
	terraform init --upgrade
	terraform validate

docs:
	rm -rf examples/*/.terraform examples/*/.terraform.lock.hcl
	rm -rf modules/*/.terraform modules/*/.terraform.lock.hcl
	terraform-docs -c .terraform-docs.yml .
