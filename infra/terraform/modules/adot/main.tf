# ADOT (AWS Distro for OpenTelemetry) Collector for EKS

# IAM Role for ADOT Collector
resource "aws_iam_role" "adot_collector" {
  name = "${var.project_name}-${var.environment}-adot-collector"

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
            "${replace(var.eks_oidc_provider_arn, "/^(.*provider/)/", "")}:sub" = "system:serviceaccount:${var.adot_namespace}:adot-collector"
            "${replace(var.eks_oidc_provider_arn, "/^(.*provider/)/", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-adot-collector"
      Environment = var.environment
    }
  )
}

# IAM Policy for ADOT Collector
resource "aws_iam_policy" "adot_collector" {
  name        = "${var.project_name}-${var.environment}-adot-collector"
  description = "Policy for ADOT collector to send telemetry data"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets",
          "xray:GetSamplingStatisticSummaries"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "cloudwatch:namespace" = [
              "AWS/X-Ray",
              "${var.project_name}/${var.environment}",
              "ContainerInsights"
            ]
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/eks/${var.cluster_name}/adot/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVolumes",
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/aws/service/global-infrastructure/*"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "adot_collector" {
  policy_arn = aws_iam_policy.adot_collector.arn
  role       = aws_iam_role.adot_collector.name
}

# CloudWatch Log Group for ADOT
resource "aws_cloudwatch_log_group" "adot" {
  name              = "/aws/eks/${var.cluster_name}/adot"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_id

  tags = merge(
    var.tags,
    {
      Name        = "/aws/eks/${var.cluster_name}/adot"
      Environment = var.environment
    }
  )
}

# Kubernetes Namespace for ADOT
resource "kubernetes_namespace" "adot" {
  metadata {
    name = var.adot_namespace

    labels = {
      name        = var.adot_namespace
      environment = var.environment
      managed_by  = "terraform"
    }
  }
}

# Service Account for ADOT Collector
resource "kubernetes_service_account" "adot_collector" {
  metadata {
    name      = "adot-collector"
    namespace = kubernetes_namespace.adot.metadata[0].name

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.adot_collector.arn
    }

    labels = {
      app         = "adot-collector"
      environment = var.environment
    }
  }
}

# ConfigMap for ADOT Collector Configuration
resource "kubernetes_config_map" "adot_collector" {
  metadata {
    name      = "adot-collector-config"
    namespace = kubernetes_namespace.adot.metadata[0].name
  }

  data = {
    "collector.yaml" = templatefile("${path.module}/collector-config.yaml", {
      region             = data.aws_region.current.name
      cluster_name       = var.cluster_name
      project_name       = var.project_name
      environment        = var.environment
      log_group_name     = aws_cloudwatch_log_group.adot.name
      enable_prometheus  = var.enable_prometheus
      prometheus_endpoint = var.prometheus_endpoint
    })
  }
}

# Deployment for ADOT Collector
resource "kubernetes_deployment" "adot_collector" {
  metadata {
    name      = "adot-collector"
    namespace = kubernetes_namespace.adot.metadata[0].name

    labels = {
      app         = "adot-collector"
      environment = var.environment
    }
  }

  spec {
    replicas = var.collector_replicas

    selector {
      match_labels = {
        app = "adot-collector"
      }
    }

    template {
      metadata {
        labels = {
          app         = "adot-collector"
          environment = var.environment
        }
      }

      spec {
        service_account_name = kubernetes_service_account.adot_collector.metadata[0].name

        container {
          name  = "adot-collector"
          image = var.collector_image

          args = [
            "--config=/etc/collector/collector.yaml"
          ]

          resources {
            limits = {
              cpu    = var.collector_cpu_limit
              memory = var.collector_memory_limit
            }
            requests = {
              cpu    = var.collector_cpu_request
              memory = var.collector_memory_request
            }
          }

          port {
            container_port = 4317
            name           = "otlp-grpc"
            protocol       = "TCP"
          }

          port {
            container_port = 4318
            name           = "otlp-http"
            protocol       = "TCP"
          }

          port {
            container_port = 8888
            name           = "metrics"
            protocol       = "TCP"
          }

          port {
            container_port = 2000
            name           = "aws-xray"
            protocol       = "TCP"
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/collector"
          }

          env {
            name = "AWS_REGION"
            value = data.aws_region.current.name
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = "13133"
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = "13133"
            }
            initial_delay_seconds = 10
            period_seconds        = 5
          }
        }

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.adot_collector.metadata[0].name
          }
        }
      }
    }
  }
}

# Service for ADOT Collector
resource "kubernetes_service" "adot_collector" {
  metadata {
    name      = "adot-collector"
    namespace = kubernetes_namespace.adot.metadata[0].name

    labels = {
      app         = "adot-collector"
      environment = var.environment
    }
  }

  spec {
    selector = {
      app = "adot-collector"
    }

    port {
      name        = "otlp-grpc"
      port        = 4317
      target_port = 4317
      protocol    = "TCP"
    }

    port {
      name        = "otlp-http"
      port        = 4318
      target_port = 4318
      protocol    = "TCP"
    }

    port {
      name        = "aws-xray"
      port        = 2000
      target_port = 2000
      protocol    = "TCP"
    }

    port {
      name        = "metrics"
      port        = 8888
      target_port = 8888
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

# DaemonSet for Node-level metrics collection
resource "kubernetes_daemonset" "adot_node_collector" {
  count = var.enable_node_collector ? 1 : 0

  metadata {
    name      = "adot-node-collector"
    namespace = kubernetes_namespace.adot.metadata[0].name

    labels = {
      app         = "adot-node-collector"
      environment = var.environment
    }
  }

  spec {
    selector {
      match_labels = {
        app = "adot-node-collector"
      }
    }

    template {
      metadata {
        labels = {
          app         = "adot-node-collector"
          environment = var.environment
        }
      }

      spec {
        service_account_name = kubernetes_service_account.adot_collector.metadata[0].name
        host_network         = true

        container {
          name  = "adot-node-collector"
          image = var.collector_image

          args = [
            "--config=/etc/collector/node-collector.yaml"
          ]

          resources {
            limits = {
              cpu    = "200m"
              memory = "200Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "100Mi"
            }
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/collector"
          }

          volume_mount {
            name       = "hostfs"
            mount_path = "/hostfs"
            read_only  = true
          }

          env {
            name = "NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
        }

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.adot_collector.metadata[0].name
          }
        }

        volume {
          name = "hostfs"
          host_path {
            path = "/"
          }
        }
      }
    }
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}