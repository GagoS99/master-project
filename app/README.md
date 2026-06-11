# Sample App

Pre-built. Do not modify during the bootcamp.

## Services

- `api/` — Node.js Express, port 8080. Endpoints: `/healthz`, `/readyz`, `/api/items`, `/metrics`.
- `frontend/` — Static HTML + nginx, port 80. Reads `API_URL` env at startup.
- `db/` — Postgres init SQL.

## Build (Module 3)

```sh
docker build -t bootcamp-api:v1.0.0 app/api
docker build -t bootcamp-frontend:v1.0.0 app/frontend
```

## Local smoke test (optional, before deploying to k3s)

```sh
docker network create bc
docker run -d --name pg --network bc -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=items \
  -v $(pwd)/db/init.sql:/docker-entrypoint-initdb.d/init.sql postgres:16
docker run -d --name api --network bc -p 8080:8080 \
  -e DATABASE_URL=postgres://postgres:postgres@pg:5432/items bootcamp-api:v1.0.0
docker run -d --name fe --network bc -p 8081:80 \
  -e API_URL=http://localhost:8080/api bootcamp-frontend:v1.0.0
curl localhost:8080/healthz
open http://localhost:8081
```

Teardown:

```sh
docker rm -f api fe pg && docker network rm bc
```

## Contract reference

See `AGENT.md` in this dir.
