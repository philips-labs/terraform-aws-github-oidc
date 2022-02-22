module "oidc" {
  source = "../../"

  openid_connect_provider_managed = true
  repo                            = var.repo
  role_name                       = "repo-s3"
}

resource "aws_iam_role_policy" "s3" {
  name = "s3-policy"
  role = module.oidc.role.name

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
