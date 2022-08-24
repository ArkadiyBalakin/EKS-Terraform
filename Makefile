name = EKS-Cluster-22a
region = "us-east-1"

tfstate:
	cd backend && terraform init && terraform plan && terraform apply

plan: 
	cd dev && terraform init && terraform plan

apply:
	cd dev && terraform apply
	aws eks --region $(region) update-kubeconfig --name $(name)
	kubectl apply -f configmap_aws_auth.yaml
	kubectl apply -f ingress-nginx.yaml

#Clean-up
rm-eks:
	cd dev && terraform destroy

rm-backend:
	cd backend && terraform init && terraform destroy -auto-approve