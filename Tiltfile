# Tiltfile for Puchi Platform Development (self-host)

# Note: Legacy Kubernetes overlays (infra/k8s/overlays/*) are removed.
# This Tiltfile keeps local Docker build/watch helpers only.

# Frontend development (image build)
docker_build(
    'puchi-frontend',
    'apps/frontend',
    dockerfile='apps/frontend/Dockerfile',
    only=['apps/frontend/**'],
    ignore=['apps/frontend/node_modules/**', 'apps/frontend/.next/**']
)

# Backend service example (user-service)
docker_build(
    'puchi-user-service',
    'apps/services/user-service',
    dockerfile='apps/services/user-service/Dockerfile',
    only=['apps/services/user-service/**']
)

# Local dev tips
local_resource(
    'dev-tools',
    serve_cmd='echo "Local images can be built here. Deploy to cluster via infra/host-self scripts on your host."',
    deps=['apps/frontend', 'apps/services/user-service']
)
