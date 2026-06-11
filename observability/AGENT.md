# AGENT.md — `observability/`

Modules 5 and 6 output. Prometheus + Grafana + Loki on the same k3s cluster.

## Expected final structure

```
observability/
├── prometheus/
│   ├── values.yaml           # kube-prometheus-stack overrides
│   └── README.md             # engineer's own notes on what they tuned
├── grafana/
│   ├── dashboards/           # JSON dashboards exported from UI
│   └── alerts/               # alert rules YAML
└── loki/
    ├── values.yaml           # loki + promtail Helm overrides
    └── logql-cheatsheet.md   # engineer's own
```

## Module 5 — Prometheus + Grafana

Hint ladder:
- **L1:** "What's the difference between metrics and logs? Why both?"
- **L2:** Point at https://prometheus.io/docs/practices/naming/ and https://grafana.com/tutorials/.
- **L3:** Describe how kube-prometheus-stack wires together (Operator → Prometheus → ServiceMonitor → scrape targets).
- **L4:** Sketch the PromQL query shape for "request latency p99 over 5m, by service."
- **L5:** Draft on trigger.

Push back on:
- Installing `prometheus` chart instead of `kube-prometheus-stack`. The latter includes the Operator and CRDs; without those, ServiceMonitors don't work.
- Persistent volume sizes > 10 GB (free-tier risk on EBS).
- Building a dashboard from scratch when a community one already covers it. Engineer should import an existing one and then *modify* it to learn.
- Alert rules with no `for:` duration. Flapping alerts are worse than no alerts.

## Module 6 — Loki + capstone

Hint ladder same shape; capstone is a deliberately-broken scenario.

The capstone scenario:
- Engineer applies `modules/06-logging-capstone/break-it.sh` which introduces *one* problem (a misconfigured ConfigMap, a wrong image tag, a NetworkPolicy that blocks DB traffic — randomized).
- Engineer must diagnose using only:
  - Grafana dashboards
  - Loki logs
  - `kubectl` for verification (not for guessing)
- AI guardrail for the capstone: **no hints about the specific problem until the engineer has filed a written hypothesis in `modules/06-logging-capstone/hypothesis.md`.** This is non-negotiable.

Push back on:
- Engineer grepping logs without a request ID or correlation key. Force them to find one.
- Skipping the hypothesis file. Refuse to give problem-specific hints until it exists and is non-empty.
- Loki retention > 7 days (storage).

## Validation hints

Module 5 exit:
- A custom dashboard exists in `grafana/dashboards/` (exported JSON).
- One real alert fires when the engineer manually triggers the failure condition.
- Engineer can explain the `rate()` vs `irate()` vs `increase()` distinction.

Module 6 exit:
- `hypothesis.md` documents what they thought before knowing the answer.
- `resolution.md` documents the actual root cause, the log query that found it, and the fix commit.
