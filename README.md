# Terraform module AWS OIDC integration GitHub Actions

This [Terraform](https://www.terraform.io/) module manages OpenID Connect (OIDC) integration between [GitHub Actions and AWS](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services).

## Description

The module is strict on the claim checks to avoid that creating an OpenID connect integration opens your AWS account to any GitHub repo. However this strictness is not taking all the risk away. Ensure you familiarize yourself with OpenID Connect and the docs provided by GitHub and AWS. As always think about minimizing the privileges.

The module can manage the following:

- The OpenID Connect identity provider for GitHub in your AWS account (via a submodule).
- A role and assume role policy to check to check OIDC claims.

### Manage the OIDC identity provider

The module provides an option for creating an OpenID connect provider. Using the internal `provider` module to create the OpenID Connect provider. This configuration will create the provider and output the ARN. This output can be passed to other instances of the module to setup roles for repositories on the same provider. Alternative you can create the OpenID connect provider via the resource [aws_iam_openid_connect_provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) or in case you have an existing one look-up via the data source [aws_iam_openid_connect_provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_openid_connect_provider).

### Manage roles for a repo

The module creates a role with an assume role policy to check the OIDC claims for the given repo. Be default the policy is set to only allow actions running on the main branch and deny pull request actions. You can choose based on your need one (or more) of the default conditions to check. Additionally, a list of conditions can be provided. The role can only be assumed when all conditions evaluate to true. The following default conditions can be set.

- `allow_main` : Allow GitHub Actions only running on the main branch.
- `allow_environment`: Allow GitHub Actions only for environments, by setting `github_environments` you can limit to a dedicated environment.
- `deny_pull_request`: Denies assuming the role for a pull request.
- `allow_all` : Allow GitHub Actions for any claim for the repository. Be careful, this allows forks as well to assume the role!

## Required GitHub Workflows Permissions

When configuring GitHub workflows to use this module, you need to specify the following permissions in your workflow configuration:

```yaml
permissions:
  id-token: write
```

This permission is required for the GitHub Actions to be able to assume the IAM role created by this module.

## Usages

In case there is not OpenID Connect provider already created in the AWS account, create one via the submodule.

```hcl
module "oidc_provider" {
  source = "github.com/philips-labs/terraform-aws-github-oidc?ref=<version>//modules/provider"
}
```

Next, you can pass the output the one or multiple instances of the module.

```hcl
module "oidc_repo_s3" {
  source = "github.com/philips-labs/terraform-aws-github-oidc?ref=<version>"

  openid_connect_provider_arn = module.oidc_provider.openid_connect_provider.arn
  repo                        = var.repo_s3
  role_name                   = "repo-s3"

  # optional
  # override default conditions
  default_conditions          = ["allow_main"]

  # add extra conditions, will be merged with the default_conditions
  conditions                  = [{
    test = "StringLike"
    variable = "token.actions.githubusercontent.com:sub"
    values = ["repo:my-org/my-repo:pull_request"]
  }]
}
```

## Examples

Check out the [example](examples/default/README.md) for a full example of using the module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_iam_policy_document.github_actions_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_ids"></a> [account\_ids](#input\_account\_ids) | Root users of these Accounts (id) would be given the permissions to assume the role created by this module. | `list(string)` | `[]` | no |
| <a name="input_conditions"></a> [conditions](#input\_conditions) | (Optional) Additional conditions for checking the OIDC claim. | <pre>list(object({<br>    test     = string<br>    variable = string<br>    values   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_custom_principal_arns"></a> [custom\_principal\_arns](#input\_custom\_principal\_arns) | List of IAM principals ARNs able to assume the role created by this module. | `list(string)` | `[]` | no |
| <a name="input_default_conditions"></a> [default\_conditions](#input\_default\_conditions) | (Optional) Default conditions to apply, at least one of the following is mandatory: 'allow\_main', 'allow\_environment', 'deny\_pull\_request' and 'allow\_all'. | `list(string)` | <pre>[<br>  "allow_main",<br>  "deny_pull_request"<br>]</pre> | no |
| <a name="input_github_environments"></a> [github\_environments](#input\_github\_environments) | (Optional) Allow GitHub action to deploy to all (default) or to one of the environments in the list. | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| <a name="input_github_oidc_issuer"></a> [github\_oidc\_issuer](#input\_github\_oidc\_issuer) | OIDC issuer for GitHub Actions | `string` | `"token.actions.githubusercontent.com"` | no |
| <a name="input_openid_connect_provider_arn"></a> [openid\_connect\_provider\_arn](#input\_openid\_connect\_provider\_arn) | Set the openid connect provider ARN when the provider is not managed by the module. | `string` | n/a | yes |
| <a name="input_repo"></a> [repo](#input\_repo) | (Optional) GitHub repository to grant access to assume a role via OIDC. When the repo is set, a role will be created. | `string` | `null` | no |
| <a name="input_role_max_session_duration"></a> [role\_max\_session\_duration](#input\_role\_max\_session\_duration) | Maximum session duration (in seconds) that you want to set for the specified role. | `number` | `null` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | (Optional) role name of the created role, if not provided the `namespace` will be used. | `string` | `null` | no |
| <a name="input_role_path"></a> [role\_path](#input\_role\_path) | (Optional) Path for the created role, requires `repo` is set. | `string` | `"/github-actions/"` | no |
| <a name="input_role_permissions_boundary"></a> [role\_permissions\_boundary](#input\_role\_permissions\_boundary) | (Optional) Boundary for the created role, requires `repo` is set. | `string` | `null` | no |
| <a name="input_role_policy_arns"></a> [role\_policy\_arns](#input\_role\_policy\_arns) | List of ARNs of IAM policies to attach to IAM role | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to OIDC identity provider. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_conditions"></a> [conditions](#output\_conditions) | The assume conditions added to the role. |
| <a name="output_role"></a> [role](#output\_role) | The crated role that can be assumed for the configured repository. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contribution

We welcome contribution, please checkout the [contribution guide](CONTRIBUTING.md). Be-aware we use [pre commit hooks](https://pre-commit.com/) to update the docs.

## Release

Releases are create automated from the main branch using conventional commit messages.

## Contact

For question you can reach out to one of the [maintainers](./MAINTAINERS.md).
