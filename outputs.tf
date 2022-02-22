output "openid_connect_provider" {
  description = "AWS OpenID Connected identity provider."
  value       = var.openid_connect_provider_managed ? aws_iam_openid_connect_provider.github_actions[0] : null
}

output "role" {
  description = "The crated role that can be assumed for the configured repository."
  value       = var.repo != null ? aws_iam_role.main[0] : null
}
