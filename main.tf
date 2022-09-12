resource "random_string" "random" {
  count = var.role_name == null ? 1 : 0

  length  = 8
  lower   = true
  special = false
}

locals {
  github_environments = (length(var.github_environments) > 0 && var.repo != null) ? [for e in var.github_environments : "repo:${var.repo}:environment:${e}"] : ["ensurethereisnotmatch"]
  role_name           = (var.repo != null && var.role_name != null) ? var.role_name : "${substr(replace(var.repo != null ? var.repo : "", "/", "-"), 0, 64 - 8)}-${random_string.random[0].id}"

  variable_sub = "token.actions.githubusercontent.com:sub"

  default_allow_main = contains(var.default_conditions, "allow_main") ? [{
    test     = "StringLike"
    variable = local.variable_sub
    values   = ["repo:${var.repo}:ref:refs/heads/main"]
  }] : []

  default_allow_environment = contains(var.default_conditions, "allow_environment") ? [{
    test     = "StringLike"
    variable = local.variable_sub
    values   = local.github_environments
  }] : []

  default_allow_all = contains(var.default_conditions, "allow_all") ? [{
    test     = "StringLike"
    variable = local.variable_sub
    values   = ["repo:${var.repo}:*"]
  }] : []

  default_deny_pull_request = contains(var.default_conditions, "deny_pull_request") ? [{
    test     = "StringNotLike"
    variable = local.variable_sub
    values   = ["repo:${var.repo}:pull_request"]
  }] : []

  conditions = setunion(local.default_allow_main, local.default_allow_environment, local.default_allow_all, local.default_deny_pull_request, var.conditions)
  merge_conditions = [
    for k, v in { for c in local.conditions : "${c.test}|${c.variable}" => c... } : # group by test & variable
    {
      "test" : k,
      "values" : flatten([for index, sp in v[*].values : v[index].values if v[index].variable == v[0].variable]) # loop again to build the values inner map
    }
  ]
}

data "aws_iam_policy_document" "github_actions_assume_role_policy" {
  count = var.repo != null ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
  }
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [
        var.openid_connect_provider_arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    dynamic "condition" {
      for_each = local.merge_conditions

      content {
        test     = split("|", condition.value.test)[0]
        variable = split("|", condition.value.test)[1]
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

resource "aws_iam_role_policy_attachment" "custom" {
  count = length(var.role_policy_arns)

  role       = join("", aws_iam_role.main.*.name)
  policy_arn = var.role_policy_arns[count.index]
}
