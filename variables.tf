variable "chart_repo_url" {
  description = "URL to repository containing the external-dns helm chart"
  type        = string
  default     = "https://kubernetes-sigs.github.io/external-dns/"
}

variable "cluster_name" {
  type = string
  description = "k8s cluster name"
}

variable "oidc_issuer" {
  type = string
  description = "OIDC provider, leave in blank for EKS clusters"
  default     = ""
}

variable "zone_fqdns" {
  description = "Hosted zone fqdns"
  type        = list(string)
}

variable "namespace_name" {
  description = "Name for external-dns namespace to be created by the module"
  type        = string
  default     = "external-dns"
}

variable "txt_owner_id" {
  description = "TXT registry identifier."
  type        = string
}

variable "extra_domain_filters" {
  description = "List of domain filters to limit possible target zones by domain suffixes. The zone_fqdn value is included by default."
  type        = list(string)
  default     = []
}

variable "service_account_name" {
  description = "Service account name"
  type        = string
}

variable "helm_values" {
  description = "Values for external-dns Helm chart in raw YAML."
  type        = list(string)
  default     = []
}

variable "extra_set_values" {
  description = "Specific values to override in the external-dns Helm chart (overrides corresponding values in the helm-value.yaml file within the module)"
  type = list(object({
    name  = string
    value = any
    type  = string
    })
  )
  default = []
}
