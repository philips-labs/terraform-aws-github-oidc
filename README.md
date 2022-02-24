# Terraform module AWS OICD integration GitHub Actions

This [Terraform](https://www.terraform.io/) module manages OpenID Connect (OIDC) integration between [GitHub Actions and AWS](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services).

## Description

The module is strict on the claim checks to avoid that creating an OpenID connect integration opens your AWS account to any GitHub repo. However this strictness is not taking all the risk away. Ensure you familiarize yourself with OpenID Connect and the docs provided by GitHub and AWS. As always think about minimizing the privileges.

The module can manage the following:

- The OpenID Connect identity provider for GitHub in your AWS account.
- Manage a role and policy to check to check claims.

### Manage the OIDC identity provider

The module provides two options for creating an OpenID connect provider. The first one is for the simple case you only need to create a single role, for one repo in one AWS account. In this case you should not set the `openid_connect_provider_arn` property. The second option is using the internal `provider` module to create the OpenID Connect provider. This configuration will create the provider and output the ARN. This output can be passed to other instances of the module to setup roles for multiple repositories on the same provider.

### Manage roles for a repo

The module creates for a repo a role with a policy to check the OIDC claimes for the given repo. Be default the policy is set to only allow action running on the main branch and deny on the pull request. You can choose based on your need one (or more) of the default conditions to check. Additional a list of conditions can be provided. The assume role is only allowed when all conditions evaluates to true. The following default conditions can be set.

- `allow_main` : Allow GitHub Actions only running on the main branch.
- `allow_environment`: Allow GitHub Actions only for environments, by setting `github_environments` you can limit to a dedicated environment.
- `deny_pull_request`: Denies assuming the role for a pull request.
- `allow_all` : Allow GitHub Actions for any claim for the repository. Be careful, this allows forks as well to assume the role!


## Usages

Setup for a single repository in a single AWS account, see also the examples.

```hcl
module "oidc" {
  source = "github.com/philips-labs/terraform-aws-github-oidc?ref=<version>"

  repo      = var.repo
  role_name = "repo-s3"
}
```

Setup for multiple repositories connecting to a single AWS account, see also the examples.

```hcl
module "oidc_provider" {
  source = "github.com/philips-labs/terraform-aws-github-oidc/?ref=<version>//modules/provider"
}

module "oidc_repo_s3" {
  source = "github.com/philips-labs/terraform-aws-github-oidc?ref=<version>"

  openid_connect_provider_arn = module.oidc_provider.openid_connect_provider.arn
  repo                        = var.repo_s3
  role_name                   = "repo-s3"
}
```


## Examples

The following examples are provided:

1. [Single repository](./examples/single-repo/README.md): using the module for a single repository and managing the identity provider by the same instance.
2. [Multiple repositories](./examples/multi-repo/README.md): using the module for multiple repositories and manage the identity provider by multiple module instances.


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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_oidc_provider"></a> [oidc\_provider](#module\_oidc\_provider) | ./modules/provider | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_iam_policy_document.github_actions_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_conditions"></a> [conditions](#input\_conditions) | (Optional) Additonal conditions for checking the OIDC claim. | <pre>list(object({<br>    test     = string<br>    variable = string<br>    values   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_default_conditions"></a> [default\_conditions](#input\_default\_conditions) | (Optional) Default condtions to apply, at least one of the following is madatory: 'allow\_main', 'allow\_environment', 'deny\_pull\_request' and 'allow\_all'. | `list(string)` | <pre>[<br>  "allow_main",<br>  "deny_pull_request"<br>]</pre> | no |
| <a name="input_github_environments"></a> [github\_environments](#input\_github\_environments) | (Optional) Allow GitHub action to deploy to all (default) or to one of the environments in the list. | `list(string)` | <pre>[<br>  "*"<br>]</pre> | no |
| <a name="input_openid_connect_provider_arn"></a> [openid\_connect\_provider\_arn](#input\_openid\_connect\_provider\_arn) | Set the openid connect provider ARN when the provider is not managed by the module. | `string` | `null` | no |
| <a name="input_repo"></a> [repo](#input\_repo) | (Optional) GitHub repository to grant access to assume a role via OIDC. When the repo is set, a role will be created. | `string` | `null` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | (Optional) role name of the created role, if not provided the `namespace` will be used. | `string` | `null` | no |
| <a name="input_role_path"></a> [role\_path](#input\_role\_path) | (Optional) Path for the created role, requires `repo` is set. | `string` | `"/github-actions/"` | no |
| <a name="input_role_permissions_boundary"></a> [role\_permissions\_boundary](#input\_role\_permissions\_boundary) | (Optional) Boundary for the created role, requires `repo` is set. | `string` | `null` | no |
| <a name="input_thumbprint_list"></a> [thumbprint\_list](#input\_thumbprint\_list) | (Optional) A list of server certificate thumbprints for the OpenID Connect (OIDC) identity provider's server certificate(s). | `list(string)` | <pre>[<br>  "6938fd4d98bab03faadb97b34396831e3780aea1"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role"></a> [role](#output\_role) | The crated role that can be assumed for the configured repository. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contribution

We welcome contribution, please checkout the [contribution guide](CONTRIBUTING.md). Be-aware we use [pre commit hooks](https://pre-commit.com/) to update the docs.

## Release

Releases are create automated from the main branch using conventional commit messages.

## Contact

For question you can reach out to one of the [maintainers](./MAINTAINERS.md).
