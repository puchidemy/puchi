# 🏗️ Infrastructure Setup Guide

## Accessing APISIX

### APISIX (Admin API)

Verify components:

```bash
kubectl -n apisix get pods
kubectl -n apisix get svc
```

Port-forward the Admin API:

```bash
kubectl -n apisix port-forward svc/apisix-admin 9180:9180
```

Fetch the admin API key and test:

```bash
APISIX_KEY=$(kubectl -n apisix get secret apisix -o jsonpath='{.data.admin.key}' | base64 -d)
curl -s http://127.0.0.1:9180/apisix/admin/routes -H "X-API-KEY: ${APISIX_KEY}"
```

Notes:

- If you enabled APISIX Ingress Controller, Kubernetes Ingress resources will be reconciled automatically.
- Admin API should be secured and not exposed publicly. Use port-forward or a restricted network path only.

Troubleshooting:

- If APISIX CRDs are missing, ensure the Helm steps installed both APISIX and the APISIX Ingress Controller before applying platform manifests.

## Overview

This document outlines the complete infrastructure setup for the Puchi platform, including CI/CD pipelines, Kubernetes configurations, and development tools.

## 🚀 What's Been Set Up

### 1. CI/CD Pipeline (`.github/workflows/ci-cd.yml`)

**Features:**

- ✅ **Multi-stage pipeline**: Quality check → Build → Deploy
- ✅ **Code Quality**: Linting, testing, security scanning
- ✅ **Multi-environment**: Dev, Staging, Production
- ✅ **Container Registry**: GitHub Container Registry
- ✅ **Rollback Support**: Automatic rollback on failure
- ✅ **Notifications**: Deployment status notifications

**Triggers:**

- `main` branch → Production deployment
- `develop` branch → Development deployment
- `release/*` branches → Staging deployment
- Pull requests → Quality checks only

### 2. Kubernetes Infrastructure

#### Base Infrastructure (`infra/k8s/base/`)

- ✅ **Namespaces**: Separate namespaces for each environment
- ✅ **Network Policies**: Security isolation between services
- ✅ **Resource Quotas**: Resource limits per environment
- ✅ **Common Labels**: Consistent labeling strategy

#### Environment Overlays

- ✅ **Development** (`infra/k8s/overlays/dev/`)
- ✅ **Staging** (`infra/k8s/overlays/staging/`)
- ✅ **Production** (`infra/k8s/overlays/prod/`)

#### Platform Services (`infra/k8s/platform/`)

- ✅ **APISIX Gateway**: API gateway routing (deploy bằng Helm, values: `infra/k8s/platform/apisix/helm-values.yaml`). Tham khảo lệnh cài đặt: see [APISIX Helm Chart](https://apisix.apache.org/docs/helm-chart/apisix/)
- ✅ **Cloudflared**: Cloudflare Tunnel (`infra/k8s/platform/cloudflared`) để expose `*.puchi.io.vn`
- ✅ **Monitoring**: Prometheus/Grafana setup
- ✅ **Database**: PostgreSQL configuration

### 3. Development Tools

#### Setup Scripts

- ✅ **PowerShell Script** (`scripts/setup-dev-environment.ps1`)
- ✅ **Bash Script** (`scripts/setup-dev-environment.sh`)
- ✅ **Port Forwarding** (`scripts/port-forward.ps1`)

#### Development Workflow

- ✅ **Tilt** (`Tiltfile`): Live reload development
- ✅ **Makefile**: Enhanced build automation

## 🛠️ Quick Start

### Prerequisites

```bash
# Required tools
- kubectl 1.25+
- helm 3.10+
- docker 20.10+
- Node.js 18+
- Go 1.21+
```

### 1. Setup Development Environment

**Windows (PowerShell):**

```powershell
# Run setup script
.\scripts\setup-dev-environment.ps1

# Or skip monitoring for faster setup
.\scripts\setup-dev-environment.ps1 -SkipMonitoring
```

**Linux/macOS (Bash):**

```bash
# Make script executable
chmod +x scripts/setup-dev-environment.sh

# Run setup script
./scripts/setup-dev-environment.sh
```

### 2. Start Development Environment

**Option 1: Using Makefile**

```bash
make dev-start
```

**Using Tilt**

```bash
tilt up
```

### 3. Port Forwarding

**Windows (PowerShell):**

```powershell
# Start port forwarding
.\scripts\port-forward.ps1

# Stop port forwarding
.\scripts\port-forward.ps1 -Stop
```

**Linux/macOS (Bash):**

```bash
# Start port forwarding
./scripts/port-forward.sh
```

## 🌐 Access Points

After setup, you can access:

| Service          | URL                   | Purpose              |
| ---------------- | --------------------- | -------------------- |
| **Frontend**     | http://localhost:3000 | Next.js application  |
| **User Service** | http://localhost:8080 | Go microservice      |
| **PostgreSQL**   | localhost:5432        | Database             |
| **Grafana**      | http://localhost:3001 | Monitoring dashboard |
| **Prometheus**   | http://localhost:9090 | Metrics              |

## 🔄 CI/CD Workflow

### Development Flow

```
1. Developer pushes to `develop` branch
2. CI/CD pipeline runs:
   - Code quality checks
   - Build Docker images
   - Deploy to development
   - Run smoke tests
```

### Staging Flow

```
1. Create release branch: `release/v1.2.3`
2. CI/CD pipeline runs:
   - All development checks
   - Deploy to staging
   - Run integration tests
```

### Production Flow

```
1. Merge release branch to `main`
2. CI/CD pipeline runs:
   - All previous checks
   - Deploy to production
   - Backup current deployment
   - Rollback on failure
```

## 🏗️ Infrastructure Components

### Namespaces

- `puchi-dev` - Development environment
- `puchi-staging` - Staging environment
- `puchi-prod` - Production environment
- `platform` - Platform services (APISIX, etc.)
- `monitoring` - Monitoring stack
- `database` - Database services

### Services

- **Frontend**: Next.js application
- **User Service**: Go microservice
- **PostgreSQL**: Primary database
- **APISIX**: API gateway
- **Prometheus**: Metrics collection
- **Grafana**: Monitoring dashboards

### Network Policies

- Default deny all traffic
- Allow platform ingress
- Allow database access
- Service-to-service communication

### Resource Management

- Resource quotas per environment
- Limit ranges for containers
- CPU and memory limits
- Persistent volume limits

## 🔧 Configuration Management

### Environment Variables

Each environment has its own configuration:

**Development:**

```yaml
ENVIRONMENT: development
LOG_LEVEL: debug
API_URL: https://api-dev.puchi.io.vn
```

**Staging:**

```yaml
ENVIRONMENT: staging
LOG_LEVEL: info
API_URL: https://api-staging.puchi.io.vn
```

**Production:**

```yaml
ENVIRONMENT: production
LOG_LEVEL: warn
API_URL: https://api.puchi.io.vn
```

### Secrets Management

- Kubernetes secrets for sensitive data
- Environment-specific secret generators
- Secure secret rotation

## 📊 Monitoring & Observability

### Metrics

- Application metrics via Prometheus
- Infrastructure metrics
- Custom business metrics

### Logging

- Centralized logging
- Structured log format
- Log aggregation

### Alerting

- Health check alerts
- Performance alerts
- Error rate monitoring

## 🚀 Deployment Strategies

### Blue-Green Deployment

```bash
# Deploy new version to green environment
kubectl apply -f infra/k8s/overlays/prod/green/

# Test green environment
curl -I https://green.puchi.io.vn/health

# Switch traffic to green
kubectl patch service puchi-fe -n puchi-prod -p '{"spec":{"selector":{"version":"green"}}}'
```

### Rolling Deployment

```bash
# Update deployment with new image
kubectl set image deployment/puchi-fe puchi-fe=new-image:v1.2.3 -n puchi-prod

# Monitor rollout
kubectl rollout status deployment/puchi-fe -n puchi-prod
```

### Canary Deployment

```bash
# Deploy canary version (10% traffic)
kubectl apply -f infra/k8s/overlays/prod/canary/

# Gradually increase traffic
kubectl patch service puchi-fe -n puchi-prod -p '{"spec":{"selector":{"version":"canary"}}}'
```

## 🔒 Security Features

### Network Security

- Network policies for pod isolation
- TLS encryption for all communications
- Service mesh integration ready

### Image Security

- Vulnerability scanning with Trivy
- Minimal base images
- Regular security updates

### Access Control

- RBAC for Kubernetes resources
- Service account isolation
- Secret management

## 📈 Scaling & Performance

### Horizontal Scaling

- Auto-scaling based on metrics
- Load balancing across replicas
- Resource optimization

### Performance Optimization

- Database connection pooling
- Caching strategies
- CDN integration

## 🛠️ Troubleshooting

### Common Issues

**Port Forwarding Problems:**

```powershell
# Check if services are running
kubectl get pods -n puchi-dev

# Restart port forwarding
.\scripts\port-forward.ps1 -Stop
.\scripts\port-forward.ps1
```

**Deployment Issues:**

```bash
# Check pod logs
kubectl logs -f deployment/puchi-fe -n puchi-dev

# Check deployment status
kubectl rollout status deployment/puchi-fe -n puchi-dev

# Rollback if needed
kubectl rollout undo deployment/puchi-fe -n puchi-dev
```

**Database Connection:**

```bash
# Check database pod
kubectl get pods -n puchi-dev -l app=postgres

# Test database connection
kubectl exec -it deployment/postgres -n puchi-dev -- psql -U puchi -d puchi_dev
```

## 📚 Additional Resources

- [Deployment Guide](docs/operations/deployment-guide.md)
- [Troubleshooting Guide](docs/operations/troubleshooting.md)
- [API Design Guidelines](docs/architecture/api-design.md)
- [System Architecture](docs/architecture/system-architecture.md)

## 🎯 Next Steps

1. **Customize Configuration**: Update environment-specific configs
2. **Add Monitoring**: Set up custom dashboards and alerts
3. **Security Hardening**: Implement additional security measures
4. **Performance Tuning**: Optimize based on metrics
5. **Documentation**: Keep documentation updated

---

**Happy Coding! 🚀**
