variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "eu-west-1"
}

variable "repo_s3" {
  description = "GitHub repository to grant access to assume a role via OIDC."
  type        = string
}

variable "repo_ecr" {
  description = "GitHub repository to grant access to assume a role via OIDC."
  type        = string
}
