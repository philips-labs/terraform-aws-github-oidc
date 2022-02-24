resource "random_string" "random" {
  count = var.role_name == null ? 1 : 0

  length  = 8
  lower   = true
  special = false
}

locals {
  openid_connect_provider_arn = var.openid_connect_provider_arn == null ? module.oidc_provider[0].openid_connect_provider.arn : var.openid_connect_provider_arn
  github_environments         = (length(var.github_environments) > 0 && var.repo != null) ? [for e in var.github_environments : "repo:${var.repo}:environment:${e}"] : ["ensurethereisnotmatch"]
  role_name                   = (var.repo != null && var.role_name != null) ? var.role_name : "${substr(replace(var.repo != null ? var.repo : "", "/", "-"), 0, 64 - 8)}-${random_string.random[0].id}"
}

module "oidc_provider" {
  count = var.openid_connect_provider_arn == null ? 1 : 0

  source          = "./modules/provider"
  thumbprint_list = var.thumbprint_list
}

data "aws_iam_policy_document" "github_actions_assume_role_policy" {
  count = var.repo != null ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [
        local.openid_connect_provider_arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    dynamic "condition" {
      for_each = contains(var.default_conditions, "allow_main") ? ["create"] : []

      content {
        test     = "StringLike"
        variable = "token.actions.githubusercontent.com:sub"
        values   = ["repo:${var.repo}:ref:refs/heads/main"]
      }
    }

    dynamic "condition" {
      for_each = contains(var.default_conditions, "allow_environment") ? ["create"] : []

      content {
        test     = "StringLike"
        variable = "token.actions.githubusercontent.com:sub"
        values   = local.github_environments
      }
    }

    dynamic "condition" {
      for_each = contains(var.default_conditions, "allow_all") ? ["create"] : []

      content {
        test     = "StringLike"
        variable = "token.actions.githubusercontent.com:sub"
        values   = ["repo:${var.repo}:*"]
      }
    }

    dynamic "condition" {
      for_each = contains(var.default_conditions, "deny_pull_request") ? ["create"] : []

      content {
        test     = "StringNotLike"
        variable = "token.actions.githubusercontent.com:sub"
        values   = ["repo:${var.repo}:pull_request"]
      }
    }

    dynamic "condition" {
      for_each = toset(var.conditions)

      content {
        test     = condition.value.test
        variable = condition.value.variable
        values   = condition.value.values
      }
    }
  }
}

resource "aws_iam_role" "main" {
  count = var.repo != null ? 1 : 0

  name                 = local.role_name
  path                 = var.role_path
  permissions_boundary = var.role_permissions_boundary
  assume_role_policy   = data.aws_iam_policy_document.github_actions_assume_role_policy[0].json
}
