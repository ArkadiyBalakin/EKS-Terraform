###############        Worker IAM Role        #################

resource "aws_iam_role" "worker-22a" {
  name               = "${var.cluster_name}_worker"
  assume_role_policy = data.aws_iam_policy_document.worker_role.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker-22a.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker-22a.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker-22a.name
}

resource "aws_iam_instance_profile" "worker-22a" {
  name = "${var.cluster_name}_worker"
  role = aws_iam_role.worker-22a.name
}

###############        Worker Security Group        #################

#This security group controls networking access to the Kubernetes worker nodes.

resource "aws_security_group" "worker-22a" {
  name        = "${var.cluster_name}_worker_nodes"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.vpc-22a.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                        = "${var.cluster_name}_worker_sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.worker-22a.id
  source_security_group_id = aws_security_group.worker-22a.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress-cluster-https" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker-22a.id
  source_security_group_id = aws_security_group.eks-22a.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress-cluster-https-31000" {
  description              = "Allow communication to worker with internet"
  from_port                = 31000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker-22a.id
  cidr_blocks              = ["0.0.0.0/0"]
  to_port                  = 31000
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress-cluster-https-80" {
  description              = "Allow communication to worker with internet"
  from_port                = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker-22a.id
  cidr_blocks              = ["0.0.0.0/0"]
  to_port                  = 80
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress-cluster-https-22" {
  description              = "Allow SSH to worker"
  from_port                = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker-22a.id
  cidr_blocks              = ["0.0.0.0/0"]
  to_port                  = 22
  type                     = "ingress"
}

resource "aws_security_group_rule" "ingress-cluster-others" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker-22a.id
  source_security_group_id = aws_security_group.eks-22a.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks-22a.id
  source_security_group_id = aws_security_group.worker-22a.id
  to_port                  = 443
  type                     = "ingress"
}

###############        Worker Nodes        #################
locals {
  node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks-22a.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks-22a.certificate_authority.0.data}' '${var.cluster_name}'
USERDATA
}

resource "aws_launch_template" "worker-22a" {
  iam_instance_profile {
    name = aws_iam_instance_profile.worker-22a.name
  }
  image_id               = data.aws_ami.eks-worker.id
  instance_type          = var.instance_type
  key_name               = data.aws_key_pair.ssh-key-22a.key_name
  name_prefix            = var.cluster_name
  vpc_security_group_ids = [aws_security_group.worker-22a.id]
  user_data              = base64encode(local.node-userdata)

  lifecycle {
    create_before_destroy = true
  }
   block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.volume_size
    }
  }
}

resource "aws_autoscaling_group" "workers-22a" {
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  name                = "${var.cluster_name}_AG"
  vpc_zone_identifier = aws_subnet.public-22a.*.id #A list of subnet IDs to launch resources in.

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 25 # this means everything else will be 75% spot and 25% onDemand (we have fixed capacity of 1 onDemand)
      spot_allocation_strategy                 = "lowest-price"
      spot_max_price                           = var.spot_price
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.worker-22a.id
      }

      override {
        instance_type = var.instance_types[0]
      }
      override {
        instance_type = var.instance_types[1]
      }
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}_worker_node"
    propagate_at_launch = true
  }
  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}-auto-scaler"
    value               = "owned"
    propagate_at_launch = true
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "TRUE"
    propagate_at_launch = true
  }
}