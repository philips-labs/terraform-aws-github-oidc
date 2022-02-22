data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "github_actions" {
  count = var.manage_iam_openid_connect_provider ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = var.thumbprint_list
}

data "aws_iam_policy_document" "github_actions_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.github_actions.arn
      ]
    }
    # condition {
    #   test     = "StringNotLike"
    #   variable = "token.actions.githubusercontent.com:sub"
    #   values   = ["repo:npalm/aws-oidc-demo:pull_request"]
    # }


    # condition {
    #   test     = "StringEquals"
    #   variable = "token.actions.githubusercontent.com:workflow"
    #   values   = ["Test"]
    # }
    # "Condition": {
    #   "ForAllValues:StringEquals": {
    #     "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
    #     "token.actions.githubusercontent.com:sub": "repo:octo-org/octo-repo:ref:refs/heads/octo-branch"
    #   }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:npalm/aws-oidc-demo:*"]
    }
  }
}


resource "aws_iam_role" "deploy" {
  name               = "${var.environment}-deploy"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role_policy.json
}

resource "aws_iam_role_policy" "deploy_policy" {
  name = "deploy-policy"
  role = aws_iam_role.deploy.name

  policy = data.aws_iam_policy_document.deploy.json
}

data "aws_iam_policy_document" "deploy" {
  statement {
    sid = "1"

    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }
}

output "role" {
  value = aws_iam_role.deploy
}
