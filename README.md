# terraform-external-dns

## HowTo

## HowTo

    module "external_dns" {
      source               = "crazy-canux/dns/external"
      version              = "0.1.0"
      txt_owner_id         = local.cluster_name
      service_account_name = local.service_account
      cluster_name         = local.cluster_name
      oidc_issuer          = local.cluster_oidc_issuer_url
      zone_fqdns           = [local.zone_fqdn]
      depends_on = [data.terraform_remote_state.eks]
    }
