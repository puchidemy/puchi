# Host-self bootstrap bundle

Copy this folder to the self-host machine and run the scripts below. This repo intentionally keeps infra minimal; no CI/GitOps is required for infra. Do not commit rendered YAML or secrets.

## Structure

- scripts/
  - bootstrap-k0s.sh: install k0s (single-node), kubeconfig, helm
  - deploy-cloudflared.sh: create Secret from TUNNEL_TOKEN and apply manifests
  - deploy-apisix.sh: render APISIX (incl. CRDs, ingress-controller) and apply
  - deploy-supertokens.sh: helm install SuperTokens (ClusterIP)
- manifests/
  - base/: minimal kustomize manifests (namespaces, policies, quotas)
  - supertokens/: ingress and example values for SuperTokens

## Prereqs on host

- Linux user with sudo
- Internet egress

## Quick start

```bash
# 1) Install k0s + kubectl + helm
chmod +x scripts/*.sh
./scripts/bootstrap-k0s.sh

# 2) Base namespaces/policies
kubectl apply -k manifests/base

# 3) Cloudflared (requires env)
export TUNNEL_TOKEN=YOUR_TUNNEL_TOKEN
./scripts/deploy-cloudflared.sh

# 4) APISIX (gateway + ingress-controller)
./scripts/deploy-apisix.sh

# 5) SuperTokens (set DB URI and local chart path)
export ST_DB_URI="postgresql://USER:PASSWORD@DB_HOST:5432/supertokens"
export CHART_PATH="/path/to/supertokens/helm-chart"
./scripts/deploy-supertokens.sh

# 6) Apply SuperTokens Ingress (routes via APISIX)
kubectl apply -k manifests/supertokens
```

## Verify

```bash
kubectl -n platform get pods,svc    # cloudflared
kubectl -n apisix get pods,svc      # apisix core, ingress controller, dashboard (if present)
kubectl -n auth get pods,svc        # supertokens
```

## Notes

- Keep secrets only on the host (env vars / secret stores). Do not commit.
- DNS: point domains (e.g., auth.puchi.io.vn) via Cloudflare Tunnel to APISIX.
