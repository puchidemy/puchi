# Troubleshooting (Self-Host)

This guide focuses on a single self-host Kubernetes cluster with these namespaces:

- `platform`: Cloudflared (Cloudflare Tunnel)
- `apisix`: APISIX Gateway + Ingress Controller
- `auth`: SuperTokens (authentication service)

## Basics

```bash
# Cluster status
kubectl get nodes
kubectl get ns

# Namespaces of interest
kubectl -n platform get pods,svc
kubectl -n apisix get pods,svc
kubectl -n auth get pods,svc

# Describe & logs
kubectl -n <ns> describe pod <pod>
kubectl -n <ns> logs -f <pod>            # or deployment/<name>

# Events (latest first)
kubectl -n <ns> get events --sort-by='.lastTimestamp'
```

## Cloudflared (namespace: platform)

Symptoms:

- Pod CrashLoopBackOff
- Tunnel not connecting / invalid token

Checks:

```bash
kubectl -n platform get pods
kubectl -n platform logs -l app=cloudflared --tail=200
kubectl -n platform get secret cloudflared-secret -o yaml | grep -A2 TUNNEL_TOKEN || true
```

Fixes:

- Ensure `TUNNEL_TOKEN` is valid and exported before running deploy script:

```bash
export TUNNEL_TOKEN=YOUR_TUNNEL_TOKEN
infra/host-self/scripts/deploy-cloudflared.sh
```

- If stuck, recreate secret:

```bash
kubectl -n platform delete secret cloudflared-secret --ignore-not-found
infra/host-self/scripts/deploy-cloudflared.sh
```

## APISIX (namespace: apisix)

Symptoms:

- CRDs missing (errors when applying Ingress)
- Ingress not routing
- APISIX pods not ready

Checks:

```bash
kubectl -n apisix get pods,svc
kubectl get crd | grep apisix
kubectl -n apisix logs -l app.kubernetes.io/name=apisix-ingress-controller --tail=200
```

Fixes:

- Re-render and apply chart manifests:

```bash
infra/host-self/scripts/deploy-apisix.sh
```

- Wait for CRDs:

```bash
kubectl wait --for=condition=Established crd/apisixpluginconfigs.apisix.apache.org --timeout=180s || true
```

- Inspect an Ingress:

```bash
kubectl -n auth get ingress
kubectl -n auth describe ingress supertokens
```

Admin API (local only):

```bash
kubectl -n apisix port-forward svc/apisix-admin 9180:9180
APISIX_KEY=$(kubectl -n apisix get secret apisix -o jsonpath='{.data.admin.key}' | base64 -d)
curl -s http://127.0.0.1:9180/apisix/admin/routes -H "X-API-KEY: ${APISIX_KEY}"
```

## SuperTokens (namespace: auth)

Symptoms:

- Pod CrashLoopBackOff due to DB connection
- 5xx from `/auth` endpoint

Checks:

```bash
kubectl -n auth get pods,svc
kubectl -n auth logs -l app.kubernetes.io/name=supertokens --tail=200 || true
```

Fixes:

- Ensure DB URI is correct and reachable:

```bash
export ST_DB_URI="postgresql://USER:PASSWORD@DB_HOST:5432/supertokens"
export CHART_PATH="/path/to/supertokens/helm-chart"
infra/host-self/scripts/deploy-supertokens.sh
```

- Verify service and Ingress:

```bash
kubectl -n auth get svc supertokens -o yaml
kubectl -n auth get ingress supertokens -o yaml
```

## Networking

- Default NetworkPolicies in `manifests/base` deny traffic by default (adjust as needed).
- Verify endpoints and selectors:

```bash
kubectl -n <ns> get svc <name> -o yaml
kubectl -n <ns> get endpoints <name>
```

## Common Commands

```bash
# Restart deployment
kubectl -n <ns> rollout restart deployment/<name>

# Scale
kubectl -n <ns> scale deployment/<name> --replicas=0
kubectl -n <ns> scale deployment/<name> --replicas=1

# Port-forward a service
kubectl -n <ns> port-forward svc/<name> 8080:80
```

## DNS

- Point your domain(s) (e.g., `auth.puchi.io.vn`) to the Cloudflare Tunnel.
- Ensure APISIX routes traffic to the right service/namespace.
