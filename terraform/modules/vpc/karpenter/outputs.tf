output "karpenter_namespace" {
  value = kubernetes_namespace.karpenter.metadata[0].name
}

output "karpenter_role_arn" {
  value = aws_iam_role.karpenter_controller_role.arn
}