#!/usr/bin/env bash
set -euo pipefail

if [ -z "${TUNNEL_TOKEN:-}" ]; then
  echo "TUNNEL_TOKEN env is required" >&2
  exit 1
fi

kubectl apply -k ../manifests/base
kubectl get ns platform >/dev/null 2>&1 || kubectl create ns platform

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: cloudflared-secret
  namespace: platform
type: Opaque
stringData:
  TUNNEL_TOKEN: "${TUNNEL_TOKEN}"
EOF

kubectl apply -k ../../k8s/platform/cloudflared
kubectl -n platform get pods -l app.kubernetes.io/name=cloudflared