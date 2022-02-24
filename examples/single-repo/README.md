# Managing a single repo for a single AWS account

The module provides an example how to setup roles to to use with OIDC for one repository.

- A single repository with some access to s3
- Provided role name
- Default conditions

## Usages

Create a GitHub repository (private) and set teh variable `repo` to the name of your created repo. Add as secret `AWS_ACCOUNT_ID` and set the value to your account.

```bash
terraform init
terraform apply
```

On the console the name of the bucket and role are printed. Next update [workflow](../repositories/.github/workflows/../../repo-s3/.github/workflows/s3.yml) with the bucket name and role name. Add, commit and push the workflow to the repository. In the action build the test workflow should execute and list the objects in your bucket (by default empty).

Finally you can clean up with `terraform destroy`
