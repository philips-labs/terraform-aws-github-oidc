variable "conditions" {
  description = "(Optional) Additonal conditions for checking the OIDC claim."
  type = list(object({
    test     = string
    variable = string
    values   = list(string)
  }))
  default = []
}

variable "default_conditions" {
  description = "(Optional) Default condtions to apply, at least one of the following is madatory: 'allow_main', 'allow_environment', 'deny_pull_request' and 'allow_all'."
  type        = list(string)
  default     = ["allow_main", "deny_pull_request"]
  validation {
    condition     = length(setsubtract(var.default_conditions, ["allow_main", "allow_environment", "deny_pull_request", "allow_all"])) == 0
    error_message = "Valid configurations are: 'allow_main', 'allow_environment', 'deny_pull_request' and 'allow_all'."
  }
}

variable "github_environments" {
  description = "(Optional) Allow GitHub action to deploy to all (default) or to one of the environments in the list."
  type        = list(string)
  default     = ["*"]
}

variable "openid_connect_provider_arn" {
  description = "(Optional) Set the openid connect provider ARN when the provider is not managed by the module."
  type        = string
  default     = null
}

variable "openid_connect_provider_managed" {
  description = "(Optional) Let the module manage the openid connect provider. "
  type        = bool
  default     = false
}

variable "repo" {
  description = "(Optional) GitHub repository to grant access to assume a role via OIDC. When the repo is set, a role will be created."
  type        = string
  default     = null
  validation {
    condition     = var.repo == null || can(regex("^.+\\/.+", var.repo))
    error_message = "Repo name is not matching the pattern <owner>/<repo>."
  }
  validation {
    condition     = var.repo == null || !can(regex("^.*\\*.*$", var.repo))
    error_message = "Wildcards are not allowed."
  }
}

variable "role_name" {
  description = "(Optional) role name of the created role, if not provided the `namespace` will be used."
  type        = string
  default     = null
}

variable "role_path" {
  description = "(Optional) Path for the created role, requires `repo` is set."
  type        = string
  default     = "/github-actions/"
}

variable "role_permissions_boundary" {
  description = "(Optional) Boundary for the created role, requires `repo` is set."
  type        = string
  default     = null
}

variable "thumbprint_list" {
  description = "(Optional) A list of server certificate thumbprints for the OpenID Connect (OIDC) identity provider's server certificate(s)."
  type        = list(string)
  default     = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}
