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

# Karpenter RBAC ClusterRole
resource "kubernetes_cluster_role" "karpenter" {
  metadata {
    name = "karpenter"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes", "namespaces", "pods", "pods/logs"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/eviction"]
    verbs      = ["create"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "statefulsets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["karpenter.sh"]
    resources  = ["nodepools", "nodeclaims", "nodeclaims/status"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "karpenter" {
  metadata {
    name = "karpenter"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.karpenter.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.karpenter.metadata[0].name
    namespace = kubernetes_namespace.karpenter.metadata[0].name
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

  depends_on = [kubernetes_namespace.karpenter, kubernetes_service_account.karpenter]
}

# EC2NodeClass for Karpenter
resource "kubernetes_manifest" "karpenter_ec2_node_class" {
  manifest = {
    apiVersion = "karpenter.sh/v1beta1"
    kind       = "EC2NodeClass"
    metadata = {
      name      = "default"
      namespace = kubernetes_namespace.karpenter.metadata[0].name
    }
    spec = {
      amiFamily = "AL2"
      role      = "KarpenterNodeRole-${var.cluster_name}"
      subnetSelector = {
        "karpenter.sh/discovery" = var.cluster_name
      }
      securityGroupSelector = {
        "karpenter.sh/discovery" = var.cluster_name
      }
    }
  }

  depends_on = [kubernetes_deployment.karpenter]
}

# NodePool for Karpenter
resource "kubernetes_manifest" "karpenter_node_pool" {
  manifest = {
    apiVersion = "karpenter.sh/v1beta1"
    kind       = "NodePool"
    metadata = {
      name      = "default"
      namespace = kubernetes_namespace.karpenter.metadata[0].name
    }
    spec = {
      template = {
        metadata = {
          labels = {
            "managed-by" = "karpenter"
          }
        }
        spec = {
          nodeClassRef = {
            name = "default"
          }
          requirements = [
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values   = ["on-demand"]
            },
            {
              key      = "kubernetes.io/arch"
              operator = "In"
              values   = ["amd64"]
            },
            {
              key      = "node.kubernetes.io/instance-type"
              operator = "In"
              values   = ["t3.medium", "t3.large"]
            }
          ]
        }
      }
      limits = {
        resources = {
          cpu    = "10"
          memory = "100Gi"
        }
      }
      consolidationPolicy = {
        nodes = "when-underutilized"
      }
      ttlSecondsAfterEmpty = 30
    }
  }

  depends_on = [kubernetes_manifest.karpenter_ec2_node_class]
}
