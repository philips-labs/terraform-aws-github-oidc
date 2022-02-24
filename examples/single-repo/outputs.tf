output "role" {
  value = module.oidc.role.name
}

output "s3" {
  value = {
    bucket = aws_s3_bucket.example.bucket
  }
}
