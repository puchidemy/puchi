# Tiltfile for Puchi Platform Development

# Load Kubernetes resources
load('infra/k8s/overlays/dev', allow_k8s_contexts=['docker-desktop', 'microk8s'])

# Frontend development
docker_build(
    'puchi-frontend',
    'apps/frontend',
    dockerfile='apps/frontend/Dockerfile',
    only=['apps/frontend/**'],
    ignore=['apps/frontend/node_modules/**', 'apps/frontend/.next/**']
)

k8s_yaml('infra/k8s/overlays/dev/frontend-patch.yaml')
k8s_resource('puchi-fe', port_forwards='3000:80', resource_deps=['puchi-fe'])

# Backend services development
docker_build(
    'puchi-user-service',
    'apps/services/user-service',
    dockerfile='apps/services/user-service/Dockerfile',
    only=['apps/services/user-service/**']
)

k8s_yaml('infra/k8s/overlays/dev/user-service-patch.yaml')
k8s_resource('user-service', port_forwards='8080:8080', resource_deps=['user-service'])

# Database
k8s_yaml('infra/k8s/overlays/dev/database-patch.yaml')
k8s_resource('postgres', port_forwards='5432:5432')

# Local development settings
local_resource(
    'dev-tools',
    serve_cmd='echo "Development tools available:" && echo "- Frontend: http://localhost:3000" && echo "- User Service: http://localhost:8080" && echo "- PostgreSQL: localhost:5432"',
    deps=['apps/frontend', 'apps/services/user-service']
)

# Watch for changes in submodules
watch_file('.gitmodules')

# Environment variables for development
os.environ['TILT_HOST'] = 'localhost'
os.environ['TILT_PORT'] = '10350'
