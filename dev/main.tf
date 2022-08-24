module "centos_eks_cluster" {
  source           = "../module"
  cluster_name     = var.cluster_name
  cidr_block       = var.cidr_block
  public_subnet    = var.public_subnet
  private_subnet   = var.private_subnet
  cluster_version  = var.cluster_version
  spot_price       = var.spot_price
  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size
  instance_type    = var.instance_type
  instance_types   = var.instance_types
}