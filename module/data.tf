data "aws_iam_policy_document" "eks_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "worker_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_key_pair" "ssh-key-22a" {
  key_name           = "ssh-key-22a"
  include_public_key = true

  # filter {
  #   name   = "key_pair_id"
  #   values = ["key-06529499822be6457"]
  # }
  depends_on = [
    aws_key_pair.ssh_public_key
  ]
}

data "aws_ami" "eks-worker" { # AMI image for worker nodes
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.eks-22a.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Default Amazon EKS AMI Account ID
}