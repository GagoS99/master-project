# Module 1 — Validation

## Hard gates

- [ ] `terraform plan` returns "No changes" on a freshly-applied stack.
- [ ] `terraform state list` shows every resource and you can explain each.
- [ ] SSH works: `ssh devvm` (via SSH config) connects to the EC2.
- [ ] From inside the EC2, `aws sts get-caller-identity` returns the *role* (not your user).
- [ ] Billing budget for $5/mo is active and you got the test email.
- [ ] Re-running `terraform destroy` then `terraform apply` produces a working stack.
- [ ] `terraform.tfstate` is in S3; the DynamoDB lock table shows a brief lock during apply.

## Concept gates

You can answer in plain English, out loud, without notes:

- What is in your state file and why it shouldn't be committed to Git.
- Why the backend bucket can't be defined in the same Terraform that uses it.
- The difference between `count`, `for_each`, and `dynamic` blocks.
- What `terraform refresh` does and why you almost never run it manually.
- Why we used a route table with `0.0.0.0/0 → IGW` instead of letting the subnet "just work."
- What happens to your EC2 if you stop it vs. terminate it (and what costs each).

## Done-when

Run `./scripts/check-free-tier.sh` and paste the output. Confirm:
- Exactly 1 EC2 instance (yours).
- 0 NAT Gateways, 0 LoadBalancers, 0 RDS instances.
- 0 unattached Elastic IPs.
- EBS volumes: only the one attached to your EC2.

If anything is off, fix it before claiming Module 1 done.
