#!/usr/bin/env bash
set -euo pipefail

if ! command -v k0s >/dev/null 2>&1; then
  curl -sSLf https://get.k0s.sh | sudo sh
fi

sudo k0s install controller --single || true
sudo k0s start
sleep 5

mkdir -p "$HOME/.kube"
sudo k0s kubeconfig admin > "$HOME/.kube/config"
chmod 600 "$HOME/.kube/config"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl not found; install via your distro or https://kubernetes.io/docs/tasks/tools/"
fi

if ! command -v helm >/dev/null 2>&1; then
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

kubectl get nodes