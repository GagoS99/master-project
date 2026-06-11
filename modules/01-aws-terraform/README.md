# Module 1 — AWS Foundations + Terraform

**Time:** ~1 week (10-15 hours)
**Free-tier risk:** Low. Most resources are free; surprises come from forgetting to destroy.
**Working dir:** `infra/terraform/`

## Why this module exists

You will provision a small AWS footprint by hand-written Terraform. Not via a UI, not via someone's giant module. You will know exactly what every resource is and why.

## Learning objectives

1. Configure the AWS CLI and Terraform provider with a named profile.
2. Understand Terraform's plan → apply → state model. Read state. Read plan output critically.
3. Set up a remote state backend (S3 + DynamoDB lock). Migrate from local state to remote.
4. Build a minimal VPC: one VPC, one public subnet, one Internet Gateway, one route table.
5. Launch one t3.micro EC2 instance in the subnet with a security group permitting SSH from your IP only.
6. Attach an IAM instance profile so the instance can read from S3 (you'll use this in Module 5 for backups, optional).
7. Output the instance's public IP. SSH in.

## What you read

Mandatory:
- https://developer.hashicorp.com/terraform/intro — what it is, the workflow, the state model.
- https://developer.hashicorp.com/terraform/language — language reference, at least the "Resources" and "Modules" sections.
- https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html — VPC concepts.

Background (skim):
- https://aws.amazon.com/free/ — read the free-tier terms once, recently.
- https://developer.hashicorp.com/terraform/language/state/remote — remote state.

## What you do

See `exercises.md`.

## How you know you're done

See `validation.md`.

## Cost note

- t3.micro on-demand outside free tier: ~$0.0104/hr ≈ $7.49/mo if left running.
- During free-tier window: 750 hr/month covers one instance 24/7.
- Bootcamp recommendation: stop the instance when not actively using it. `aws ec2 stop-instances` doesn't bill for compute, only EBS.
