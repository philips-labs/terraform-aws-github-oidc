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

variable "tags" {
  description = "(Optional) Add tags to resources."
  type        = map(string)
  default     = {}
}