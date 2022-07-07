locals {
  oidc_provider = trimprefix(var.oidc_issuer, "https://")
}

data "aws_iam_policy_document" "irsa-trust-policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_provider}"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:sub"
      values = [
        "system:serviceaccount:${var.namespace_name}:${var.service_account_name}"
      ]
    }
  }
}

data "aws_iam_policy_document" "route53-policy-document" {
  /*
  This role is to be assumed by the pod  via IRSA
  when the r53 zone is co-located in the same LZ account.
  */
  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets"
    ]
    resources = [for zone_id in local.zone_ids :
      "arn:aws:route53:::hostedzone/${zone_id}"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
    ]
    resources = [
      "*"
    ]
  }
}

# create role to be used by external-dns pods
resource "aws_iam_role" "external-dns-role" {
  name        = "Proj-k8s-${var.cluster_name}-external-dns"
  description = "Role to enable external-dns/route53 via IRSA"
  permissions_boundary = "arn:aws:iam::aws:policy/PowerUserAccess"
  assume_role_policy = data.aws_iam_policy_document.irsa-trust-policy.json
}

resource "aws_iam_policy" "external-dns-policy" {
  name        = "Proj-k8s-${var.cluster_name}-external-dns-policy"
  description = "Policy for external-dns/route53"
  policy      = data.aws_iam_policy_document.route53-policy-document.json
}

resource "aws_iam_policy_attachment" "external-dns-policy-attach" {
  name       = "external-dns-pod-attachment"
  roles      = [aws_iam_role.external-dns-role.name]
  policy_arn = aws_iam_policy.external-dns-policy.arn
}
