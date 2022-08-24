region       = "us-east-1"
cluster_name = "EKS-Cluster-22a"

# EKS Cluster
cluster_version = 1.23

# Autoscaling Group
spot_price       = "0.0464"
desired_capacity = 3
max_size         = 4
min_size         = 2
instance_type    = "t3.medium"                               #(for launch template)
instance_types   = ["t2.medium", "t3a.medium", "t3.medium"] # uses by the autoscaling group when creating worker nodes

# VPC
cidr_block     = "10.0.0.0/16"
public_subnet  = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
private_subnet = ["10.0.40.0/24", "10.0.50.0/24", "10.0.60.0/24"]