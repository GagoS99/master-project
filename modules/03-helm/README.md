# Module 3 — Helm Packaging

**Time:** ~1 week
**Free-tier risk:** None.
**Working dir:** `infra/helm/`, plus building Docker images for `app/`.

## Why this module exists

You have raw YAML. You have learned the hard way that copy-pasting YAML across environments produces drift and bugs. Helm fixes this with templates and values.

You will package the sample app — API + frontend + Postgres — into Helm charts and install them on your k3s cluster.

## Learning objectives

1. Understand the anatomy of a Helm chart: `Chart.yaml`, `values.yaml`, `templates/`, `_helpers.tpl`.
2. Template a Deployment, Service, ConfigMap, Secret from values.
3. Use `helm template`, `helm lint`, `helm install --dry-run` *before* `helm install`.
4. Use `helm upgrade --install` (idempotent) instead of `helm install` + `helm upgrade`.
5. Compose charts with dependencies (umbrella chart with `bitnami/postgresql` as a dep).
6. Separate environment-specific values from chart defaults.

## What you read

- https://helm.sh/docs/topics/charts/ — chart structure.
- https://helm.sh/docs/chart_template_guide/ — the templating guide. Read it in order.
- https://helm.sh/docs/topics/library_charts/ — skim only.
- https://artifacthub.io/packages/helm/bitnami/postgresql — for the Postgres dep.

## What you do

See `exercises.md`.

## How you know you're done

See `validation.md`.
