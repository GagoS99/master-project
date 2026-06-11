# Module Index

Track your current position in the bootcamp. Update the `Current module` line as you progress.

**Current module:** `00-linux`

---

## Curriculum (4-6 weeks, AWS free tier, ~10-15 hrs/week)

| #  | Module                        | Weeks | What you'll build                                          | Free-tier risk |
|----|-------------------------------|-------|------------------------------------------------------------|----------------|
| 00 | Linux fundamentals refresher  | 0.5   | systemd unit, journalctl debugging, basic networking lab   | None (local)   |
| 01 | AWS foundations + Terraform   | 1     | VPC, EC2 t3.micro, IAM role, S3 backend, DynamoDB lock     | Low            |
| 02 | k3s cluster on EC2 + kubectl  | 0.5   | Single-node k3s, kubeconfig, first Deployment              | Low            |
| 03 | Helm packaging                | 1     | Two charts (api, frontend) + umbrella chart, values per-env| None           |
| 04 | ArgoCD + GitOps               | 1     | ArgoCD installed via Helm, app-of-apps, PR-driven deploys  | None           |
| 05 | Monitoring (Prom + Grafana)   | 1     | kube-prometheus-stack, one custom dashboard, one alert     | Low (storage)  |
| 06 | Logging + capstone debug      | 1     | Loki + Promtail, then a deliberately-broken scenario       | Low            |

**Total target:** 4-6 weeks.

## Exit criteria for the bootcamp

You can answer YES to all of these without notes:

- [ ] You can `terraform apply` a VPC + EC2 from scratch and explain every resource.
- [ ] You can SSH to the node, inspect a misbehaving systemd service, and find the cause in logs.
- [ ] You can `helm install` your app and explain what each value controls.
- [ ] You can break ArgoCD sync intentionally and diagnose drift via the UI and CLI.
- [ ] You can write a PromQL query that distinguishes "API is slow" from "API is down."
- [ ] You can grep Loki for the request ID of a failing request and tell the story end-to-end.
- [ ] You can destroy everything with one command and confirm $0 ongoing spend.

## Rules of the road

1. **No copy-paste from the AI.** If the AI draft mode produces a snippet, retype it. Muscle memory matters.
2. **Cost guard:** run `./scripts/check-free-tier.sh` at the end of every session.
3. **Teardown discipline:** if you walk away for more than 48 hours, run `./scripts/destroy-all.sh`. Recreate next session.
4. **Commit often, push often.** Git history is your real notes.
5. **Read the official docs first.** AI is supplement, not source.
