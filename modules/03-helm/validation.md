# Module 3 — Validation

## Hard gates

- [ ] `helm lint` clean on api, frontend, umbrella.
- [ ] From a fresh `kubectl delete namespace bootcamp`, you can `helm upgrade --install` and have a working app within ~3 minutes.
- [ ] Both `values-dev.yaml` and `values-staging.yaml` produce the differences you intended (verified via `helm template` diff).
- [ ] `helm rollback` works end-to-end.
- [ ] Postgres data survives a pod restart (PVC bound, not ephemeral).

## Concept gates

You can explain, on demand:

- The order in which Helm evaluates templates (which directory, which files first, when `_helpers.tpl` is parsed).
- The difference between `helm install` and `helm upgrade --install`.
- What `--atomic` does and when to use it.
- The semantics of `Chart.yaml` `appVersion` vs `version`.
- Why you'd use a subchart vs. duplicating templates.
- How Helm tracks releases (which Secret it stores them in).

## Done-when

- App is up and you can hit it from a browser.
- All work committed to git (no chart secrets, no built `*.tgz`).
- You can produce a deployment diff between two values files in under 60 seconds.
