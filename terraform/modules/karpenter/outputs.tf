output "karpenter_namespace" {
  description = "Karpenter namespace"
  value       = kubernetes_namespace.karpenter.metadata[0].name
}

output "karpenter_role_arn" {
  description = "Karpenter controller IAM role ARN"
  value       = aws_iam_role.karpenter_controller_role.arn
}

output "karpenter_node_role_arn" {
  description = "Karpenter node IAM role ARN"
  value       = aws_iam_role.karpenter_node_role.arn
}
