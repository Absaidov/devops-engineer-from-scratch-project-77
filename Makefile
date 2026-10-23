ANSIBLE_PLAYBOOK ?= ansible-playbook
ANSIBLE_VAULT ?= ansible-vault
TERRAFORM ?= terraform

ANSIBLE_INVENTORY ?= ansible/inventory.ini
ANSIBLE_PLAYBOOK_FILE ?= ansible/playbook.yml
VAULT_FILE ?= ansible/group_vars/all/vault.yml
VAULT_ID ?= project77
TERRAFORM_DIR ?= terraform

VAULT_ARGS = --vault-id "$(VAULT_ID)@prompt"

.PHONY: setup init fmt validate check plan apply destroy output test \
	vault-create vault-edit vault-view secrets \
	terraform-init terraform-init-local terraform-fmt terraform-validate \
	terraform-plan terraform-apply terraform-destroy terraform-output

setup: secrets terraform-init

init: terraform-init

fmt: terraform-fmt

validate: terraform-validate

check: terraform-fmt terraform-validate

plan: terraform-plan

apply: terraform-apply

destroy: terraform-destroy

output: terraform-output

test: terraform-fmt terraform-validate

vault-create:
	@test ! -e "$(VAULT_FILE)" || { echo "$(VAULT_FILE) already exists; use make vault-edit" >&2; exit 1; }
	$(ANSIBLE_VAULT) create $(VAULT_ARGS) "$(VAULT_FILE)"

vault-edit:
	@test -f "$(VAULT_FILE)" || { echo "$(VAULT_FILE) does not exist; use make vault-create" >&2; exit 1; }
	$(ANSIBLE_VAULT) edit $(VAULT_ARGS) "$(VAULT_FILE)"

vault-view:
	@test -f "$(VAULT_FILE)" || { echo "$(VAULT_FILE) does not exist; use make vault-create" >&2; exit 1; }
	@echo "Warning: this command prints decrypted secrets to the terminal." >&2
	$(ANSIBLE_VAULT) view $(VAULT_ARGS) "$(VAULT_FILE)"

secrets:
	$(ANSIBLE_PLAYBOOK) -i "$(ANSIBLE_INVENTORY)" "$(ANSIBLE_PLAYBOOK_FILE)" $(VAULT_ARGS)

terraform-init:
	$(TERRAFORM) -chdir="$(TERRAFORM_DIR)" init -backend-config=backend.hcl

terraform-init-local:
	$(TERRAFORM) -chdir="$(TERRAFORM_DIR)" init -backend=false

terraform-fmt:
	$(TERRAFORM) -chdir="$(TERRAFORM_DIR)" fmt -check -recursive

terraform-validate:
	$(TERRAFORM) -chdir="$(TERRAFORM_DIR)" validate

terraform-plan:
	$(TERRAFORM) -chdir="$(TERRAFORM_DIR)" plan

terraform-apply:
	$(TERRAFORM) -chdir="$(TERRAFORM_DIR)" apply

terraform-destroy:
	$(TERRAFORM) -chdir="$(TERRAFORM_DIR)" destroy

terraform-output:
	$(TERRAFORM) -chdir="$(TERRAFORM_DIR)" output

