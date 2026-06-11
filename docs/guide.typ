// DevOps Bootcamp — Tutorial-Hell Recovery Edition
// Rich curriculum PDF. Compile with: typst compile docs/guide.typ pdf/guide.pdf

#set document(
  title: "DevOps Bootcamp — Tutorial-Hell Recovery Edition",
  author: "Bootcamp curriculum",
)

#set page(
  paper: "a4",
  margin: (top: 2.2cm, bottom: 2.2cm, left: 2.4cm, right: 2.4cm),
  numbering: "1",
  header: context {
    if counter(page).get().first() > 2 {
      align(right, text(size: 8pt, fill: gray, "DevOps Bootcamp · Tutorial-Hell Recovery"))
    }
  },
)

#set text(font: "New Computer Modern", size: 10.5pt, lang: "en")
#set par(justify: true, leading: 0.65em)
#show heading: set block(above: 1.4em, below: 0.8em)
#show heading.where(level: 1): set text(size: 22pt, weight: "bold")
#show heading.where(level: 2): set text(size: 15pt, weight: "bold")
#show heading.where(level: 3): set text(size: 12pt, weight: "bold")

#show link: set text(fill: rgb("#2c5fa0"))
#show raw.where(block: false): set text(font: "DejaVu Sans Mono", size: 9pt)
#show raw.where(block: true): block.with(
  fill: rgb("#f5f5f7"),
  inset: 10pt,
  radius: 4pt,
  width: 100%,
)
#show raw.where(block: true): set text(font: "DejaVu Sans Mono", size: 8.7pt)

// === Helper boxes ===
#let sidebar(title, body, color: rgb("#0a6d40")) = block(
  fill: color.lighten(88%),
  stroke: (left: 3pt + color),
  inset: 10pt,
  radius: (right: 3pt),
  width: 100%,
)[
  #text(weight: "bold", fill: color, size: 9.5pt, upper(title))
  #v(4pt)
  #body
]

#let warning(body) = sidebar("warning", body, color: rgb("#b8331f"))
#let cost(body) = sidebar("cost note", body, color: rgb("#a86a00"))
#let aitip(body) = sidebar("ai guardrail", body, color: rgb("#5a2ea1"))
#let docs-link(body) = sidebar("read the docs", body, color: rgb("#2c5fa0"))

// === Cover page ===
#align(center)[
  #v(4cm)
  #text(size: 32pt, weight: "bold")[DevOps Bootcamp]
  #v(0.3em)
  #text(size: 16pt, fill: gray)[Tutorial-Hell Recovery Edition]
  #v(2cm)
  #text(size: 11pt)[
    A 4–6 week, AWS-free-tier curriculum that takes you \
    from "I watched the course" to "I built and operated it." \
  ]
  #v(3cm)
  #table(
    columns: (auto, auto),
    stroke: none,
    align: (right, left),
    inset: 6pt,
    text(weight: "bold")[Cloud:], [AWS (us-east-1)],
    text(weight: "bold")[Cluster:], [k3s on EC2 t3.micro],
    text(weight: "bold")[GitOps:], [ArgoCD],
    text(weight: "bold")[Observability:], [Prometheus, Grafana, Loki],
    text(weight: "bold")[IaC:], [Terraform + Helm],
    text(weight: "bold")[Cost (with discipline):], [\$0/month],
  )
  #v(3cm)
  #text(size: 9pt, fill: gray)[
    Open `pdf/guide.pdf` on a tablet. \
    Work in the repo on your laptop. \
    Paste `AGENT_SYSTEM_PROMPT.md` into your AI before every session.
  ]
]
#pagebreak()

// === TOC ===
#outline(title: "Table of Contents", indent: auto, depth: 2)
#pagebreak()

// === Foreword ===
= How to use this guide

#sidebar("read first", [
  This is the *primary* curriculum. The repo's `modules/NN-*/` directories are companions: they hold the *exercises*, the *validation checklists*, and the per-module AI guardrails. The PDF teaches; the repo is where you do.
])

You picked up this guide because you've finished N tutorials and remember M of them, where M is alarmingly close to zero. Tutorials teach *recognition*, not *recall*. Recall comes from building and breaking your own systems. This is a recall machine.

The structure:

#table(
  columns: (auto, 1fr, auto),
  stroke: 0.5pt + gray,
  inset: 7pt,
  align: (center, left, center),
  [*\#*], [*Module*], [*Weeks*],
  [0], [Linux fundamentals refresher], [0.5],
  [1], [AWS foundations + Terraform], [1.0],
  [2], [k3s cluster on EC2], [0.5],
  [3], [Helm packaging], [1.0],
  [4], [ArgoCD + GitOps], [1.0],
  [5], [Monitoring (Prometheus + Grafana)], [1.0],
  [6], [Logging + capstone debug scenario], [1.0],
)

== The deal with the AI

This bootcamp assumes you'll use an AI assistant. It also assumes that letting the AI write your Terraform and YAML will produce the same outcome as the last 12 tutorials: you'll feel productive and remember nothing.

So the AI is *constrained*. Before each session, paste `AGENT_SYSTEM_PROMPT.md` into your AI. It will:

- Ask questions before answering.
- Point you at docs instead of writing code.
- Escalate hints only when you ask again.
- Refuse to write code until you explicitly type *"I'm stuck, draft it."*

#aitip[
  The AI's job is to make you faster *at thinking*, not faster at producing artifacts. Every line of code in this repo must be typed by you.
]

== The deal with money

Everything in this bootcamp fits inside the AWS free tier *if you stay disciplined*. The main risk is leaving things running.

#cost[
  *End every session* with `./scripts/check-free-tier.sh`. \
  *Walk away for > 48 hours?* `./scripts/destroy-all.sh`. \
  *Set a \$5/mo budget alarm on day one.* Walk-through in `docs/aws-account-setup.md`.
]

== The architecture you'll end up with

```
                              ┌──────────────────┐
                              │  Your Laptop     │
                              │  (kubectl, helm, │
                              │   terraform, gh) │
                              └────────┬─────────┘
                                       │ ssh, kubectl, git push
                                       ▼
       ┌──────────────────── AWS  us-east-1 ─────────────────────┐
       │                                                         │
       │   VPC 10.0.0.0/16                                       │
       │   ┌──────────────────────────────────────────────────┐  │
       │   │  Public Subnet 10.0.1.0/24                       │  │
       │   │  ┌─────────────────────────────────────────────┐ │  │
       │   │  │  EC2 t3.micro (Ubuntu 22.04, k3s)           │ │  │
       │   │  │   ├─ argocd     (namespace)                 │ │  │
       │   │  │   ├─ bootcamp   (api, frontend, postgres)   │ │  │
       │   │  │   ├─ monitoring (prom, grafana, alertmgr)   │ │  │
       │   │  │   └─ loki       (loki, promtail)            │ │  │
       │   │  └─────────────────────────────────────────────┘ │  │
       │   └──────────────────────────────────────────────────┘  │
       │     ▲                                                   │
       │     │ Internet Gateway                                  │
       │   ──┴──                                                 │
       │                                                         │
       │   S3: tfstate bucket   DynamoDB: tfstate lock           │
       └─────────────────────────────────────────────────────────┘
                                       ▲
                                       │ pulls desired state
                              ┌────────┴─────────┐
                              │  GitHub          │
                              │  (this repo)     │
                              └──────────────────┘
```

== One more thing

Do the modules in order. Module 4 (ArgoCD) assumes you understand Helm from Module 3. Module 5 (monitoring) assumes you understand Module 4's GitOps loop. Skipping ahead because something looks more fun is how you ended up here in the first place.

#pagebreak()

= Module 0 — Linux Fundamentals Refresher

#table(columns: (auto, 1fr), stroke: none, inset: 4pt,
  [*Time:*], [\~0.5 week (4–6 hours)],
  [*Free-tier risk:*], [None (entirely local)],
  [*Repo dir:*], [`modules/00-linux/`],
)

== Why this module exists

You will spend the rest of the bootcamp logging into a Linux box, reading logs, and debugging systemd units. If your fingers don't already know `journalctl`, `ss`, and `systemctl status` by reflex, every later module triples in difficulty.

This is not "learn Linux." It's "rebuild the muscle for the seven commands you'll use 200 times in the next 6 weeks."

== Concepts

=== systemd in one paragraph

systemd is the init system on every distro you'll touch. Each long-running service is described by a *unit file* (`.service`, `.timer`, etc.). You start, stop, enable (boot-time), and inspect units with `systemctl`. Each unit's stdout/stderr goes to `journald`, queryable with `journalctl`.

=== The seven commands

#table(columns: (auto, 1fr), stroke: 0.5pt + gray, inset: 6pt,
  [`systemctl status <unit>`], [Is it running? Why or why not?],
  [`systemctl restart <unit>`], [Stop and start.],
  [`systemctl enable --now <unit>`], [Start it, and on every boot.],
  [`journalctl -u <unit> -n 100`], [Last 100 lines from this unit.],
  [`journalctl -u <unit> -p err`], [Only errors from this unit.],
  [`ss -tlnp`], [What's listening, by which process.],
  [`ps auxf`], [Process tree with details.],
)

== What you'll do

A condensed view of `modules/00-linux/exercises.md`:

#enum(
  [Inspect your Linux VM (OS, RAM, CPU, listening ports).],
  [Drive `systemctl` and `journalctl` on the `sshd` service.],
  [Write a `hellotick.service` unit that runs a script every 10 seconds for 5 minutes.],
  [Deliberately break the unit (bad ExecStart). Use `journalctl` to find the cause.],
  [Networking: `curl -v`, `dig`, `ss -tlnp`, run a one-liner Python HTTP server.],
  [SSH ergonomics: keypair, `~/.ssh/config` aliases, `scp`/`rsync`.],
)

#docs-link[
  systemd: #link("https://systemd.io/")[systemd.io] · Arch wiki on systemd: #link("https://wiki.archlinux.org/title/Systemd")[wiki.archlinux.org/title/Systemd] (best per-feature reference even on non-Arch)
]

#aitip[
  *Module 0 AI rule:* the AI may *not* write commands for you in this module. Even on "I'm stuck, draft it" the most it produces is a skeleton with `# fill this in` placeholders. The whole point is finger memory.
]

== Validation

You're done when, without notes, you can:

- Tell me whether `sshd` is running and enabled, with one command each.
- Show only the errors from `sshd` since boot in one command.
- List every listening port and the process that opened it.
- Write a systemd unit from a blank file with `Restart=on-failure` and a `network-online.target` dependency.

#pagebreak()

= Module 1 — AWS Foundations + Terraform

#table(columns: (auto, 1fr), stroke: none, inset: 4pt,
  [*Time:*], [\~1 week (10–15 hours)],
  [*Free-tier risk:*], [Low if you stay on t3.micro and tear down],
  [*Repo dir:*], [`infra/terraform/`],
)

== Why this module exists

You will provision a small AWS footprint with hand-written Terraform. Not via console, not via someone's giant module. You will know exactly what every resource is and why it's there. The next four modules sit on top of this footprint.

== Concepts

=== The Terraform loop

#raw("write HCL  →  terraform init  →  terraform plan  →  read plan  →  terraform apply  →  state updated", block: false)

Repeat. The *plan* is the only meaningful sanity check between you and unintended changes. Reading it is a skill — the diff syntax (`+`, `-`, `~`) tells you create / destroy / in-place modify. A *replace* (`-/+`) means the resource is destroyed and recreated — sometimes this is fine, sometimes catastrophic.

=== Remote state

Local state (`terraform.tfstate`) is fine for solo learning but breaks the moment a teammate joins. The standard pattern is *S3 + DynamoDB*: S3 holds the state file (versioned, encrypted), DynamoDB holds a lock so two `apply`s can't race.

There's a chicken-and-egg problem: the bucket that holds your state can't itself be created by the Terraform that uses the bucket. Solution: a small bootstrap script (`scripts/bootstrap-tf-backend.sh`) creates the bucket + table by hand, once.

=== The minimum viable AWS footprint

```
VPC (10.0.0.0/16)
├── Public Subnet (10.0.1.0/24, us-east-1a)
│   └── EC2 t3.micro
│       ├── Security Group: 22, 6443 from your IP only
│       └── IAM Instance Profile: read-only access to tfstate bucket
├── Internet Gateway
└── Route Table: 0.0.0.0/0 → IGW
```

That's *seven* primary resources plus their associations. Nothing else.

#cost[
  *Avoid:* NAT Gateway (\$32/mo), ALB/NLB (\$22+/mo), EKS (\$72/mo), RDS (easy to misconfigure into a charge), Route 53 hosted zone (\$0.50/mo). See `docs/free-tier-budget.md` for the full list.
]

== What you'll do

#enum(
  [Configure AWS CLI with a `bootcamp` profile. Set a \$5 budget alarm.],
  [Bootstrap state backend (S3 + DynamoDB) via the helper script.],
  [Write `versions.tf`, `providers.tf`, `backend.tf`.],
  [Write the VPC + subnet + IGW + route table by hand.],
  [Write the security group + key pair + EC2 instance.],
  [Write the IAM role + instance profile.],
  [Refactor into modules: `vpc/`, `ec2/`, `iam/`.],
  [Destroy. Re-apply. Confirm idempotency.],
)

#warning[
  Do *not* `terraform apply -auto-approve` while learning. Read every line of the plan. The day you stop reading plans is the day you delete your prod VPC.
]

#docs-link[
  Terraform intro: #link("https://developer.hashicorp.com/terraform/intro")[hashicorp.com/terraform/intro] · VPC concepts: #link("https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html")[docs.aws.amazon.com/vpc] · Remote state: #link("https://developer.hashicorp.com/terraform/language/state/remote")[terraform/language/state/remote]
]

== Validation

`terraform plan` on a freshly-applied stack returns "No changes." `terraform state list` shows every resource and you can explain each. You can SSH to the EC2 via a config alias. `aws sts get-caller-identity` *from inside the EC2* returns the IAM role.

#pagebreak()

= Module 2 — k3s Cluster on EC2

#table(columns: (auto, 1fr), stroke: none, inset: 4pt,
  [*Time:*], [\~0.5 week],
  [*Free-tier risk:*], [Low — same EC2 as Module 1],
  [*Repo dir:*], [`infra/terraform/` (cloud-init) + remote ops on the EC2],
)

== Why k3s instead of EKS

EKS control plane bills you \$0.10/hour, about \$72/month. Not free. k3s is a single-binary, production-grade Kubernetes distribution (used at the edge, in CI, in IoT). It runs comfortably on a t3.micro at our scale and you'll learn *real* Kubernetes — Deployments, Services, Pods, ConfigMaps, NetworkPolicies — without the bill.

In an interview you can say: "I built and operated a k3s cluster from bare cloud. I know what the control plane components do because I started them."

== Concepts

=== What k3s ships with

```
k3s server (single binary)
├── kube-apiserver
├── kube-controller-manager
├── kube-scheduler
├── kubelet (embedded)
├── containerd (embedded)
├── CoreDNS               ← keep
├── traefik (ingress)     ← disable for bootcamp
├── servicelb (klipper)   ← disable (no real LB on free tier)
├── local-path provisioner← keep (storage class for Postgres)
└── metrics-server        ← keep (kubectl top)
```

=== The flow

`Terraform` provisions the EC2 with `cloud-init` user data → cloud-init installs k3s on first boot → k3s writes `kubeconfig` to `/etc/rancher/k3s/k3s.yaml` → you SCP it down, rewrite `server:` to the public IP, point `KUBECONFIG` at it from your laptop.

== What you'll do

#enum(
  [Modify EC2's cloud-init to install k3s (pinned version) with `--disable servicelb,traefik` and `--tls-san <public-ip>`.],
  [`terraform apply` (forces EC2 re-creation if it already existed).],
  [SCP kubeconfig down, fix `server:` field, set `KUBECONFIG`.],
  [`kubectl get nodes` from laptop — Ready.],
  [Write a scratch `nginx-test.yaml` (Deployment + NodePort Service) by hand. Apply, browse to the node port, delete.],
  [Break things deliberately: bad image tag, oversize resource request, NetworkPolicy blocking egress.],
)

#aitip[
  When the engineer reports a workload issue, your AI is configured to first ask: "what does `kubectl describe` say? what about `kubectl get events --sort-by=.lastTimestamp`?" If you haven't run those, that's the answer.
]

#docs-link[
  k3s: #link("https://docs.k3s.io/")[docs.k3s.io] · K8s Deployments: #link("https://kubernetes.io/docs/concepts/workloads/controllers/deployment/")[k8s/Deployment] · K8s Services: #link("https://kubernetes.io/docs/concepts/services-networking/service/")[k8s/Service]
]

== Validation

`kubectl get nodes` from laptop returns `Ready`. `kubectl get pods -A` shows only system pods after you've cleaned up. You can destroy + recreate the EC2 via Terraform and end up with a working cluster (same cloud-init).

#pagebreak()

= Module 3 — Helm Packaging

#table(columns: (auto, 1fr), stroke: none, inset: 4pt,
  [*Time:*], [\~1 week],
  [*Free-tier risk:*], [None],
  [*Repo dir:*], [`infra/helm/`],
)

== Why Helm

You have raw YAML. You've felt the pain of copy-pasting between dev and staging and producing drift. Helm fixes it with templates and values: one source of truth, many environments, idempotent installs.

== Concepts

=== A chart is...

```
api/
├── Chart.yaml              ← name, version, appVersion, dependencies
├── values.yaml             ← defaults
├── values-dev.yaml         ← env-specific overrides
├── templates/
│   ├── _helpers.tpl        ← named templates (e.g., labels block)
│   ├── deployment.yaml     ← Go-template ⇒ K8s YAML
│   ├── service.yaml
│   └── configmap.yaml
└── tests/                  ← `helm test` runs these as Jobs
```

`helm template` evaluates the templates against the values and prints the resulting YAML. Use it constantly while developing.

=== The install loop

#raw("helm lint  →  helm template  →  helm install --dry-run  →  helm upgrade --install  →  helm history  →  helm rollback (if needed)", block: false)

`helm upgrade --install` is idempotent — use it instead of `helm install` so your script can be re-run.

=== Subcharts and umbrellas

An umbrella chart depends on other charts (local via `file://` or remote via a Helm repo). Values for subcharts live under a key named after the subchart. This is how you'll bundle api + frontend + postgres into one release.

== What you'll do

#enum(
  [Build & push images for `app/api` and `app/frontend` (Docker Hub is fine for the bootcamp).],
  [Hand-write a chart for the API: Deployment, Service, ConfigMap, Secret reference.],
  [Install via `helm upgrade --install` into a `bootcamp` namespace. Install Postgres via the Bitnami chart.],
  [Repeat for the frontend.],
  [Build an umbrella chart that depends on both + Postgres.],
  [Create `values-dev.yaml` and `values-staging.yaml` with different `replicaCount` and `resources`.],
  [Test a rollback: deploy a bad image tag, `helm rollback`, watch recovery.],
)

#warning[
  Never tag images `latest`. Always use a concrete tag (e.g., `v1.0.0`). Latest breaks rollback and reproducibility — you can't roll back to a specific build if every deploy points at "whatever was latest at that moment."
]

#docs-link[
  Helm charts: #link("https://helm.sh/docs/topics/charts/")[helm.sh/docs/topics/charts] · Template guide: #link("https://helm.sh/docs/chart_template_guide/")[helm.sh/docs/chart_template_guide]
]

== Validation

`helm lint` clean on all charts. From a fresh `kubectl delete namespace bootcamp`, `helm upgrade --install` produces a working app in ~3 minutes. `helm template` outputs have no unresolved `{{ ... }}`. The frontend in a browser lists items from the API.

#pagebreak()

= Module 4 — ArgoCD + GitOps

#table(columns: (auto, 1fr), stroke: none, inset: 4pt,
  [*Time:*], [\~1 week],
  [*Free-tier risk:*], [None],
  [*Repo dir:*], [`infra/argocd/`],
)

== Why GitOps

Push-from-laptop is fine for solo learning. It breaks at the first teammate. GitOps inverts the direction: *git is the source of truth, the cluster pulls.* Auditable. Reproducible. Roll-back-able with `git revert`.

== Concepts

=== The reconciliation loop

```
You             Git                  ArgoCD                Cluster
 │              │                      │                     │
 │── PR ──────▶│                      │                     │
 │              │── webhook/poll ────▶│                     │
 │              │                      │── diff ──────────▶ │
 │              │                      │◀──── desired-vs-actual
 │              │                      │── apply changes ─▶ │
 │              │                      │                     │
```

ArgoCD continuously diffs Git's desired state against the cluster's actual state. When they diverge, it shows `OutOfSync`. You sync (manual) or it auto-syncs (`syncPolicy.automated`).

=== App-of-apps

One root `Application` points at a directory of *more* `Application` manifests. ArgoCD creates those child Applications, which create the actual workloads. Why: one bootstrap command unfolds your entire platform.

```
root (Application)
├── api          (Application → infra/helm/api)
├── frontend     (Application → infra/helm/frontend)
├── postgres     (Application → bitnami/postgresql)
├── monitoring   (Application → kube-prometheus-stack)
└── loki         (Application → grafana/loki-stack)
```

=== The three flags everyone gets wrong on day one

#table(columns: (auto, 1fr), stroke: 0.5pt + gray, inset: 6pt,
  [`automated.prune`], [Delete resources in cluster when removed from Git. Powerful and dangerous — enable only after the App is stable.],
  [`automated.selfHeal`], [Revert manual `kubectl edit`s in the cluster. Safe-ish; turn on early.],
  [`syncOptions: [CreateNamespace=true]`], [Lets the sync create the destination namespace. Always pair with `destination.namespace`.],
)

== What you'll do

#enum(
  [Install ArgoCD via Helm (NodePort, no LB, no Ingress yet).],
  [Get initial admin password, rotate it.],
  [Bootstrap root Application by hand.],
  [Create child Applications for `api`, `frontend`, `postgres`.],
  [Delete your prior `helm install`s — ArgoCD is the new owner.],
  [Drive a change via PR. Watch sync.],
  [Manually `kubectl edit` the cluster. Watch ArgoCD detect drift. Sync to recover.],
  [Enable `selfHeal: true`. Watch it auto-revert.],
  [Enable `prune: true`. Remove a Service from Git, watch it delete in the cluster.],
)

#warning[
  Do *not* enable `prune` and `selfHeal` together on day one. Start manual. Promote to `selfHeal`. Then add `prune` once you've watched drift behavior with your own eyes.
]

#docs-link[
  ArgoCD getting started: #link("https://argo-cd.readthedocs.io/en/stable/getting_started/")[argo-cd.readthedocs.io/getting_started] · App-of-apps: #link("https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/")[argo-cd/cluster-bootstrapping] · GitOps principles: #link("https://opengitops.dev/")[opengitops.dev]
]

== Validation

`argocd app list` shows root + 3 children, all Synced and Healthy. A merged PR produces a sync without you. Manual drift is auto-reverted. No `helm` releases of the bootcamp app exist outside ArgoCD.

#pagebreak()

= Module 5 — Monitoring (Prometheus + Grafana)

#table(columns: (auto, 1fr), stroke: none, inset: 4pt,
  [*Time:*], [\~1 week],
  [*Free-tier risk:*], [Low (EBS for PVCs — keep small)],
  [*Repo dir:*], [`observability/prometheus/`, `observability/grafana/`],
)

== Why monitoring

You shipped. You don't know if it's working. Monitoring fixes that.

== Concepts

=== The four golden signals (Google SRE book)

#table(columns: (auto, 1fr, 1fr), stroke: 0.5pt + gray, inset: 6pt,
  [*Signal*], [*What*], [*Sample PromQL*],
  [Traffic], [Requests per second], [`sum(rate(http_request_duration_seconds_count[5m]))`],
  [Errors], [Error rate or ratio], [`sum(rate(...{status=~"5.."}[5m])) / sum(rate(...[5m]))`],
  [Latency], [p50 / p95 / p99], [`histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))`],
  [Saturation], [How "full" the system is], [`container_cpu_usage_seconds_total / cpu_quota`],
)

=== The Prometheus Operator's CRDs

#table(columns: (auto, 1fr), stroke: 0.5pt + gray, inset: 6pt,
  [`ServiceMonitor`], [Tells Prometheus to scrape a Service. Selector matches Service labels.],
  [`PodMonitor`], [Same but for Pods without a Service.],
  [`PrometheusRule`], [Recording rules and alerting rules.],
  [`Alertmanager`], [Top-level Alertmanager config.],
)

You install all of this with one chart: `kube-prometheus-stack`.

=== What `rate()` actually computes

`rate(counter[5m])` = average increase per second over the last 5 minutes. The counter *must* be monotonically increasing (resets are handled internally). For dashboards: use `rate()` with a window 2–4× your scrape interval. For sub-second analysis: don't, sample more often instead.

== What you'll do

#enum(
  [Add `kube-prometheus-stack` as a new ArgoCD Application.],
  [Constrain values: NodePort (no LB), 5 GiB Prometheus storage, 5-day retention.],
  [Write a `ServiceMonitor` template in the api chart, guarded by `.Values.metrics.enabled`.],
  [Verify the API target shows `UP` in Prometheus Targets page.],
  [Run a small traffic generator in the background to fill dashboards.],
  [Build a custom dashboard: 5 panels covering traffic, p50/p95/p99 latency, error rate, CPU, memory.],
  [Export as JSON, store in `observability/grafana/dashboards/`, provision via ConfigMap so it survives Grafana restarts.],
  [Write a `PrometheusRule` for `APIHighErrorRate`. Make it fire by scaling Postgres to 0. Recover.],
)

#aitip[
  The AI in this module will not draft Grafana dashboard JSON from scratch — the schema is too large to do safely. It will instead point you at the JSON Model view of a community dashboard and ask you to adapt.
]

#docs-link[
  Prometheus practices: #link("https://prometheus.io/docs/practices/instrumentation/")[prometheus.io/practices/instrumentation] · Prometheus Operator: #link("https://prometheus-operator.dev/docs/")[prometheus-operator.dev] · SRE Monitoring chapter: #link("https://sre.google/sre-book/monitoring-distributed-systems/")[sre.google/sre-book]
]

== Validation

Prometheus Targets shows your API `UP`. Custom dashboard renders with real moving data. Dashboard JSON in git survives a Grafana pod delete. `APIHighErrorRate` alert can be made to fire and clear by your own action.

#pagebreak()

= Module 6 — Logging + Capstone

#table(columns: (auto, 1fr), stroke: none, inset: 4pt,
  [*Time:*], [\~1 week],
  [*Free-tier risk:*], [Low (Loki PVC)],
  [*Repo dir:*], [`observability/loki/`, `modules/06-logging-capstone/`],
)

This module is two distinct phases: a logging-stack setup, then a *capstone* debugging exercise — the most important hour of the bootcamp.

== Phase A: Logging

=== Concepts

Loki is "Prometheus for logs": indexes by *labels*, not by full-text. This makes it cheap and fast for the common case (filter by namespace/pod/job, then grep). It makes high-cardinality fields (like user IDs as labels) expensive — keep them in the log *body*, not in labels.

LogQL is to Loki what PromQL is to Prometheus:

```
{namespace="bootcamp", pod=~"api.*"} |~ "(?i)error"
   └──── label selector ────┘       └── line filter ──┘

sum by (pod) (count_over_time({namespace="bootcamp"} |= "ERROR" [5m]))
```

=== What you'll do

#enum(
  [Install `loki-stack` (loki + promtail) via ArgoCD.],
  [Provision Grafana data source for Loki via ConfigMap.],
  [Practice LogQL in Grafana Explore.],
  [Build a row of panels in your Module 5 dashboard: top = error rate metric, bottom = filtered API logs.],
)

== Phase B: The Capstone

You run `./modules/06-logging-capstone/break-it.sh`. It picks one of five scenarios at random and breaks the system. You diagnose using only the dashboards and `kubectl`.

=== The rules

#enum(
  [Write `hypothesis.md` *before* attempting any fix. The AI refuses to give problem-specific hints until your hypothesis is committed.],
  [No `kubectl edit` to "see if it fixes it" — every change is preceded by a description of what you expect it to do.],
  [Don't read `break-it.sh`'s source until you've fixed it. The AI is also instructed not to read it.],
  [Time the exercise. Typical: 1–3 hours.],
  [After the fix, write `resolution.md`: root cause, breadcrumb trail, what you'd add to catch this in 30 seconds next time.],
)

#warning[
  This is the only module where the AI's hint policy is *more* restrictive than your default. It is doing this on purpose. The capstone is the closest thing to a 2am page you can simulate without one.
]

=== The scenario pool

The break script picks one of these (your AI knows the categories but not the specifics):

#table(columns: (auto, 1fr), stroke: 0.5pt + gray, inset: 6pt,
  [*Configuration*], [A Secret/ConfigMap value is wrong.],
  [*Image*], [Wrong image, wrong tag, image-pull failure.],
  [*Network*], [A NetworkPolicy or DNS issue blocks traffic.],
  [*Capacity*], [Resource limits too tight, replicas too low, node pressure.],
  [*Data layer*], [Database is down, unreachable, or the schema is gone.],
)

=== Done-when

Frontend renders a non-empty list. `kubectl get all -n bootcamp` clean. Dashboard back to baseline. `argocd app list` Synced. `resolution.md` committed.

#pagebreak()

= Closing: the exit checklist

You've finished the bootcamp when you can answer YES, without notes, to each of these:

#enum(
  [I can `terraform apply` a VPC + EC2 from scratch and explain every resource on the plan.],
  [I can SSH to the node, inspect a misbehaving systemd service, and find the cause in logs.],
  [I can `helm install` my app from clean and explain what every value controls.],
  [I can break ArgoCD sync intentionally and diagnose drift via the UI and CLI.],
  [I can write a PromQL query that distinguishes "API is slow" from "API is down."],
  [I can grep Loki for a request's logs and tell the story end-to-end.],
  [I can destroy everything with one command and confirm \$0 ongoing spend.],
)

If all seven are yes: you're out of tutorial hell. You're an apprentice operator.

If any one is shaky: that's where you go back. The modules don't expire.

#v(2cm)

#align(center)[
  #text(size: 9pt, fill: gray)[
    Built for the engineer who watched the courses and wants to actually remember. \
    Repo: this directory. PDF: `pdf/guide.pdf`. AI prompt: `AGENT_SYSTEM_PROMPT.md`.
  ]
]
