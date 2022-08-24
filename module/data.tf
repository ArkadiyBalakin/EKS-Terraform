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

data "aws_key_pair" "key-22a" {
  key_name           = "eks-node-secrets-keypair"
  include_public_key = true

  # filter {
  #   name   = "key_pair_id"
  #   values = ["key-06529499822be6457"]
  # }
}