commit: docs validate

docs:
	terraform-docs --lockfile=false -c .terraform-docs.yml .

init:
	git submodule update --init --recursive
	terraform init -upgrade

lint:
	terraform fmt --recursive

tests:
# Super long timeout since this Makefile will be used in various repositories
	cd test; go clean -testcache; go test -v -timeout 60m

validate: lint
	terraform init --upgrade
	terraform validate
