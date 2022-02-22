variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "eu-west-1"
}

variable "repo" {
  description = "GitHub repository to grant access to assume a role via OIDC."
  type        = string
}
