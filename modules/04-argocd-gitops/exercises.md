# Module 4 — Exercises

## Pre-req

You need this repo on GitHub (or GitLab) so ArgoCD can pull from it. Free-tier private repos work, but for the bootcamp keep it public to skip credential setup. If you must use private, see "Private repo" section at the bottom.

Confirm: `git remote -v` points at GitHub.

## Exercise 1 — Install ArgoCD

`infra/argocd/bootstrap/values.yaml` — overrides for the ArgoCD Helm chart.

Constraints:
- `server.service.type: NodePort` (NOT LoadBalancer — free-tier).
- Disable `dex` if you're not using SSO.
- Set `server.extraArgs: ["--insecure"]` for the bootcamp (we'll port-forward; TLS termination is a later concern).

Install:
```sh
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  --values infra/argocd/bootstrap/values.yaml \
  --version <pin-this>   # see chart releases
```

Wait for pods to be ready:
```sh
kubectl -n argocd get pods -w
```

Get the initial admin password:
```sh
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d
```

Access the UI: `kubectl -n argocd port-forward svc/argocd-server 8443:443`, then https://localhost:8443. Log in as `admin` + that password.

Rotate or delete the initial-admin secret after first login (best practice; do this before continuing).

## Exercise 2 — Install the CLI

```sh
brew install argocd   # or download from releases
argocd login localhost:8443 --insecure --username admin
```

You should see `argocd app list` (empty for now).

## Exercise 3 — Root Application (app-of-apps)

Create `infra/argocd/applications/root.yaml`:
- Kind: Application
- Name: `root`
- Source: this Git repo, path `infra/argocd/applications`, recurse over remaining YAML files in this dir.
- Destination: same cluster, namespace `argocd`.
- Sync policy: **manual** for now. Auto comes later.

Apply it once, by hand, to bootstrap:
```sh
kubectl -n argocd apply -f infra/argocd/applications/root.yaml
```

In the UI you should see one Application called `root`. Sync it manually.

## Exercise 4 — Child Applications

Create:

- `infra/argocd/applications/postgres.yaml` — points at `bitnami/postgresql` chart from the Helm repo, with the values from your umbrella chart.
- `infra/argocd/applications/api.yaml` — points at `infra/helm/api` (in this repo) with appropriate values inline (`spec.source.helm.values: |-`).
- `infra/argocd/applications/frontend.yaml` — same.

After committing + pushing to git, sync the root Application. ArgoCD should detect the three new Apps and create them.

Sync each child. Verify with `argocd app list` and `kubectl get all -n bootcamp`.

**Before moving on:** delete your prior `helm install` of the app — confirm everything is now managed by ArgoCD. There should be no two sources of truth.

## Exercise 5 — Drive a change through Git

1. Edit the `replicaCount` for `api` from 1 to 2 in `infra/argocd/applications/api.yaml`.
2. Commit, push.
3. Watch ArgoCD detect the change: in the UI, `api` should become `OutOfSync`.
4. Sync (manually for now). Pods scale to 2.

Repeat: change something visible (an env var, a label). Confirm round-trip.

## Exercise 6 — Drift detection

1. `kubectl -n bootcamp edit deployment api`. Change replicas to 5.
2. In the ArgoCD UI, `api` is now `OutOfSync` — but ArgoCD shows the *cluster* as the diverging side, not Git.
3. Click Sync. Cluster snaps back to 2.

This is what `selfHeal: true` automates. **Don't enable it yet.** Observe the drift behavior first.

## Exercise 7 — Enable automated sync, carefully

Pick one Application (`api`) and add:
```yaml
syncPolicy:
  automated:
    prune: false       # start false; turn on later when you trust the setup
    selfHeal: true
  syncOptions:
    - CreateNamespace=true
```

Push. Wait. Now manually edit the cluster: change replicas. Watch ArgoCD auto-revert within ~3 minutes.

Then turn on `prune: true`. Test: remove a Service from the chart, push. Watch ArgoCD delete the Service in the cluster.

## Exercise 8 — Failure modes

Things to deliberately break and recover from:
- Push a syntactically-bad YAML. ArgoCD shows the App as `ComparisonError`. Find the error in the UI; fix it.
- Push a values change that produces an invalid manifest (e.g., `replicaCount: -1`). Watch the sync fail with a clear K8s API error.
- Disconnect the cluster from the internet briefly (drop the egress rule). Watch ArgoCD's sync status.

## Private repo (if you went that route)

You'll need to add a repo credential to ArgoCD. Two options:

1. SSH deploy key on the repo + `argocd repo add git@github.com:... --ssh-private-key-path ...`.
2. GitHub App or PAT via `argocd repo add https://github.com/... --username ... --password ...`.

Document the approach you took in `infra/argocd/NOTES.md`.

## Deliverables checklist

- [ ] ArgoCD installed via Helm, accessible via port-forward.
- [ ] App-of-apps pattern: 1 root Application + 3 child Applications.
- [ ] No `helm install`/`helm upgrade` of the app outside ArgoCD anymore.
- [ ] At least one PR has been merged and synced.
- [ ] `selfHeal` is enabled on at least one App; you've watched it recover from manual drift.
- [ ] `prune` is enabled on at least one App; you've watched it delete a removed resource.
