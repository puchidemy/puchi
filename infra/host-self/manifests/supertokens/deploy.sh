#!/usr/bin/env bash
set -euo pipefail

# Deploy SuperTokens ingress after SuperTokens is installed
kubectl apply -k manifests/supertokens/

echo "SuperTokens ingress deployed. Ensure DNS points auth.puchi.io.vn to APISIX."