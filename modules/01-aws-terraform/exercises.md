# Module 1 — Exercises

> **Stop. Before exercise 1**, complete `docs/aws-account-setup.md` (CLI configured, billing budget set, IAM user created). Confirm: `aws sts get-caller-identity --profile bootcamp` returns your bootcamp user.

## Exercise 1 — Local Terraform

Working dir: `infra/terraform/`.

1. Install Terraform >= 1.6 (`brew install terraform` or `tfenv`).
2. Initialize a Terraform project. Add `providers.tf` declaring the AWS provider, region `us-east-1`, profile `bootcamp`.
3. Add `versions.tf` pinning the AWS provider version (e.g., `~> 5.40`).
4. Run `terraform init`. Look at what got created. Look at `.terraform/`. Don't commit it.
5. Write a *trivial* resource — e.g., an S3 bucket — `terraform plan`, `terraform apply`. Inspect `terraform.tfstate`. Then `terraform destroy`.

Goal: feel the plan/apply/state loop on a throwaway resource before doing anything load-bearing.

## Exercise 2 — Remote state backend (bootstrap)

Chicken-and-egg: the bucket that holds state can't be in the same Terraform that uses it.

1. Manually (or via a one-shot script — `scripts/bootstrap-tf-backend.sh` — that you write) create:
   - An S3 bucket: `bootcamp-tfstate-<your-initials>-<random>` (must be globally unique).
     - Versioning: enabled.
     - Public access: blocked.
     - Encryption: SSE-S3 (default).
   - A DynamoDB table: `bootcamp-tfstate-lock`. Primary key `LockID` (string). PAY_PER_REQUEST billing mode.
2. Configure `backend "s3"` in a `backend.tf`. Reference your bucket and lock table.
3. Run `terraform init -migrate-state`. Confirm `terraform.tfstate` is now in S3.

## Exercise 3 — VPC

Build, by hand (no community modules unless you've read their source):

- 1 VPC, CIDR `10.0.0.0/16`, DNS support + DNS hostnames enabled.
- 1 public subnet, CIDR `10.0.1.0/24`, in availability zone `us-east-1a`.
- 1 Internet Gateway, attached to the VPC.
- 1 route table with route `0.0.0.0/0 → IGW`. Associated to the subnet.

Run `terraform plan`. Read every line of the plan. Apply.

Verify in the AWS console (read-only): the VPC, subnet, IGW, and route table exist.

## Exercise 4 — Security group + EC2 + key pair

1. Generate an SSH key pair locally (different from any personal key). Upload the public key to AWS as a `aws_key_pair` resource.
2. Create a security group:
   - Inbound: port 22 from `<your-public-IP>/32` only. Use a data source or variable for your IP.
   - Inbound: port 6443 from `<your-public-IP>/32` (for k3s API in Module 2).
   - Outbound: all.
3. Launch one EC2 instance:
   - `instance_type = "t3.micro"`.
   - AMI: latest Ubuntu 22.04 LTS via `data.aws_ami` (filter by name + owner).
   - Subnet: your public subnet.
   - Associate public IP.
   - Key pair: the one from step 1.
   - Security group: the one from step 2.
   - Root volume: 20 GB, gp3.
   - User data (cloud-init): set hostname, apt update, install `curl`. (No k3s yet — Module 2.)
4. Output the instance's public IP.

## Exercise 5 — IAM instance profile

1. Create an IAM role with `ec2.amazonaws.com` trust.
2. Attach a minimal policy: `s3:GetObject` and `s3:ListBucket` on your tfstate bucket (or a separate bucket if you don't want EC2 to read state).
3. Create an instance profile referencing the role.
4. Attach the instance profile to the EC2.
5. SSH in, install AWS CLI, confirm `aws sts get-caller-identity` returns the role.

## Exercise 6 — Refactor into modules

Once exercises 3-5 work, refactor:
- `modules/vpc/`
- `modules/ec2/`
- `modules/iam/`

Root `main.tf` composes them. Variables flow in via `environments/dev/terraform.tfvars`.

Run `terraform plan` — should produce zero changes. (If it does, you accidentally changed something during refactor.)

## Exercise 7 — Destroy + re-apply

1. `terraform destroy`. Confirm AWS console shows nothing.
2. `terraform apply`. Confirm everything comes back, public IP may differ.
3. Note the time it took. Future-you will need this estimate.

## Deliverables checklist

- [ ] `infra/terraform/backend.tf` references S3 + DynamoDB.
- [ ] `terraform fmt -recursive` is clean.
- [ ] `terraform validate` is clean.
- [ ] No `*.tfstate*` committed.
- [ ] `terraform plan` after a clean apply shows "No changes."
- [ ] You can `ssh -i <key> ubuntu@<public-ip>` and run `aws sts get-caller-identity`.
