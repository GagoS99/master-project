# Capstone — A Broken System

## The setup

You have a working app. Metrics flowing. Logs flowing. Dashboards green. Everything is fine.

Then you run:

```sh
./break-it.sh
```

The script introduces exactly one problem somewhere in the system. The script does *not* tell you what it did. You will find out by debugging.

## The rules

1. **Hypothesis before answer.** Before you look at `break-it.sh`'s source, you write `hypothesis.md` (template below). Minimum: what you think broke, why you think it, the metric or log that suggests it.
2. **No guessing changes.** You can `kubectl get`, `kubectl describe`, `kubectl logs`, `kubectl exec`. You may *not* `kubectl edit` or `kubectl apply` to "see if it fixes it." Every change you make is *after* you've described what you expect it to do.
3. **The AI is locked.** The AI for this module **will not give problem-specific hints** until your `hypothesis.md` is committed. Read `AGENT.md`.
4. **Time the exercise.** Note when you started. Stop when the system is back to healthy *and* you've written `resolution.md`. Typical: 1-3 hours.
5. **Don't read `break-it.sh` until you've fixed it.** That's the answer key.

## The fixed-it criteria

You're done when:
- The frontend renders a non-empty list of items.
- `kubectl get all -n bootcamp` shows everything `Running` / `Healthy`.
- Your Module 5 dashboard shows error rate back at baseline.
- `argocd app list` shows everything `Synced`.

## Hypothesis template — write this *first*

Save to `modules/06-logging-capstone/hypothesis.md`:

```md
# Hypothesis

**Timestamp started:** YYYY-MM-DD HH:MM

## What I observed first
<the symptom that made you notice — pasted dashboard panel description or log line>

## Where I looked
<which `kubectl` commands you ran, which dashboard panels, which LogQL queries>

## What I think broke
<one sentence>

## Why I think that
<the specific evidence: a metric value, a log line, a `describe` output, a YAML diff>

## What I plan to change to verify
<the smallest reversible action that will confirm or refute>
```

## Resolution template — write this *after*

Save to `modules/06-logging-capstone/resolution.md`:

```md
# Resolution

**Time to fix:** Xh Ym

## What actually broke
<one paragraph, accurate>

## How I found it
<the breadcrumb trail: metric → log → kubectl → diff>

## What I changed to fix it
<the exact commit / kubectl command / value>

## What I'd add to make this faster next time
<a dashboard panel? An alert? A runbook entry?>

## How my hypothesis compared to reality
<honest evaluation>
```

## Re-running

You can re-run `./break-it.sh` for a different scenario. The script randomly picks from a list (see `AGENT.md` for what's allowed in the random pool).

To reset between runs: `./break-it.sh --restore` undoes the previous break.

## When you're truly stuck

After 90 minutes without progress, you may type **"I'm stuck, draft it"** to the AI. It will then narrow the search space — not give the answer, but eliminate the obviously-wrong avenues.

After 180 minutes, you may read `break-it.sh`. But finish `resolution.md` honestly.
