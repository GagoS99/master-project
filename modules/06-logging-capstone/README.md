# Module 6 — Logging + Capstone Debug Scenario

**Time:** ~1 week
**Free-tier risk:** Low (Loki PVC).
**Working dir:** `observability/loki/` + `modules/06-logging-capstone/`.

## What this module does

Two parts:

1. **Logging stack** — Install Loki + Promtail. Get logs from all bootcamp namespaces into Grafana. Learn LogQL.
2. **The capstone** — Run `./break-it.sh`. It introduces one bug at random. You diagnose it using only Grafana (metrics + logs) and `kubectl` (for verification, not guessing). You write your hypothesis *before* you check the answer.

The capstone is the most important hour of the bootcamp. It's the closest simulation to "the on-call page at 2am" available without a real incident.

## Learning objectives

1. Install Loki + Promtail via Helm (GitOps).
2. Configure Promtail to scrape all pod logs with useful labels.
3. Write LogQL queries to:
   - Tail the api logs.
   - Filter by level, namespace, pod.
   - Correlate a metric anomaly with a log spike.
4. Practice incident hygiene: hypothesis-first debugging.
5. Document a root cause analysis.

## What you read

- https://grafana.com/docs/loki/latest/ — Loki overview, especially LogQL.
- https://grafana.com/docs/loki/latest/send-data/promtail/ — Promtail configuration.

## What you do

See `exercises.md` for logging setup, then `capstone.md` for the scenario.

## How you know you're done

See `validation.md`.
