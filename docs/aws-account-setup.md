# AWS Account Setup (do this before Module 1)

## Account hygiene

1. **Use a personal account separate from any work account.** If you ruin it with charges, you ruin only yours.
2. **Enable MFA on the root user.** Then never use the root user again.
3. **Create an IAM user `bootcamp-admin`** with `AdministratorAccess` policy. (Not best practice in production; fine here.)
4. **Generate an access key for `bootcamp-admin`** and store it via `aws configure --profile bootcamp`.

## Billing protections (mandatory)

1. **Enable IAM access to billing**: root user → Account → "IAM user and role access to Billing information" → Activate.
2. **Set a $5 monthly budget** with email alerts at 50% and 100% spend. Billing → Budgets → Create budget.
3. **Enable Cost Anomaly Detection** (free): Billing → Cost Anomaly Detection → Get started.

## CLI

```sh
aws --version          # need v2
aws configure --profile bootcamp
# AWS Access Key ID: <paste>
# AWS Secret Access Key: <paste>
# Default region name: us-east-1   (cheapest + most services)
# Default output format: json

aws sts get-caller-identity --profile bootcamp
```

Add to your shell rc:

```sh
export AWS_PROFILE=bootcamp
export AWS_REGION=us-east-1
```

## What you should NOT do

- Do not paste keys into Git. `.gitignore` already excludes `.envrc`, `*.tfvars`, `.aws/`.
- Do not click around in the console to create resources we'll later import to Terraform. (You may use the console to *read* state.)
- Do not delete the root account or change its email. Future-you will need it.
