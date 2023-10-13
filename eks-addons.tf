resource "aws_eks_addon" "vpc-cni" {
  cluster_name                = aws_eks_cluster.eks_cluster.name
  addon_name                  = "vpc-cni"
  addon_version               = "v1.15.0-eksbuild.2"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
  preserve                    = true

  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  addon_name    = "kube-proxy"
  addon_version = "v1.28.2-eksbuild.2"
}

resource "aws_eks_addon" "coredns" {
  depends_on           = [aws_eks_node_group.app_node_group]
  cluster_name         = aws_eks_cluster.eks_cluster.name
  addon_name           = "coredns"
  configuration_values = "{\"replicaCount\":2,\"resources\":{\"limits\":{\"memory\":\"170Mi\"},\"requests\":{\"cpu\":\"100m\",\"memory\":\"70Mi\"}}}"
  addon_version        = "v1.10.1-eksbuild.4"
}