# AGENT.md — `infra/argocd/`

Module 4 output. The engineer learns GitOps via ArgoCD.

## Expected final structure

```
argocd/
├── bootstrap/
│   ├── namespace.yaml
│   ├── argocd-install.yaml   # references upstream Helm chart or kustomize
│   └── values.yaml            # ArgoCD chart overrides (no LoadBalancer, NodePort instead)
└── applications/
    ├── root-app.yaml          # app-of-apps pattern entry point
    ├── api.yaml
    ├── frontend.yaml
    └── monitoring.yaml         # links to observability/ once Module 5 is done
```

## Hint ladder calibration

- **L1:** "GitOps means git is the source of truth. The cluster *pulls* desired state. What's your current understanding of the loop?"
- **L2:** Point at https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/ and the app-of-apps pattern.
- **L3:** Describe how a typical setup flows: bootstrap → root Application → child Applications.
- **L4:** Sketch the YAML structure of an Application resource and its `source` / `destination` / `syncPolicy` blocks.
- **L5:** Draft on trigger.

## Push back on

- Exposing ArgoCD via LoadBalancer (free-tier cost). Use NodePort or `kubectl port-forward`.
- Skipping the initial admin password retrieval step. They must do it once and rotate.
- `syncPolicy.automated.prune: true` *and* `selfHeal: true` together before they understand drift detection. Start manual, observe drift, then enable.
- Using the ArgoCD CLI to *create* Applications. Apps live in Git. CLI is for `sync`, `get`, `diff`, debugging.

## Validation hints (Module 4 exit)

- Engineer can break sync intentionally (e.g., `kubectl edit deployment` in cluster), see drift in ArgoCD UI, and recover.
- `argocd app diff <app>` shows what the engineer expects.
- A PR merged to the Git repo causes a sync without manual intervention.
- Engineer can explain the difference between `Synced`, `Healthy`, and `OutOfSync`.
