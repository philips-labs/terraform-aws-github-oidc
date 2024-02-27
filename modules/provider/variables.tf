##
## Thumbprint published by GitHub https://github.blog/changelog/2022-01-13-github-actions-update-on-oidc-based-deployments-to-aws/
## can also be generated with the script in ./bin/generate-thumbprint.sh
##
variable "thumbprint_list" {
  description = "(Optional) A list of server certificate thumbprints for the OpenID Connect (OIDC) identity provider's server certificate(s)."
  type        = list(string)
  default = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]
}

variable "tags" {
  description = "(Optional) Map of resource tags for the IAM OIDC provider. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  type        = map(string)
}
