# DevOps Bootcamp — Tutorial-Hell Recovery Edition

A 4-6 week self-paced curriculum that takes you from "I watched a course" to "I built and operated it." Stays inside the AWS free tier. Ends with a GitOps-deployed, monitored, logged 2-service app on a real cloud k8s cluster.

## How to use this repo

1. **Read the PDF** — `pdf/guide.pdf`. That is the primary curriculum. Open it on a tablet/second screen.
2. **Read `MODULE_INDEX.md`** — your progress tracker.
3. **Work in `modules/NN-*/`** — each has a `README.md` (what you do) and `exercises.md` (the work) and `validation.md` (how you know you're done).
4. **The repo starts mostly empty.** You build the contents of `infra/`, `observability/`, etc. as you go.
5. **Use the AI as a hint engine.** At the start of every session, paste `AGENT_SYSTEM_PROMPT.md` into your AI. It will refuse to write code for you by default. To unlock drafting, type the exact phrase: **"I'm stuck, draft it."**

## Prerequisites

- macOS or Linux workstation
- An AWS account (personal, with billing alerts set — see `docs/aws-account-setup.md`)
- Comfortable in a terminal; can read code in any language
- ~10-15 hours/week for 4-6 weeks

## What you'll have at the end

- A VPC + EC2 + k3s cluster provisioned by Terraform
- A 2-service app (Node API + static frontend) packaged as Helm charts
- ArgoCD deploying that app via GitOps from this repo
- Prometheus + Grafana dashboards and one real alert
- Loki collecting logs, with a capstone debug scenario you've solved
- One command to destroy everything: `./scripts/destroy-all.sh`

## Top-level layout

```
.
├── AGENT_SYSTEM_PROMPT.md     # Paste into your AI at session start
├── MODULE_INDEX.md            # Your progress tracker
├── README.md                  # You are here
├── pdf/
│   └── guide.pdf              # The primary curriculum (rich format)
├── docs/                      # Reference docs (cost budget, AWS setup)
├── modules/
│   ├── 00-linux/
│   ├── 01-aws-terraform/
│   ├── 02-k3s-cluster/
│   ├── 03-helm/
│   ├── 04-argocd-gitops/
│   ├── 05-monitoring/
│   └── 06-logging-capstone/
├── app/                       # Pre-built sample app (don't modify app code)
│   ├── api/
│   ├── frontend/
│   └── db/
├── infra/                     # YOU build this
│   ├── terraform/
│   ├── helm/
│   └── argocd/
├── observability/             # YOU build this
│   ├── prometheus/
│   ├── grafana/
│   └── loki/
└── scripts/
    ├── check-free-tier.sh
    └── destroy-all.sh
```

## Cost expectations

If you follow the guide and run `./scripts/destroy-all.sh` between sessions: **$0/month**.

If you forget to tear down: ~$0-5/month while in free-tier window (12 months), then ~$8-15/month for an idle t3.micro + EBS + minor data transfer.

See `docs/free-tier-budget.md` for the line-item breakdown.
