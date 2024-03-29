name = EKS-Cluster-22a
region = "us-east-1"

#Create
tfstate:
	cd backend && terraform init && terraform plan && terraform apply

plan: 
	cd dev && terraform init && terraform plan -var-file="dev.tfvars"

apply:
	cd dev && terraform apply -var-file="dev.tfvars"
	aws eks --region $(region) update-kubeconfig --name $(name)
	kubectl apply -f configmap_aws_auth.yaml
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.3.0/deploy/static/provider/aws/deploy.yaml
	kubectl -n ingress-nginx patch service ingress-nginx-controller -p '{"spec":{"externalTrafficPolicy":"Cluster"}}' service/ingress-nginx-controller patched

#Clean-up
rm-eks:
	cd dev && terraform destroy -var-file="dev.tfvars"

rm-backend:
	cd backend && terraform init && terraform destroy -auto-approve