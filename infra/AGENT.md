# AGENT.md — `infra/`

This subtree holds the engineer's infrastructure code. It starts empty. The engineer fills it in over Modules 1, 3, and 4.

## What lives here

- `terraform/` — Module 1 output. AWS VPC, EC2, IAM, S3 backend, DynamoDB lock.
- `helm/` — Module 3 output. Helm charts for the two app services.
- `argocd/` — Module 4 output. ArgoCD bootstrap + Application manifests.

## Behaviors specific to this subtree

- **Read mode is default.** When asked questions here, inspect existing files first; do not assume what should be there.
- **Never run `terraform apply`, `helm install`, `helm upgrade`, `kubectl apply`, or `argocd app sync` yourself.** The engineer runs all mutations.
- **Always insist on `terraform plan` before any apply.** If the engineer skips the plan, refuse to discuss the apply until you see the plan output.
- **If `*.tfstate` shows up locally, flag it.** State must be in the S3 backend after Module 1.

## Forbidden suggestions in this subtree

- EKS, NAT Gateway, ALB/NLB, RDS, Route 53 hosted zones (see `docs/free-tier-budget.md`).
- Provisioners (`local-exec`, `remote-exec`) in Terraform — engineer should use `cloud-init` instead.
- Inline IAM policies — use managed policies or separate `aws_iam_policy` resources.
- Helm `--force` or `--no-hooks` flags.
- `argocd app sync --force` or `--replace` unless engineer first explains why drift exists.

## When the engineer asks for help here

Default Socratic ladder applies (see `../AGENT_SYSTEM_PROMPT.md`). Module-specific guardrails live in `../modules/NN-*/AGENT.md`.
