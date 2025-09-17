# 🏗️ Infrastructure Setup Guide (Self-Host)

## Accessing APISIX

Verify components:

```bash
kubectl -n apisix get pods
kubectl -n apisix get svc
```

Port-forward the Admin API:

```bash
kubectl -n apisix port-forward svc/apisix-admin 9180:9180
```

Fetch the admin API key and test:

```bash
APISIX_KEY=$(kubectl -n apisix get secret apisix -o jsonpath='{.data.admin.key}' | base64 -d)
curl -s http://127.0.0.1:9180/apisix/admin/routes -H "X-API-KEY: ${APISIX_KEY}"
```

Notes:

- Do not expose Admin API publicly.
- APISIX Ingress Controller reconciles Kubernetes Ingress resources automatically.

## Self-Host Deployment (Summary)

Use the bundle under `infra/host-self/`:

```bash
cd infra/host-self
chmod +x scripts/*.sh
./scripts/bootstrap-k0s.sh
kubectl apply -k manifests/base
export TUNNEL_TOKEN=YOUR_TUNNEL_TOKEN && ./scripts/deploy-cloudflared.sh
./scripts/deploy-apisix.sh
export ST_DB_URI="postgresql://USER:PASSWORD@DB_HOST:5432/supertokens" CHART_PATH="/path/to/supertokens/helm-chart" && ./scripts/deploy-supertokens.sh
kubectl apply -k manifests/supertokens
```

## Troubleshooting

See `docs/operations/troubleshooting.md` (single-environment; namespaces used: `platform`, `apisix`, `auth`).
