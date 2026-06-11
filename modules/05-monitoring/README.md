# Module 5 — Monitoring: Prometheus + Grafana

**Time:** ~1 week
**Free-tier risk:** Low (EBS usage from PVCs — keep them small).
**Working dir:** `observability/prometheus/`, `observability/grafana/`.

## Why this module

You've shipped an app. You don't know if it's working until a user complains. This module fixes that. By the end you'll have:
- Metrics scraped from the app's `/metrics` endpoint.
- A custom Grafana dashboard showing request rate, latency, error rate.
- One real alert that fires when error rate spikes.

## Learning objectives

1. Install `kube-prometheus-stack` via Helm (Prometheus + Grafana + Alertmanager + Operator).
2. Understand the Prometheus Operator's CRDs: `ServiceMonitor`, `PodMonitor`, `PrometheusRule`.
3. Write a `ServiceMonitor` so Prometheus scrapes the API.
4. Write PromQL queries for the four golden signals: traffic, errors, latency, saturation.
5. Build a Grafana dashboard from scratch (then export to JSON).
6. Write one `PrometheusRule` that fires an alert when 5xx rate > 5% for 5 minutes.

## What you read

- https://prometheus.io/docs/practices/instrumentation/ — what to measure.
- https://prometheus.io/docs/prometheus/latest/querying/basics/ — PromQL basics.
- https://prometheus-operator.dev/docs/ — Operator CRDs.
- https://grafana.com/docs/grafana/latest/panels-visualizations/ — dashboard panels.
- https://sre.google/sre-book/monitoring-distributed-systems/ — the SRE book chapter, short.

## What you do

See `exercises.md`.

## How you know you're done

See `validation.md`.
