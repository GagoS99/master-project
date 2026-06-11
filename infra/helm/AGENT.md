# AGENT.md — `infra/helm/`

Module 3 output. The engineer is learning Helm templating, values, releases, lifecycle hooks.

## Expected final structure

```
helm/
├── api/                    # Chart for app/api
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── templates/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── configmap.yaml
│   │   └── _helpers.tpl
│   └── tests/
├── frontend/               # Chart for app/frontend
│   └── ...
└── umbrella/               # Optional: app-of-charts that depends on api + frontend + postgres
    ├── Chart.yaml
    └── values.yaml
```

## Hint ladder calibration

- **L1:** "A Helm chart is a templated K8s manifest set + a values schema. Which part are you stuck on?"
- **L2:** Point at https://helm.sh/docs/chart_template_guide/ and the specific subsection.
- **L3:** Describe a similar chart (e.g., how `bitnami/postgresql` structures its `values.yaml`).
- **L4:** Sketch the template file list and what each contains, one line each.
- **L5:** Draft mode on explicit trigger.

## Push back on

- Putting environment-specific values inside the chart instead of in separate values files.
- Hard-coding the image tag. Use `.Values.image.tag` and default to `latest` for dev only.
- Skipping `helm lint` and `helm template` before install.
- Using `helm install` repeatedly instead of `helm upgrade --install`.
- Storing secrets as plain `Secret` manifests in the chart. Use external secrets in Module 4+ or `--set` from CI for now.
- Lifecycle hooks they don't understand (post-install jobs, etc.). Ask why.

## In-cluster Postgres note

The engineer is running Postgres as a StatefulSet in-cluster (free-tier driven decision — see `docs/free-tier-budget.md`). They should:

- Use `bitnami/postgresql` or write their own StatefulSet.
- Use a PVC with the local-path provisioner that k3s ships with.
- Acknowledge in their notes that this is not how prod databases run, and why.

## Validation hints (Module 3 exit)

- `helm lint` clean on both charts.
- `helm template` output is human-readable and contains no unresolved variables.
- `helm upgrade --install` is idempotent — running it twice changes nothing.
- Engineer can explain `_helpers.tpl` and why it exists.
