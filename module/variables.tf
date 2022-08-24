# VPC
variable "cidr_block" {
  type        = string
  #default     = "10.0.0.0/16"
  description = "cidr block for the VPC"
}
variable "private_subnet" {
  type        = list(any)
  #default     = ["10.0.40.0/24", "10.0.50.0/24", "10.0.60.0/24"]
  description = "private subnets cidr blocks"
}
variable "public_subnet" {
  type        = list(any)
  #default     = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  description = "public subnets cidr blocks"
}

# EKS Cluster
variable "cluster_name" {
  type        = string
  #default     = "EKS_Cluster_22a"
  description = "Name of the cluster"
}
variable "cluster_version" {
  type        = string
  #default     = "1.23"
  description = "EKS cluster version"
}

# Worker Nodes
variable "spot_price" {
  type        = string
  #default     = "0.0464"
  description = "maximum price for the spot instances"
}
variable "desired_capacity" {
  type        = string
  #default     = "3"
  description = "Desired number of worker nodes"
}
variable "max_size" {
  type        = string
  #default     = "4"
  description = "maximum size of worker nodes"
}
variable "min_size" {
  type        = string
  #default     = "2"
  description = "minumum size of worker nodes"
}
variable "instance_type" {
  type        = string
  #default     = "t2.medium"
  description = "Launch templates instance type"
}
variable "instance_types" {
  type        = list(any)
  #default     = ["t2.medium", "t3a.medium", "t3.medium"]
  description = "Instance types for the Autoscaling Group"
}