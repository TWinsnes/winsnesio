deploy:
	terraform plan \
	-var 'service_account=$(shell cat .creds/gcp-sa-key.json | jq .client_email)' \
	-var 'google_project=$(shell cat .creds/gcp-sa-key.json | jq .project_id)' \
	-var 'root_domain=winsnes.io' \
	-var 'sub_domain=www' \
	-out plan.out
	terraform apply -auto-approve plan.out
	
tfinit:
	terraform init \
	--backend-config="path=.tfstate/terraform.tfstate"
	
