# Managing multiple repo's for a single AWS account

The module provides an example how to setup roles to to use with OIDC for multiple repositories.

- A repository with some access to S3 (same as in the [single example](../single-repo/README.md))
- A repository with access to ECR with the tag `allow-gh-action-access`
- Environment for ECR repo (requires a paid GitHub subscription)

## Usages

Create a GitHub repositories (private) for S3 and ECR and set the variable `repo` to the name of your created repo. Add as secret `AWS_ACCOUNT_ID` and set the value to your account.

```bash
terraform init
terraform apply
```

For the S3 repository follow the directions in the single example. On the console the name of the ECR repo and role are printed. Next update [workflow](../repositories/.github/workflows/../../repo-ecr/.github/workflows/ecr.yml) for the repo and role. Add, commit and push. The job should now push a busybox container to your ECR repo.

Finally you can clean up with `terraform destroy`
