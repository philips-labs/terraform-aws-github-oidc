##
## Thumbprint published by GitHub https://github.blog/changelog/2022-01-13-github-actions-update-on-oidc-based-deployments-to-aws/
## can also be generated with the script in ./bin/generate-thumbprint.sh
##
variable "thumbprint_list" {
  description = "(Optional) A list of server certificate thumbprints for the OpenID Connect (OIDC) identity provider's server certificate(s)."
  type        = list(string)
  default     = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

variable "tags" {
  description = "(Optional) Add tags to resources."
  type        = map(string)
  default     = {}
}