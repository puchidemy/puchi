#!/usr/bin/env bash
set -euo pipefail

helm repo add apisix https://charts.apiseven.com
helm repo update

kubectl get ns apisix >/dev/null 2>&1 || kubectl create ns apisix

helm template apisix apisix/apisix \
  --namespace apisix \
  --create-namespace \
  --include-crds \
  --set ingress-controller.enabled=true \
  --set ingress-controller.config.apisix.serviceNamespace=apisix \
  > /tmp/apisix-rendered.yaml

kubectl apply -f /tmp/apisix-rendered.yaml
kubectl -n apisix get pods,svc