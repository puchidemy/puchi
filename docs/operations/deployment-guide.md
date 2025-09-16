# Deployment Guide

## Overview

This guide covers the deployment process for the Puchi platform across different environments. The platform uses Kubernetes for container orchestration and follows GitOps principles for deployment.

## Environments

### Environment Overview

| Environment     | Purpose          | Kubernetes Context | Namespace     | Domain            |
| --------------- | ---------------- | ------------------ | ------------- | ----------------- |
| **Local**       | Development      | `docker-desktop`   | `puchi-local` | `localhost`       |
| **Development** | Feature testing  | `microk8s`         | `puchi-dev`   | `dev.puchi.io.vn` |
| **Production**  | Live application | `prod-cluster`     | `puchi-prod`  | `puchi.io.vn`     |

### Environment Characteristics

#### Local Environment

- **Purpose**: Local development and testing
- **Resources**: Limited (developer machine)
- **Data**: Mock/test data
- **Monitoring**: Basic logging
- **Access**: Developer only

#### Development Environment

- **Purpose**: Feature integration and testing
- **Resources**: Moderate
- **Data**: Test data with real structure
- **Monitoring**: Basic monitoring
- **Access**: Development team

#### Production Environment

- **Purpose**: Live application serving users
- **Resources**: High availability and performance
- **Data**: Live user data
- **Monitoring**: Comprehensive monitoring and alerting
- **Access**: Operations team only

## Prerequisites

### Required Tools

- [kubectl](https://kubernetes.io/docs/tasks/tools/) 1.25+
- [Helm](https://helm.sh/docs/intro/install/) 3.10+
- [Docker](https://docs.docker.com/get-docker/) 20.10+

### Required Access

- Kubernetes cluster access
- Docker registry access
- Cloudflare API access (for DNS)
- Monitoring system access

### Environment Setup

#### 1. Configure kubectl Context

```bash
# List available contexts
kubectl config get-contexts

# Switch to development context
kubectl config use-context microk8s

# Switch to production context
kubectl config use-context prod-cluster

# Verify current context
kubectl config current-context
```

#### 2. Verify Cluster Access

```bash
# Check cluster connection
kubectl cluster-info

# List namespaces
kubectl get namespaces

# Check node status
kubectl get nodes
```

## Deployment Process

### 1. Pre-Deployment Checklist

Before deploying, ensure:

- [ ] All tests pass (`make test`)
- [ ] Code is linted and formatted (`make lint && make format`)
- [ ] Security scan passes (`make security-scan`)
- [ ] Docker images are built and pushed
- [ ] Database migrations are ready
- [ ] Configuration files are updated
- [ ] Secrets are configured
- [ ] Monitoring is configured

### 2. Build and Push Images

```bash
# Build all services
make build

# Tag and push images
docker tag puchi-frontend:latest your-registry/puchi-frontend:latest
docker push your-registry/puchi-frontend:latest

docker tag puchi-user-service:latest your-registry/puchi-user-service:latest
docker push your-registry/puchi-user-service:latest
```

### 3. Deploy to Development (GitOps via Argo CD)

```bash
# Install Argo CD and Applications
make argocd-install

# Check deployment status
make status

# View logs if needed
make logs ENV=dev SERVICE=puchi-fe
```

### 4. Deploy to Production (GitOps via Argo CD)

```bash
# Ensure Argo CD is healthy and syncing
make argocd-sync

# Monitor deployment
kubectl rollout status deployment/puchi-fe -n puchi-prod

# Verify apps status
make argocd-status
```

## Deployment Strategies

### Blue-Green Deployment

```bash
# Deploy new version to green environment
kubectl apply -f infra/k8s/overlays/prod/green/

# Test green environment
curl -I https://green.puchi.io.vn/health

# Switch traffic to green
kubectl patch service puchi-fe -n puchi-prod -p '{"spec":{"selector":{"version":"green"}}}'

# Monitor for issues
kubectl get pods -n puchi-prod -l version=green

# If successful, clean up blue
kubectl delete -f infra/k8s/overlays/prod/blue/
```

### Rolling Deployment

```bash
# Update deployment with new image
kubectl set image deployment/puchi-fe puchi-fe=your-registry/puchi-frontend:v1.2.3 -n puchi-prod

# Monitor rollout
kubectl rollout status deployment/puchi-fe -n puchi-prod

# Rollback if needed
kubectl rollout undo deployment/puchi-fe -n puchi-prod
```

### Canary Deployment

```bash
# Deploy canary version (10% traffic)
kubectl apply -f infra/k8s/overlays/prod/canary/

# Monitor canary metrics
kubectl get pods -n puchi-prod -l version=canary

# Gradually increase traffic
kubectl patch service puchi-fe -n puchi-prod -p '{"spec":{"selector":{"version":"canary"}}}'

# Promote canary to full deployment
kubectl patch deployment puchi-fe -n puchi-prod -p '{"spec":{"template":{"spec":{"containers":[{"name":"puchi-fe","image":"your-registry/puchi-frontend:v1.2.3"}]}}}}'
```

## Configuration Management

### Environment-Specific Configs

Each environment has its own configuration overlay:

```
infra/k8s/
├── base/                    # Base configurations
│   ├── common/             # Common resources
│   └── namespaces.yaml     # Namespace definitions
└── overlays/               # Environment-specific configs
    ├── dev/                # Development configs
    └── prod/               # Production configs
```

### ConfigMap Management

```bash
# Create ConfigMap
kubectl create configmap app-config -n puchi-prod \
  --from-file=config.yaml=configs/prod/config.yaml

# Update ConfigMap
kubectl patch configmap app-config -n puchi-prod \
  --patch '{"data":{"config.yaml":"new config content"}}'

# Restart deployment to pick up changes
kubectl rollout restart deployment/puchi-fe -n puchi-prod
```

### Secret Management

```bash
# Create secret
kubectl create secret generic app-secrets -n puchi-prod \
  --from-literal=database-password=secretpassword \
  --from-literal=api-key=secretkey

# Update secret
kubectl patch secret app-secrets -n puchi-prod \
  --patch '{"data":{"database-password":"bmV3cGFzc3dvcmQ="}}'
```

## Database Migrations

### Running Migrations

```bash
# Run migrations for development
kubectl exec -it deployment/user-service -n puchi-dev -- \
  ./migrate -path ./migrations -database "postgres://user:pass@db:5432/dbname?sslmode=disable" up

# Run migrations for production
kubectl exec -it deployment/user-service -n puchi-prod -- \
  ./migrate -path ./migrations -database "postgres://user:pass@db:5432/dbname?sslmode=disable" up
```

### Migration Best Practices

- Always backup database before migrations
- Test migrations on development first
- Use transactions for complex migrations
- Have rollback scripts ready
- Monitor migration progress

## Monitoring and Alerting

### Health Checks

```bash
# Check pod health
kubectl get pods -n puchi-prod

# Check service health
kubectl get services -n puchi-prod

# Check ingress health
kubectl get ingress -n puchi-prod
```

### Metrics Monitoring

```bash
# Check Prometheus targets
curl http://prometheus:9090/api/v1/targets

# Check Grafana dashboards
open https://grafana.puchi.io.vn

# Check APISIX metrics
curl http://apisix:9080/apisix/admin/routes
```

### Log Monitoring

```bash
# View application logs
kubectl logs -f deployment/puchi-fe -n puchi-prod

# View system logs
kubectl logs -f deployment/fluentd -n kube-system

# Search logs in Elasticsearch
curl -X GET "elasticsearch:9200/_search?q=error"
```

## Troubleshooting

### Common Issues

#### Pod Not Starting

```bash
# Check pod status
kubectl describe pod pod-name -n puchi-prod

# Check events
kubectl get events -n puchi-prod --sort-by='.lastTimestamp'

# Check logs
kubectl logs pod-name -n puchi-prod
```

#### Service Not Accessible

```bash
# Check service endpoints
kubectl get endpoints -n puchi-prod

# Check ingress configuration
kubectl describe ingress puchi-fe -n puchi-prod

# Test service connectivity
kubectl exec -it pod-name -n puchi-prod -- curl http://service-name:port
```

#### Database Connection Issues

```bash
# Check database pod
kubectl get pods -n puchi-prod -l app=postgres

# Check database logs
kubectl logs -f deployment/postgres -n puchi-prod

# Test database connectivity
kubectl exec -it deployment/postgres -n puchi-prod -- psql -U user -d dbname
```

### Rollback Procedures

#### Quick Rollback

```bash
# Rollback deployment
kubectl rollout undo deployment/puchi-fe -n puchi-prod

# Check rollback status
kubectl rollout status deployment/puchi-fe -n puchi-prod
```

#### Database Rollback

```bash
# Rollback database migration
kubectl exec -it deployment/user-service -n puchi-prod -- \
  ./migrate -path ./migrations -database "postgres://user:pass@db:5432/dbname?sslmode=disable" down 1
```

#### Full Environment Rollback

```bash
# Rollback entire environment
kubectl apply -k infra/k8s/overlays/prod/previous/

# Verify rollback
make status
```

## Security Considerations

### Secrets Management

- Use Kubernetes secrets for sensitive data
- Encrypt secrets at rest
- Rotate secrets regularly
- Use external secret management (Vault) for production

### Network Security

- Use network policies for pod-to-pod communication
- Enable TLS for all communications
- Use service mesh for advanced security features
- Implement proper RBAC

### Image Security

- Scan container images for vulnerabilities
- Use minimal base images
- Keep images updated
- Use image signing and verification

## Best Practices

### Deployment Best Practices

1. **Always test in development first**
2. **Use blue-green or canary deployments for production**
3. **Monitor deployments closely**
4. **Have rollback procedures ready**
5. **Document all deployment procedures**
6. **Use infrastructure as code**
7. **Implement proper logging and monitoring**
8. **Follow the principle of least privilege**

### Operational Best Practices

1. **Maintain deployment runbooks**
2. **Regular disaster recovery drills**
3. **Monitor system health proactively**
4. **Keep documentation updated**
5. **Train team on deployment procedures**
6. **Use automated testing and validation**
7. **Implement proper change management**

## Emergency Procedures

### Incident Response

1. **Identify the issue**: Check monitoring dashboards and logs
2. **Assess impact**: Determine scope and severity
3. **Communicate**: Notify stakeholders and team
4. **Contain**: Implement immediate fixes or rollbacks
5. **Resolve**: Fix the root cause
6. **Document**: Record incident details and lessons learned

### Emergency Contacts

- **On-call Engineer**: +1-XXX-XXX-XXXX
- **Team Lead**: +1-XXX-XXX-XXXX
- **DevOps Team**: devops@puchi.io.vn
- **Emergency Escalation**: emergency@puchi.io.vn

### Emergency Rollback

```bash
# Emergency rollback to previous version
kubectl rollout undo deployment/puchi-fe -n puchi-prod

# Force restart all pods
kubectl delete pods -l app=puchi-fe -n puchi-prod

# Scale down and up
kubectl scale deployment puchi-fe --replicas=0 -n puchi-prod
kubectl scale deployment puchi-fe --replicas=3 -n puchi-prod
```
