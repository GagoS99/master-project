# Module 5 — Validation

## Hard gates

- [ ] Prometheus Targets page shows your API as `UP`.
- [ ] Your custom dashboard renders the 5 panels with real, moving data.
- [ ] Dashboard JSON is in git and survives a Grafana pod delete.
- [ ] `APIHighErrorRate` alert can be made to fire and clear by your own action (e.g., scaling Postgres).
- [ ] PVC sizes sum to ≤ 10 GiB.

## Concept gates

You can explain:

- The Prometheus pull model (vs push gateways).
- The difference between counter, gauge, histogram, summary.
- Why `rate()` requires a counter, and why `irate()` is rarely what you want for dashboards.
- The `for:` duration on alerts and why "evaluation period" ≠ "for".
- The four golden signals (latency, traffic, errors, saturation) and which metric in your dashboard maps to each.
- The role of the Prometheus Operator vs a vanilla Prometheus install.

## Done-when

- You can hand someone the dashboard URL + the alert rules and they can answer "is the API healthy" without you.
