module "oidc_provider" {
  source = "../../modules/provider"
}

data "aws_caller_identity" "current" {}

module "oidc_repo_s3" {
  source = "../../"

  openid_connect_provider_arn = module.oidc_provider.openid_connect_provider.arn
  repo                        = var.repo_s3
  role_name                   = "repo-s3"
}

module "oidc_repo_ecr" {
  source = "../../"

  openid_connect_provider_arn = module.oidc_provider.openid_connect_provider.arn
  repo                        = var.repo_ecr
  default_conditions          = ["allow_environment"]
  github_environments         = ["production"]
  account_id = data.aws_caller_identity.current.account_id
}

##########################################
##
## Resources for s3 repo
##
##########################################
resource "aws_iam_role_policy" "s3" {
  name   = "s3-policy"
  role   = module.oidc_repo_s3.role.name
  policy = data.aws_iam_policy_document.s3.json
}

data "aws_iam_policy_document" "s3" {
  statement {
    sid = "1"

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]

    resources = [
      aws_s3_bucket.example.arn, "${aws_s3_bucket.example.arn}*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/allow-gh-action"

      values = ["true"]
    }
  }
}

resource "random_uuid" "main" {
}

resource "aws_s3_bucket" "example" {
  bucket = random_uuid.main.result

  tags = {
    allow-gh-action-access = "true"
  }
}

##########################################
##
## Resources for ecr repo
##
##########################################
resource "aws_iam_role_policy" "ec3" {
  name = "ec3-policy"
  role = module.oidc_repo_ecr.role.name

  policy = data.aws_iam_policy_document.ecr.json
}


data "aws_iam_policy_document" "ecr" {
  statement {
    actions = [
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]

    # Another option to lock to resources is by locking on tags
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/allow-gh-action"

      values = ["true"]
    }
  }
}

resource "aws_ecr_repository" "example" {
  name                 = "lunch-and-learn/example"
  image_tag_mutability = "IMMUTABLE"

  tags = {
    "allow-gh-action-access" = true
  }
}
