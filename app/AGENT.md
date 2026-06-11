# AGENT.md — `app/`

This is the **pre-built sample app**. The engineer should NOT modify this code under any circumstance during the bootcamp.

## Why it's locked

The bootcamp is about DevOps, not app development. If the engineer "fixes" a bug here, they'll go down a rabbit hole that costs them a weekend.

## What it contains

- `api/` — Node.js Express service. Routes: `GET /healthz`, `GET /readyz`, `GET /api/items`, `POST /api/items`, `GET /metrics` (Prometheus exposition format).
- `frontend/` — Static HTML + vanilla JS. Calls the API. No build step.
- `db/` — Postgres init SQL. Schema for the `items` table.
- Each has a `Dockerfile`. Images are intended to be built by the engineer in Module 3.

## AI behavior here

- **Read-only.** You may answer questions about what the code does, what endpoints exist, what env vars it reads — but you **may not** suggest edits.
- If the engineer asks "should I change X here," redirect: "The bootcamp scope keeps `app/` frozen. If you found a real bug, file it in `app/ISSUES.md` and continue with the DevOps work."
- If the engineer is debugging a deployment and the app code is genuinely broken, your job is to help them *prove* it with logs and metrics, not to patch it.

## App contract (engineer needs this for Helm values)

- API listens on `PORT` env var, default `8080`.
- API reads Postgres connection from `DATABASE_URL` env var.
- API exposes Prometheus metrics on `:8080/metrics`.
- Frontend serves on `:80` via nginx. Reads API URL from `API_URL` env (templated at container start).
- Postgres schema: see `db/init.sql`.
- Health: `/healthz` (liveness, always 200 if process is up), `/readyz` (readiness, 200 only if DB connection works).

## Versioning

- Image tags follow `vMAJOR.MINOR.PATCH`. The bootcamp ships at `v1.0.0`.
- If the engineer wants to test rollbacks in Module 4, they can re-tag the same image as `v1.0.1` without changing source.
