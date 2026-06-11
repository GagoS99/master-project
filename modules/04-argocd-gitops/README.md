# Module 4 — ArgoCD + GitOps

**Time:** ~1 week
**Free-tier risk:** None.
**Working dir:** `infra/argocd/`.

## Why GitOps

You just `helm upgrade --install`'d your app from your laptop. Fine for solo dev. Not fine for a team, not auditable, not reproducible after you go on vacation.

GitOps inverts the model: **the cluster pulls desired state from git.** Your laptop pushes to git. The cluster reconciles. The benefits:
- Audit trail = git history.
- Rollback = `git revert`.
- Drift detection: if someone `kubectl edit`s, ArgoCD shows it.
- New environments = a new branch or directory, not a runbook.

## Learning objectives

1. Install ArgoCD via Helm into your cluster.
2. Bootstrap an "app-of-apps" pattern: one root Application that manages all child Applications.
3. Move the api/frontend/postgres charts from manual `helm install` to ArgoCD-managed.
4. Open a PR that changes a value, merge it, watch ArgoCD sync.
5. Manually break sync (edit in-cluster). See drift in UI. Recover.
6. Understand `syncPolicy.automated`, `prune`, `selfHeal` — and when *not* to enable them.

## What you read

- https://argo-cd.readthedocs.io/en/stable/getting_started/
- https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/ — app-of-apps.
- https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/ — Application CR.
- https://opengitops.dev/ — short principles read.

## What you do

See `exercises.md`.

## How you know you're done

See `validation.md`.
