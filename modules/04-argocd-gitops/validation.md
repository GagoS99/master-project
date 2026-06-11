# Module 4 — Validation

## Hard gates

- [ ] `argocd app list` shows root + 3 child apps, all `Synced` and `Healthy`.
- [ ] You can change something via PR, merge, and see the sync happen without your involvement after merge.
- [ ] You can drift the cluster manually and see ArgoCD revert it.
- [ ] No `helm` releases of the bootcamp app exist outside ArgoCD. (`helm list -A` shows only `argocd` and `postgres` if it's managed by Argo via dependency.)

## Concept gates

You can explain, in plain English:

- The "pull-based" reconciliation model and why it differs from `kubectl apply` from a CI pipeline.
- The difference between `Synced`, `Healthy`, `OutOfSync`, `Degraded`, `Missing`.
- What `prune` does and the failure mode of enabling it before you trust the App.
- What `selfHeal` does and when *not* to enable it.
- How `app-of-apps` differs from `ApplicationSet` (and why we used app-of-apps).
- How ArgoCD knows when to sync (polls, webhooks).

## Done-when

- All three child Apps are managed by Argo, you've broken sync at least twice and recovered cleanly, and the cluster matches `infra/argocd/applications/*` exactly.
