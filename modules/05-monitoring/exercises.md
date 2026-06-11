# Module 5 — Exercises

## Exercise 1 — Install kube-prometheus-stack via ArgoCD

You'll deploy it the GitOps way from the start.

1. Add a new Application to `infra/argocd/applications/monitoring.yaml`:
   - Source: `https://prometheus-community.github.io/helm-charts`, chart `kube-prometheus-stack`, pinned version.
   - Destination namespace: `monitoring`.
   - Values inline (or in a separate values file referenced by Argo).
2. Constraints in values:
   - `grafana.service.type: NodePort` (no LoadBalancer).
   - `grafana.adminPassword`: set via secret reference, not inline. (For bootcamp, you may set it inline temporarily — but log this as tech debt.)
   - `prometheus.prometheusSpec.retention: 5d` (free-tier disk).
   - `prometheus.prometheusSpec.storageSpec` with a 5Gi PVC on `local-path`.
   - `alertmanager.alertmanagerSpec.storage.volumeClaimTemplate` with a 1Gi PVC.
   - Disable components you don't need yet: e.g., `kube-state-metrics` is good to keep; `node-exporter` keep; you can disable `defaultRules` of certain rule groups if you want fewer alerts.

3. Sync. Wait. `kubectl -n monitoring get pods` should show prometheus, grafana, alertmanager all `Running`.

4. Port-forward Grafana: `kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80`. Log in with admin/admin (or whatever you set).

## Exercise 2 — Scrape the API

The API at `/metrics` exposes Prometheus-format metrics.

1. Create a `ServiceMonitor` in `infra/helm/api/templates/servicemonitor.yaml`. Guarded by `.Values.metrics.enabled` so dev environments without Prometheus won't fail.
2. Selector: matches the API Service labels.
3. Endpoints: port `http` (or whatever your Service names it), path `/metrics`, interval `30s`.

Push, sync. In Prometheus UI (`kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090:9090`), Status → Targets, find your API service, confirm `UP`.

Run a few PromQL queries in the Prometheus UI:
- `up{job=~"api.*"}` — should be 1.
- `http_request_duration_seconds_count{job=~"api.*"}` — request counter.
- `rate(http_request_duration_seconds_count[5m])` — request rate.

## Exercise 3 — Generate some traffic

Otherwise dashboards are flat lines.

```sh
# In a loop, hit the API:
while true; do
  curl -s -o /dev/null http://<ec2>:<frontend-nodeport>/api/items
  sleep 0.5
done
```

Or use `hey`/`vegeta`/`k6` for fancier load. Let it run while you build the dashboard.

## Exercise 4 — A real dashboard

Build, in Grafana UI, a dashboard with these panels:

1. **Request rate** (requests/sec): `sum(rate(http_request_duration_seconds_count[5m])) by (route)`.
2. **Latency p50/p95/p99** (seconds): `histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, route))` etc.
3. **Error rate** (5xx as %): `sum(rate(http_request_duration_seconds_count{status=~"5.."}[5m])) / sum(rate(http_request_duration_seconds_count[5m])) * 100`.
4. **CPU usage** (per pod): `sum(rate(container_cpu_usage_seconds_total{pod=~"api.*"}[5m])) by (pod)`.
5. **Memory usage** (per pod): `container_memory_working_set_bytes{pod=~"api.*"} / 1024 / 1024`.

Save the dashboard. Export it as JSON. Commit it to `observability/grafana/dashboards/api.json`.

## Exercise 5 — Provision the dashboard from Git

In Grafana, dashboards manually created are stored in its DB and lost on PV reset. Move it under GitOps:

1. Add a ConfigMap that contains your dashboard JSON, with the label `grafana_dashboard: "1"` (kube-prometheus-stack's grafana sidecar will pick it up).
2. Add the ConfigMap to your `api` Helm chart or a new `observability/grafana` chart.
3. Delete the dashboard from Grafana UI. Sync. Confirm it reappears, loaded from the ConfigMap.

You now have GitOps-managed dashboards. Document this in `observability/grafana/README.md`.

## Exercise 6 — An alert that means something

Write a `PrometheusRule` (CRD from the Operator):

- Alert name: `APIHighErrorRate`.
- Expression: `sum(rate(http_request_duration_seconds_count{status=~"5.."}[5m])) / sum(rate(http_request_duration_seconds_count[5m])) > 0.05`.
- `for: 5m`.
- Labels: `severity: warning`.
- Annotations: `summary`, `description` with `{{ $value }}`.

Apply via Helm (in the api chart or a new chart). Test:

1. Manually make the API return 500s. (Quick way: scale Postgres to 0 replicas. `/api/items` will 500.)
2. Wait 5 minutes (the `for:` duration).
3. Alertmanager should now show the alert. In Grafana → Alerting → Alert rules.
4. Restore Postgres. Alert clears.

Document the firing→clearing timing in `observability/prometheus/README.md`.

## Stretch

- Add a recording rule that pre-computes the 5m error ratio so dashboard queries are cheap.
- Wire Alertmanager to a free webhook (e.g., a Discord webhook to your personal server).
- Add a dashboard panel that shows `up{}` for every service and turns red on down.

## Deliverables checklist

- [ ] kube-prometheus-stack deployed via ArgoCD.
- [ ] API is scraped (Targets page shows it UP).
- [ ] Custom dashboard JSON committed in `observability/grafana/dashboards/`.
- [ ] PrometheusRule for `APIHighErrorRate` is in git and the alert can be made to fire.
- [ ] Retention is bounded; PVCs are < 10 GB total.
