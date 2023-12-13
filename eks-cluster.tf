data "aws_iam_policy_document" "AmazonEKSClusterAssumeRolePolicy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "AmazonEKSClusterRole" {
  name               = "${var.project_name}-${var.env}-AmazonEKSClusterRole"
  assume_role_policy = data.aws_iam_policy_document.AmazonEKSClusterAssumeRolePolicy.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.iam_role_eks.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.iam_role_eks.name
}

# resource "aws_security_group_rule" "culster_sg_ingress" {
#   type                     = "ingress"
#   from_port                = 0
#   to_port                  = 0
#   protocol                 = "-1"
#   source_security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
#   security_group_id        = aws_security_group.cluster_sg.id
# }

# resource "aws_security_group_rule" "culster_sg_egress" {
#   type              = "egress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.cluster_sg.id
# }

resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.project_name}-${var.env}"
  role_arn = aws_iam_role.AmazonEKSClusterRole.arn

  # TODO: Enabling Control Plane Logging
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster#enabling-control-plane-logging
  # https://catalog.us-east-1.prod.workshops.aws/workshops/afee4679-89af-408b-8108-44f5b1065cc7/en-US/500-eks-terraform-workshop/560-cluster/tf-files#aws_eks_cluster__cluster.tf

  version = var.eks_version

  vpc_config {
    # endpoint_private_access = true
    # endpoint_public_access  = true
    # public_access_cidrs     = var.eks_public_access_cidrs
    # security_group_ids = [aws_security_group.cluster_sg.id]
    subnet_ids = [aws_subnet.private_subnet_01.id, aws_subnet.private_subnet_02.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
  ]
}
