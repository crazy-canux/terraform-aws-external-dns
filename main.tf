locals {
  oidc_provider = trimprefix(var.oidc_issuer, "https://")
  zone_ids      = [for zone in data.aws_route53_zone.hosted_zones : zone.zone_id]
}

data "aws_route53_zone" "hosted_zones" {
  for_each = toset(var.zone_fqdns)
  name         = "${each.value}."
  private_zone = true
}

data "aws_caller_identity" "current" {}

##############################
# resource/module
##############################
resource "kubernetes_namespace" "edns_namespace" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "external-dns" {
  name       = "external-dns"
  repository = var.chart_repo_url
  version = var.chart_version
  chart      = "external-dns"
  namespace  = var.namespace
  values     = var.helm_values 

  set {
    name  = "txtOwnerId"
    value = var.txt_owner_id
  }

  set {
    name  = "serviceAccount.name"
    value = var.service_account
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external-dns-role.arn
  }

    set {
    name  = "image.repository"
    value = var.image_repo
  }
  set {
    name  = "image.tag"
    value = var.image_tag
  }

  dynamic "set" {
    for_each = var.extra_set_values
    content {
      name  = set.value.name
      value = set.value.value
      type  = set.value.type
    }
  }

  dynamic "set" {
    for_each = concat(var.extra_domain_filters, var.zone_fqdns)
    content {
      name  = "domainFilters.${set.key}"
      value = set.value
    }
  }
  depends_on = [
    aws_iam_role.external-dns-role,
    kubernetes_namespace.edns_namespace
  ]
}