###############        EKS Cluster       #################

resource "aws_security_group" "eks-22a" {
  name        = "${var.cluster_name}_eks"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.vpc-22a.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ControlPlaneSecurityGroup"
  }
}

resource "aws_iam_role" "eks-22a" {
  name               = "${var.cluster_name}_eks"
  assume_role_policy = data.aws_iam_policy_document.eks_role.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-22a.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-22a.name
}

resource "aws_eks_cluster" "eks-22a" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks-22a.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids         = aws_subnet.public-22a.*.id
    security_group_ids = [aws_security_group.eks-22a.id]
  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
  ]
}