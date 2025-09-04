# ArgoCD for GitOps CD

# Namespace for ArgoCD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace

    labels = {
      name        = var.argocd_namespace
      environment = var.environment
      managed_by  = "terraform"
    }
  }
}

# ArgoCD Helm Release
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    templatefile("${path.module}/values.yaml", {
      domain                = var.domain
      certificate_arn       = var.certificate_arn
      github_org            = var.github_org
      github_repo           = var.github_repo
      slack_token           = var.slack_token
      enable_dex            = var.enable_dex
      enable_notifications  = var.enable_notifications
      enable_rollouts       = var.enable_rollouts
      redis_ha              = var.redis_ha
      controller_replicas   = var.controller_replicas
      server_replicas       = var.server_replicas
      repo_server_replicas  = var.repo_server_replicas
    })
  ]

  set {
    name  = "server.service.type"
    value = var.service_type
  }

  set_sensitive {
    name  = "configs.secret.githubSecret"
    value = var.github_webhook_secret
  }

  depends_on = [kubernetes_namespace.argocd]
}

# IAM Role for ArgoCD Server (for AWS integration)
resource "aws_iam_role" "argocd_server" {
  count = var.enable_aws_integration ? 1 : 0

  name = "${var.project_name}-${var.environment}-argocd-server"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.eks_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.eks_oidc_provider_arn, "/^(.*provider/)/", "")}:sub" = "system:serviceaccount:${var.argocd_namespace}:argocd-server"
            "${replace(var.eks_oidc_provider_arn, "/^(.*provider/)/", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-argocd-server"
      Environment = var.environment
    }
  )
}

resource "aws_iam_policy" "argocd_server" {
  count = var.enable_aws_integration ? 1 : 0

  name        = "${var.project_name}-${var.environment}-argocd-server"
  description = "Policy for ArgoCD server AWS integration"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:${var.project_name}/${var.environment}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "argocd_server" {
  count = var.enable_aws_integration ? 1 : 0

  policy_arn = aws_iam_policy.argocd_server[0].arn
  role       = aws_iam_role.argocd_server[0].name
}

# Service Account for ArgoCD Server
resource "kubernetes_service_account" "argocd_server" {
  count = var.enable_aws_integration ? 1 : 0

  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace.argocd.metadata[0].name

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.argocd_server[0].arn
    }
  }
}

# ArgoCD Root Application (App of Apps pattern)
resource "kubernetes_manifest" "root_app" {
  depends_on = [helm_release.argocd]

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "root"
      namespace = var.argocd_namespace
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/${var.github_org}/${var.github_repo}"
        targetRevision = var.target_revision
        path           = var.apps_path
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.argocd_namespace
      }
      syncPolicy = {
        automated = {
          prune      = true
          selfHeal   = true
          allowEmpty = false
        }
        syncOptions = [
          "Validate=true",
          "CreateNamespace=true",
          "PrunePropagationPolicy=foreground",
          "PruneLast=true"
        ]
        retry = {
          limit = 5
          backoff = {
            duration    = "5s"
            factor      = 2
            maxDuration = "3m"
          }
        }
      }
      revisionHistoryLimit = 10
    }
  }
}

# ArgoCD Project for microservices
resource "kubernetes_manifest" "microservices_project" {
  depends_on = [helm_release.argocd]

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = "microservices"
      namespace = var.argocd_namespace
    }
    spec = {
      description = "Shopstream microservices"
      
      sourceRepos = [
        "https://github.com/${var.github_org}/*"
      ]
      
      destinations = [
        {
          namespace = "*"
          server    = "https://kubernetes.default.svc"
        }
      ]
      
      clusterResourceWhitelist = [
        {
          group = "*"
          kind  = "*"
        }
      ]
      
      namespaceResourceWhitelist = [
        {
          group = "*"
          kind  = "*"
        }
      ]
      
      roles = [
        {
          name = "admin"
          policies = [
            "p, proj:microservices:admin, applications, *, microservices/*, allow"
          ]
          groups = var.admin_groups
        },
        {
          name = "readonly"
          policies = [
            "p, proj:microservices:readonly, applications, get, microservices/*, allow"
          ]
          groups = var.readonly_groups
        }
      ]
    }
  }
}

# ConfigMap for ArgoCD repositories
resource "kubernetes_config_map" "argocd_repositories" {
  metadata {
    name      = "argocd-repositories"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    labels = {
      "app.kubernetes.io/name"    = "argocd-repositories"
      "app.kubernetes.io/part-of" = "argocd"
    }
  }

  data = {
    repositories = yamlencode([
      {
        url  = "https://github.com/${var.github_org}/${var.github_repo}"
        type = "git"
        name = var.github_repo
      }
    ])
  }
}

# ArgoCD Ingress
resource "kubernetes_ingress_v1" "argocd" {
  count = var.create_ingress ? 1 : 0

  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    
    annotations = {
      "kubernetes.io/ingress.class"                    = "alb"
      "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"          = "ip"
      "alb.ingress.kubernetes.io/certificate-arn"      = var.certificate_arn
      "alb.ingress.kubernetes.io/listen-ports"         = jsonencode([{ HTTPS = 443 }])
      "alb.ingress.kubernetes.io/ssl-redirect"         = "443"
      "alb.ingress.kubernetes.io/backend-protocol"     = "HTTPS"
      "alb.ingress.kubernetes.io/healthcheck-path"     = "/healthz"
      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTPS"
    }
  }

  spec {
    rule {
      host = "argocd.${var.domain}"
      
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          
          backend {
            service {
              name = "argocd-server"
              port {
                number = 443
              }
            }
          }
        }
      }
    }
  }
}

# Secret for GitHub webhook
resource "kubernetes_secret" "github_webhook" {
  metadata {
    name      = "argocd-github-webhook"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  data = {
    secret = var.github_webhook_secret
  }

  type = "Opaque"
}