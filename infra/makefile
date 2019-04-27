deploy:
	terraform plan \
	-var 'service_account=$(shell cat .creds/gcp-sa-key.json | jq .client_email)' \
	-var 'google_project=$(shell cat .creds/gcp-sa-key.json | jq .project_id)' \
	-out plan.out
	terraform apply -auto-approve plan.out
	