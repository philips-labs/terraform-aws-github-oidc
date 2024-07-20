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
  validation {
    condition     = length(var.default_conditions) > 0
    error_message = "At least one of the following configuration needs to be set: 'allow_main', 'allow_environment', 'deny_pull_request' and 'allow_all'."
  }
}

variable "github_environments" {
  description = "(Optional) Allow GitHub action to deploy to all (default) or to one of the environments in the list."
  type        = list(string)
  default     = ["*"]
}

variable "openid_connect_provider_arn" {
  description = "Set the openid connect provider ARN when the provider is not managed by the module."
  type        = string
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

variable "repo_mainline_branch" {
  description = "(Optional) Mainline branch of the GitHub repository, defaults to 'main'. This will be the main/default branch that `allow_main` provides access to."
  type        = string
  default     = "main"
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

variable "role_policy_arns" {
  description = "List of ARNs of IAM policies to attach to IAM role"
  type        = list(string)
  default     = []
}

variable "role_max_session_duration" {
  description = "Maximum session duration (in seconds) that you want to set for the specified role."
  type        = number
  default     = null
}

variable "account_ids" {
  description = "Root users of these Accounts (id) would be given the permissions to assume the role created by this module."
  type        = list(string)
  default     = []
}

variable "custom_principal_arns" {
  description = "List of IAM principals ARNs able to assume the role created by this module."
  type        = list(string)
  default     = []
}

variable "github_oidc_issuer" {
  description = "OIDC issuer for GitHub Actions"
  type        = string
  default     = "token.actions.githubusercontent.com"
}
