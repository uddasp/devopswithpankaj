# Karpenter Namespace
resource "kubernetes_namespace" "karpenter" {
  metadata {
    name = "karpenter"
  }
}

# Karpenter Service Account
resource "kubernetes_service_account" "karpenter" {
  metadata {
    name      = "karpenter"
    namespace = kubernetes_namespace.karpenter.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.karpenter_controller_role.arn
    }
  }
}

# Karpenter Deployment
resource "kubernetes_deployment" "karpenter" {
  metadata {
    name      = "karpenter"
    namespace = kubernetes_namespace.karpenter.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "karpenter"
      }
    }

    template {
      metadata {
        labels = {
          app = "karpenter"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.karpenter.metadata[0].name

        container {
          name  = "karpenter"
          image = "public.ecr.aws/karpenter/karpenter:v0.33.0"

          ports {
            container_port = 8080
            name           = "http"
          }

          env {
            name  = "KARPENTER_NAMESPACE"
            value = kubernetes_namespace.karpenter.metadata[0].name
          }

          env {
            name  = "KARPENTER_CLUSTER_NAME"
            value = var.cluster_name
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.karpenter]
}

# Karpenter Provisioner
resource "kubernetes_manifest" "karpenter_provisioner" {
  manifest = yamldecode(templatefile("${path.module}/provisioner.yaml", {
    node_role_arn = var.node_role_arn
    subnet_ids    = join(",", var.subnet_ids)
    vpc_id        = var.vpc_id
  }))

  depends_on = [kubernetes_deployment.karpenter]
}