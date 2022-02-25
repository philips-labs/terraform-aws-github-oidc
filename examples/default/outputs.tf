output "roles" {
  value = {
    repos_s3  = module.oidc_repo_s3.role.name
    repos_ecr = module.oidc_repo_ecr.role.name
  }
}

output "ecr" {
  value = {
    repository_url = aws_ecr_repository.example.repository_url
  }
}

output "s3" {
  value = {
    bucket = aws_s3_bucket.example.bucket
  }
}
