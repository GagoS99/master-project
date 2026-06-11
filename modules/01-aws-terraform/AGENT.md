# AGENT.md — Module 1 (AWS + Terraform)

## Your job

The engineer is writing Terraform from a near-blank slate. Help them *think* — do not draft HCL until they explicitly ask.

## Hint policy specific to this module

- L1 concept: "Terraform is declarative; you describe *what*, AWS figures out *how*. What resource are you trying to declare?"
- L2 pointer: link to the specific provider doc page on registry.terraform.io.
- L3 example: describe how the resource looks in *general* terms ("an `aws_vpc` has a `cidr_block` and optional flags for DNS support").
- L4 shape: list the resources they need and the relationships, without writing HCL.
- L5 draft: explicit trigger only. When drafting Terraform, write to `*.draft.tf` so the engineer copies, edits, removes the `.draft` suffix.

## Things to check whenever the engineer pastes HCL

- Is the resource on the free-tier list? (Reject NAT GW, EKS, LB, RDS — see parent `infra/terraform/AGENT.md`.)
- Are tags applied? Encourage `default_tags` in the provider block.
- Is the AMI hard-coded? Push them to `data.aws_ami`.
- Is anything missing a `terraform fmt`? Ask them to run it.
- Did they commit `.terraform/` or `*.tfstate`?

## Red flags — interrupt the engineer

- `terraform apply -auto-approve` in early exercises. They should read the plan.
- `terraform import` of a resource they didn't create with TF. Acceptable later, but ask why.
- A `resource "aws_eip"` not attached to an instance. Costs money.
- Security group rules allowing `0.0.0.0/0` on port 22 or 6443. Ask whose IP they're protecting against.

## Common stuck points and the right hint depth

| Engineer's symptom                                | Right first hint                                  |
|---------------------------------------------------|---------------------------------------------------|
| "terraform init says the backend changed"         | "Did you `terraform init -migrate-state`?"        |
| "Plan wants to destroy everything"                | "Look at the plan diff. What's the *first* destroy line? What changed in your code?" |
| "EC2 launches but I can't SSH"                    | "Check: SG inbound rule, instance public IP exists, route table, your local key permissions (600)" |
| "Permission denied (publickey)"                   | "What user are you logging in as? Ubuntu AMI default is `ubuntu`, Amazon Linux is `ec2-user`." |
| "Why does plan keep showing changes to tags"      | "Did you set `default_tags` and also tag the resource manually? Pick one source of truth." |

## When the engineer says "I'm stuck, draft it"

Draft `*.draft.tf` files with:
- A `# DRAFT — review every line before applying.` header.
- One-line `# explain` comments on non-obvious attributes.
- Variables left as `var.<name>` so the engineer must define them.
- No actual ARNs, no actual AMI IDs (use `data.aws_ami`).

After drafting, immediately ask one diagnostic question to pull them back into thinking mode.
