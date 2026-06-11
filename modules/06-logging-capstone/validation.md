# Module 6 — Validation

## Logging hard gates

- [ ] Loki running, Promtail running on the node.
- [ ] Grafana shows logs from all bootcamp namespaces.
- [ ] You have a metric+log panel row that lets you see error rate and the offending logs in one screen.

## Capstone hard gates

- [ ] `hypothesis.md` is committed in git *before* any fix attempt.
- [ ] `resolution.md` is committed after the fix.
- [ ] System is back to healthy by the criteria in `capstone.md`.
- [ ] You ran at least 2 different scenarios (re-run `./break-it.sh` for variety).

## Concept gates

You can explain:

- The difference between metrics and logs: when does each lie? When is each cheaper?
- How Loki indexes data (by label) and why label cardinality matters.
- The `|=`, `!=`, `|~`, `!~` operators in LogQL.
- The `unwrap`, `rate`, `count_over_time` aggregations in LogQL.
- Why you write a hypothesis before changing things during an incident.

## Bootcamp exit checklist (revisit `MODULE_INDEX.md`)

If every box there is ticked, you're done. Run `./scripts/destroy-all.sh` and put the cluster to bed.

If a box isn't ticked, that's your next session's first task.
