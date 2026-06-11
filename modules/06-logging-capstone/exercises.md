# Module 6 — Exercises (Logging Setup)

## Exercise 1 — Install Loki + Promtail

Use the `loki-stack` Helm chart (or `loki` + `promtail` separately — the modern recommendation is `loki` + `grafana-agent` but `loki-stack` is fine for bootcamp scope).

1. New ArgoCD Application: `infra/argocd/applications/loki.yaml`.
2. Chart values:
   - `loki.persistence.enabled: true`, size 5Gi, storageClass `local-path`.
   - `loki.config.limits_config.retention_period: 168h` (7 days; free-tier).
   - `promtail.enabled: true`.
   - `grafana.enabled: false` (you already have Grafana from Module 5).

3. Sync. Verify pods Running.

4. Add Loki as a Grafana data source: in Grafana → Connections → Data Sources → Add Loki, URL `http://loki:3100`.
   Better: provision the data source via ConfigMap (grafana sidecar with label `grafana_datasource: "1"`).

## Exercise 2 — Find your logs

In Grafana → Explore → Loki:

- `{namespace="bootcamp"}` — all bootcamp pod logs.
- `{namespace="bootcamp", pod=~"api.*"}` — just the API.
- `{namespace="bootcamp"} |= "error"` — lines containing "error" (case-sensitive substring).
- `{namespace="bootcamp"} |~ "(?i)error"` — regex, case-insensitive.
- `{namespace="bootcamp", pod=~"api.*"} | json` — parse JSON lines into labels (your API logs are simple text — try this against the Postgres pod which has structured logs).

Find a "real" log line your API emits when it serves a request. (Note: the sample app's logging is minimal — that's fine.)

## Exercise 3 — Correlate logs with metrics

In Grafana, build a row of panels:
- Top: error rate from Module 5's dashboard.
- Bottom: a Loki panel showing logs filtered to `{pod=~"api.*"} |~ "error|warn"`.

Trigger an error (scale Postgres to 0). Watch both panels react. Restore Postgres.

This row is the most useful artifact you'll build in the bootcamp. Save it.

## Exercise 4 — LogQL practice

Write LogQL queries for:

1. Count of log lines per pod over the last 5 minutes.
2. Rate of lines containing "ERROR" over the last 1 minute.
3. Average duration of "completed request" log lines (assuming a `duration=` field; use `unwrap`).

If your app doesn't produce these specific shapes, simulate by `kubectl exec`-ing into a pod and `echo "ERROR something"` to stdout.

## Exercise 5 — Ready for the capstone

Confirm:
- [ ] Loki has data from `bootcamp`, `monitoring`, `argocd`, `kube-system` namespaces.
- [ ] You can switch from a metric panel to a log query in under 30 seconds.
- [ ] You have written 3 LogQL queries from memory.

When all three boxes are ticked: proceed to `capstone.md`.
