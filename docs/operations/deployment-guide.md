# Deployment Guide

## Overview

This project uses a single self-hosted Kubernetes environment. Infrastructure is deployed directly on the host using the `infra/host-self/` bundle (no GitOps/Argo CD).

## Prerequisites

- A Linux host with sudo
- Internet egress
- kubectl and Helm are installed by `infra/host-self/scripts/bootstrap-k0s.sh`

## Deploy Steps (Self-host)

```bash
cd infra/host-self

# 1) Install k0s + kubeconfig + helm
chmod +x scripts/*.sh
./scripts/bootstrap-k0s.sh

# 2) Base namespaces/policies
kubectl apply -k manifests/base

# 3) Cloudflared (Cloudflare Tunnel)
export TUNNEL_TOKEN=YOUR_TUNNEL_TOKEN
./scripts/deploy-cloudflared.sh

# 4) APISIX (Gateway + Ingress Controller)
./scripts/deploy-apisix.sh

# 5) SuperTokens (Auth service)
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

- Do not commit secrets or rendered manifests.
- DNS: point domains (e.g., auth.puchi.io.vn) to the APISIX entry via Cloudflare Tunnel.
