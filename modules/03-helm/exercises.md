# Module 3 — Exercises

## Exercise 1 — Build and push images

You need a place to put images. Options:
- **A.** Build on the EC2 itself (it has docker via k3s containerd; you'll need to install `docker` or use `nerdctl`). Push to a local registry on the EC2.
- **B.** Build on your laptop, push to Docker Hub (free, public).
- **C.** Build on your laptop, push to ECR (free tier covers 500 MB private storage).

Recommended: **B for now** (least moving parts), revisit ECR later if you want private images.

Tasks:
1. Build `bootcamp-api:v1.0.0` and `bootcamp-frontend:v1.0.0` from `app/api` and `app/frontend`.
2. Tag them with your registry (e.g., `docker.io/<your-user>/bootcamp-api:v1.0.0`).
3. Push.
4. On the EC2, `sudo k3s crictl pull docker.io/<your-user>/bootcamp-api:v1.0.0` to verify pull works.

## Exercise 2 — Initial chart for the API

`cd infra/helm/api`.

`helm create api` generates a starter — feel free to use it, but **delete the parts you don't understand**. Better: start from `helm create` and prune until you can explain every line.

The chart should produce:
- A Deployment with configurable image, tag, replicas, resource requests/limits.
- A Service (ClusterIP) on port 8080.
- A ConfigMap for non-secret env (none for now — keep ConfigMap empty or omit).
- A Secret reference for `DATABASE_URL` (do *not* commit the secret value — use `--set` or a separate values file out of git).

Values to expose:
- `image.repository`, `image.tag`, `image.pullPolicy`.
- `replicaCount`.
- `resources.requests.{cpu,memory}` and `.limits.*`.
- `service.port`.
- `database.urlSecretName`.

Validate locally:
```sh
helm lint infra/helm/api
helm template api infra/helm/api --values infra/helm/api/values.yaml
```

## Exercise 3 — Install the API on k3s

Create the Postgres dependency *first* — easiest path:
```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install postgres bitnami/postgresql \
  --namespace bootcamp --create-namespace \
  --set auth.postgresPassword=devonly-change-me \
  --set auth.database=items \
  --set primary.persistence.size=2Gi
```

Then create the DB secret the API reads:
```sh
kubectl -n bootcamp create secret generic api-db \
  --from-literal=url='postgres://postgres:devonly-change-me@postgres-postgresql:5432/items'
```

Apply the schema (one-off Job or `kubectl exec`):
```sh
kubectl -n bootcamp exec -it postgres-postgresql-0 -- \
  psql -U postgres -d items -c "$(cat app/db/init.sql)"
```

Install the API chart:
```sh
helm upgrade --install api infra/helm/api \
  --namespace bootcamp \
  --set image.repository=docker.io/<your-user>/bootcamp-api \
  --set image.tag=v1.0.0 \
  --set database.urlSecretName=api-db
```

Verify:
```sh
kubectl -n bootcamp get all
kubectl -n bootcamp port-forward svc/api 8080:8080
curl localhost:8080/healthz
curl localhost:8080/api/items
```

## Exercise 4 — Frontend chart

Same shape as the API chart, but:
- Image: `bootcamp-frontend:v1.0.0`.
- Service port 80.
- A Service of type `NodePort` (so you can browse it from your laptop).
- Pass `API_URL` env. Choose between in-cluster DNS (`http://api.bootcamp.svc.cluster.local:8080/api`) or going through the public IP+nodeport — both have implications.

Install. Open `http://<ec2-ip>:<nodeport>` and confirm the frontend lists items.

## Exercise 5 — Umbrella chart

Create `infra/helm/umbrella/` that depends on:
- Your local `api` chart (via `file://`).
- Your local `frontend` chart (via `file://`).
- `bitnami/postgresql` (via repository).

`Chart.yaml` dependencies block. `helm dependency update` pulls the Postgres tarball.

Values file structure: top-level keys per subchart. Document this with comments.

Now you can do everything in one command:
```sh
helm upgrade --install bootcamp infra/helm/umbrella \
  --namespace bootcamp --create-namespace \
  --values infra/helm/umbrella/values.yaml
```

## Exercise 6 — Two environments

Create `values-dev.yaml` and `values-staging.yaml` (even if you only have one cluster — pretend).

Differences:
- `replicaCount`: 1 in dev, 2 in staging.
- Resource requests: smaller in dev.
- Postgres persistence size.

Confirm:
```sh
helm template bootcamp infra/helm/umbrella -f values-dev.yaml > /tmp/dev.yaml
helm template bootcamp infra/helm/umbrella -f values-staging.yaml > /tmp/staging.yaml
diff /tmp/dev.yaml /tmp/staging.yaml
```

The diff should be exactly what you intended.

## Exercise 7 — Rollback

1. Install. `helm history bootcamp -n bootcamp`.
2. Upgrade with a bad image tag (`v9.9.9`). Watch pods fail.
3. `helm rollback bootcamp 1 -n bootcamp`. Pods recover.
4. Walk through `helm history` after each step.

## Deliverables checklist

- [ ] `infra/helm/api/`, `infra/helm/frontend/`, `infra/helm/umbrella/` exist and pass `helm lint`.
- [ ] `helm upgrade --install` works from scratch on a fresh namespace.
- [ ] `helm template` output has no unresolved `{{ ... }}`.
- [ ] Frontend in a browser shows items from the API.
- [ ] You can describe what `_helpers.tpl` does in your chart.
- [ ] Secrets are not in git. Verify with `git status` and `grep -ri "devonly-change-me" infra/helm`.
