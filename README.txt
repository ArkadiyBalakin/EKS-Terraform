EKS TERRAFORM:

/module - contains terraform files to create VPC components, SSH key, EKS cluster with worker nodes

/backend - contains terraform files to create S3 bucket

/dev - contains terraform main files

- Makefile - to reduce the steps for the terraform commands

Resources used during the project:

- https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs

INSTRUCTION FOR MAKEFILE:

- make tfstate - Creates S3 remote backend with Dynamodb table for state lock

- make plan - init initialize a working directory containing Terraform configuration files. The terraform plan command creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure

- make apply - create: VPC, SSH key, EKS cluster with worker nodes and attach the workers to the master node

USAGE:

make tfstate
- This command will cd into backend folder and run terraform init & terraform plan & terraform apply.
-- Create S3 as a remote backend with versioning enabled
-- Create Dynamodb table for lock tf.state file

make plan
- This command will cd into production file and run terraform init $ terraform plan. Initialize provider and will plan to create resources in AWS

make apply
- Create VPC and components
-- VPC with 10.0.0.0/16 cidr block
-- Internet Gateway
-- Public subnets "10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"
-- Private subnets "10.0.40.0/24", "10.0.50.0/24", "10.0.60.0/24"
-- Route tables
-- Route table association

- EKS Cluster
-- Security Group for Control Plane (EKS Master)
-- IAM Role Master Node with next policies attached
--- AmazonEKSClusterPolicy
--- AmazonEKSServicePolicy
-- EKS

- Worker Nodes
-- IAM Role for the Worker Nodes with next policies attached
--- AmazonEKSWorkerNodePolicy
--- AmazonEKS_CNI_Policy
--- AmazonEC2ContainerRegistryReadOnly
-- Security Group for the Worker Nodes
-- Launch template
-- Autoscaling Group with mixed On-Demand-25% & Spot-75% instances

NOTES:

- In this project for the variables i used .tfvars instead of regular variables. But regular variable file also provided with default parameters. If .tfvars file has not been passed when running the apply command, default values from variables.tf file can be applied

CLEAN-UP:

- make rm-tfstate - delete everything that was created in backend

- make destroy - delete everything that was created in apply
