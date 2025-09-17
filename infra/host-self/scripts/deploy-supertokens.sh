#!/usr/bin/env bash
set -euo pipefail

NAMESPACE=${NAMESPACE:-auth}
ST_DB_URI=${ST_DB_URI:-}
CHART_PATH=${CHART_PATH:-}

if [ -z "$ST_DB_URI" ] || [ -z "$CHART_PATH" ]; then
  echo "Usage: ST_DB_URI=postgresql://USER:PASSWORD@HOST:5432/db CHART_PATH=/path/to/supertokens-chart ./deploy-supertokens.sh" >&2
  exit 1
fi

kubectl get ns "$NAMESPACE" >/dev/null 2>&1 || kubectl create ns "$NAMESPACE"

helm upgrade --install supertokens "$CHART_PATH" \
  --namespace "$NAMESPACE" --create-namespace \
  --set service.type=ClusterIP \
  --set env.SUPERTOKENS_POSTGRESQL_CONNECTION_URI="$ST_DB_URI"

kubectl -n "$NAMESPACE" get pods,svc