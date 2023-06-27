# Terraform (sub) module to crate an OpenID Connect provider for GitHub

## Description

The module creates a OpenID Connect provider for GitHub. See for directions the [README](../../README.md) on top-level. See the [example](../../examples/default/README.md) for how to use the sub module.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_thumbprint_list"></a> [thumbprint\_list](#input\_thumbprint\_list) | (Optional) A list of server certificate thumbprints for the OpenID Connect (OIDC) identity provider's server certificate(s). | `list(string)` | <pre>[<br>  "6938fd4d98bab03faadb97b34396831e3780aea1",<br>  "1c58a3a8518e8759bf075b76b750d4f2df264fcd"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_openid_connect_provider"></a> [openid\_connect\_provider](#output\_openid\_connect\_provider) | AWS OpenID Connected identity provider. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
