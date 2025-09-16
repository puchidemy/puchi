# Troubleshooting Guide

## Overview

This guide provides solutions to common issues encountered when working with the Puchi platform. It covers both development and production environments.

## Table of Contents

- [Development Issues](#development-issues)
- [Deployment Issues](#deployment-issues)
- [Performance Issues](#performance-issues)
- [Database Issues](#database-issues)
- [Authentication Issues](#authentication-issues)
- [Network Issues](#network-issues)
- [Monitoring & Debugging](#monitoring--debugging)
- [Emergency Procedures](#emergency-procedures)

## Development Issues

### Environment Setup

#### Issue: Docker containers not starting

**Symptoms:**

- Containers fail to start
- Port conflicts
- Permission errors

**Solutions:**

```bash
# Check Docker status
docker --version
docker-compose --version

# Restart Docker Desktop
# Or restart Docker daemon
sudo systemctl restart docker

# Check port usage
lsof -i :3000
lsof -i :5432

# Kill process using port
kill -9 <PID>

# Check disk space
df -h
docker system df
docker system prune -f
```

#### Issue: Kubernetes cluster not accessible

**Symptoms:**

- `kubectl` commands fail
- Connection refused errors
- Context not found

**Solutions:**

```bash
# Check kubectl configuration
kubectl config current-context
kubectl config get-contexts

# Switch context
kubectl config use-context docker-desktop
kubectl config use-context microk8s

# Test cluster connection
kubectl cluster-info
kubectl get nodes

# Reset kubectl config
kubectl config view --raw > ~/.kube/config
```

#### Issue: Submodules not updating

**Symptoms:**

- Outdated code in submodules
- Git submodule errors
- Merge conflicts in submodules

**Solutions:**

```bash
# Initialize submodules
git submodule update --init --recursive

# Update all submodules
git submodule foreach git fetch --all
git submodule foreach git checkout main
git submodule foreach git pull

# Reset submodules
git submodule deinit -f .
git submodule update --init --recursive

# Update submodule URLs
git config submodule.apps/frontend.url https://github.com/hoan02/puchi-frontend.git
```

### Build Issues

#### Issue: Frontend build failures

**Symptoms:**

- TypeScript compilation errors
- Missing dependencies
- Build timeouts

**Solutions:**

```bash
cd apps/frontend

# Clean and reinstall
rm -rf node_modules package-lock.json
npm install

# Clear Next.js cache
rm -rf .next
npm run build

# Check TypeScript errors
npm run type-check

# Update dependencies
npm update
npm audit fix
```

#### Issue: Go service build failures

**Symptoms:**

- Go module errors
- Import path issues
- Build failures

**Solutions:**

```bash
cd apps/services/user-service

# Clean module cache
go clean -modcache
go mod tidy
go mod download

# Verify imports
go list -m all
go mod verify

# Build with verbose output
go build -v ./...
```

## Deployment Issues

### Pod Issues

#### Issue: Pods stuck in Pending state

**Symptoms:**

- Pods not starting
- Resource constraints
- Node scheduling issues

**Diagnosis:**

```bash
# Check pod status
kubectl get pods -n puchi-dev

# Describe pod for details
kubectl describe pod <pod-name> -n puchi-dev

# Check events
kubectl get events -n puchi-dev --sort-by='.lastTimestamp'

# Check node resources
kubectl top nodes
kubectl describe nodes
```

**Solutions:**

```bash
# Check resource requests/limits
kubectl get pod <pod-name> -n puchi-dev -o yaml

# Scale down and up
kubectl scale deployment puchi-fe --replicas=0 -n puchi-dev
kubectl scale deployment puchi-fe --replicas=1 -n puchi-dev

# Check node capacity
kubectl get nodes -o custom-columns=NAME:.metadata.name,CPU:.status.capacity.cpu,MEMORY:.status.capacity.memory
```

#### Issue: Pods crashing or restarting

**Symptoms:**

- Pods in CrashLoopBackOff
- Frequent restarts
- Application errors

**Diagnosis:**

```bash
# Check pod logs
kubectl logs <pod-name> -n puchi-dev
kubectl logs <pod-name> -n puchi-dev --previous

# Check pod status
kubectl get pods -n puchi-dev
kubectl describe pod <pod-name> -n puchi-dev

# Check resource usage
kubectl top pods -n puchi-dev
```

**Solutions:**

```bash
# Check application logs
kubectl logs -f deployment/puchi-fe -n puchi-dev

# Check resource limits
kubectl get pod <pod-name> -n puchi-dev -o yaml | grep -A 10 resources

# Restart deployment
kubectl rollout restart deployment/puchi-fe -n puchi-dev

# Check configuration
kubectl get configmap -n puchi-dev
kubectl get secret -n puchi-dev
```

### Service Issues

#### Issue: Services not accessible

**Symptoms:**

- 503 Service Unavailable
- Connection refused
- Timeout errors

**Diagnosis:**

```bash
# Check service status
kubectl get services -n puchi-dev

# Check endpoints
kubectl get endpoints -n puchi-dev

# Test service connectivity
kubectl exec -it <pod-name> -n puchi-dev -- curl http://service-name:port

# Check service selector
kubectl get service puchi-fe -n puchi-dev -o yaml
```

**Solutions:**

```bash
# Verify service selector matches pod labels
kubectl get pods -n puchi-dev --show-labels
kubectl get service puchi-fe -n puchi-dev -o yaml

# Check pod readiness
kubectl get pods -n puchi-dev -o wide

# Restart service
kubectl delete service puchi-fe -n puchi-dev
kubectl apply -f k8s/service.yaml
```

### Ingress Issues

#### Issue: Ingress not routing traffic

**Symptoms:**

- 404 Not Found
- Default backend errors
- SSL certificate issues

**Diagnosis:**

```bash
# Check ingress status
kubectl get ingress -n puchi-dev

# Describe ingress
kubectl describe ingress puchi-fe -n puchi-dev

# Check ingress controller
kubectl get pods -n ingress-nginx

# Test ingress connectivity
curl -H "Host: dev.puchi.io.vn" http://localhost:80
```

**Solutions:**

```bash
# Check ingress annotations
kubectl get ingress puchi-fe -n puchi-dev -o yaml

# Verify ingress controller
kubectl get pods -n ingress-nginx
kubectl logs -f deployment/ingress-nginx-controller -n ingress-nginx

# Check SSL certificates
kubectl get certificates -n puchi-dev
kubectl describe certificate puchi-fe-tls -n puchi-dev
```

## Performance Issues

### High Response Times

**Symptoms:**

- Slow API responses
- Timeout errors
- High CPU/memory usage

**Diagnosis:**

```bash
# Check resource usage
kubectl top pods -n puchi-dev
kubectl top nodes

# Check application metrics
curl http://localhost:9090/api/v1/query?query=rate(http_requests_total[5m])

# Check database performance
kubectl exec -it deployment/postgres -n puchi-dev -- psql -c "SELECT * FROM pg_stat_activity;"
```

**Solutions:**

```bash
# Scale up deployments
kubectl scale deployment puchi-fe --replicas=3 -n puchi-dev

# Check resource limits
kubectl get pod <pod-name> -n puchi-dev -o yaml | grep -A 10 resources

# Optimize database queries
kubectl exec -it deployment/postgres -n puchi-dev -- psql -c "EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';"
```

### Memory Issues

**Symptoms:**

- Out of memory errors
- Pod evictions
- Application crashes

**Diagnosis:**

```bash
# Check memory usage
kubectl top pods -n puchi-dev
kubectl describe pod <pod-name> -n puchi-dev

# Check memory limits
kubectl get pod <pod-name> -n puchi-dev -o yaml | grep -A 5 resources
```

**Solutions:**

```bash
# Increase memory limits
kubectl patch deployment puchi-fe -n puchi-dev -p '{"spec":{"template":{"spec":{"containers":[{"name":"puchi-fe","resources":{"limits":{"memory":"1Gi"}}}]}}}}'

# Check for memory leaks
kubectl exec -it <pod-name> -n puchi-dev -- ps aux
```

## Database Issues

### Connection Issues

**Symptoms:**

- Database connection errors
- Connection pool exhaustion
- Authentication failures

**Diagnosis:**

```bash
# Check database pod
kubectl get pods -n puchi-dev -l app=postgres

# Check database logs
kubectl logs -f deployment/postgres -n puchi-dev

# Test database connectivity
kubectl exec -it deployment/postgres -n puchi-dev -- psql -U postgres -d puchi
```

**Solutions:**

```bash
# Check database configuration
kubectl get configmap postgres-config -n puchi-dev -o yaml

# Restart database
kubectl rollout restart deployment/postgres -n puchi-dev

# Check connection limits
kubectl exec -it deployment/postgres -n puchi-dev -- psql -c "SHOW max_connections;"
```

### Migration Issues

**Symptoms:**

- Migration failures
- Schema conflicts
- Data corruption

**Diagnosis:**

```bash
# Check migration status
kubectl exec -it deployment/user-service -n puchi-dev -- ./migrate -path ./migrations -database "postgres://user:pass@db:5432/dbname?sslmode=disable" version

# Check database schema
kubectl exec -it deployment/postgres -n puchi-dev -- psql -c "\dt"
```

**Solutions:**

```bash
# Run migrations manually
kubectl exec -it deployment/user-service -n puchi-dev -- ./migrate -path ./migrations -database "postgres://user:pass@db:5432/dbname?sslmode=disable" up

# Rollback migration
kubectl exec -it deployment/user-service -n puchi-dev -- ./migrate -path ./migrations -database "postgres://user:pass@db:5432/dbname?sslmode=disable" down 1
```

## Authentication Issues

### Token Issues

**Symptoms:**

- 401 Unauthorized errors
- Token expiration
- Invalid token errors

**Diagnosis:**

```bash
# Check authentication service
kubectl get pods -n puchi-dev -l app=supertokens

# Check authentication logs
kubectl logs -f deployment/supertokens -n puchi-dev

# Test authentication endpoint
curl -X POST http://localhost:3567/auth/signin \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

**Solutions:**

```bash
# Check authentication configuration
kubectl get configmap supertokens-config -n puchi-dev -o yaml

# Restart authentication service
kubectl rollout restart deployment/supertokens -n puchi-dev

# Check token validation
curl -H "Authorization: Bearer <token>" http://localhost:3567/auth/verify
```

## Network Issues

### DNS Resolution

**Symptoms:**

- DNS resolution failures
- Service discovery issues
- Network connectivity problems

**Diagnosis:**

```bash
# Check DNS resolution
kubectl exec -it <pod-name> -n puchi-dev -- nslookup kubernetes.default

# Check service discovery
kubectl exec -it <pod-name> -n puchi-dev -- nslookup puchi-fe.puchi-dev.svc.cluster.local

# Check network policies
kubectl get networkpolicies -n puchi-dev
```

**Solutions:**

```bash
# Check CoreDNS
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Restart CoreDNS
kubectl rollout restart deployment/coredns -n kube-system

# Check network policies
kubectl describe networkpolicy <policy-name> -n puchi-dev
```

### Load Balancer Issues

**Symptoms:**

- Load balancer not accessible
- Traffic not distributed
- Health check failures

**Diagnosis:**

```bash
# Check load balancer status
kubectl get services -n puchi-dev

# Check ingress controller
kubectl get pods -n ingress-nginx

# Test load balancer
curl -I http://localhost:80
```

**Solutions:**

```bash
# Restart ingress controller
kubectl rollout restart deployment/ingress-nginx-controller -n ingress-nginx

# Check ingress configuration
kubectl get ingress -n puchi-dev -o yaml
```

## Monitoring & Debugging

### Log Analysis

```bash
# View application logs
kubectl logs -f deployment/puchi-fe -n puchi-dev

# View logs from multiple pods
kubectl logs -f -l app=puchi-fe -n puchi-dev

# View logs with timestamps
kubectl logs -f deployment/puchi-fe -n puchi-dev --timestamps

# View logs from previous container
kubectl logs -f deployment/puchi-fe -n puchi-dev --previous
```

### Metrics Analysis

```bash
# Check Prometheus metrics
curl http://localhost:9090/api/v1/query?query=up

# Check Grafana dashboards
open http://localhost:3000

# Check APISIX metrics
curl http://localhost:9080/apisix/admin/routes
```

### Debugging Tools

```bash
# Access pod shell
kubectl exec -it <pod-name> -n puchi-dev -- /bin/sh

# Port forward for local access
kubectl port-forward service/puchi-fe 8080:80 -n puchi-dev

# Check resource usage
kubectl top pods -n puchi-dev
kubectl top nodes

# Check events
kubectl get events -n puchi-dev --sort-by='.lastTimestamp'
```

## Emergency Procedures

### Service Recovery

```bash
# Quick restart
kubectl rollout restart deployment/puchi-fe -n puchi-dev

# Scale down and up
kubectl scale deployment puchi-fe --replicas=0 -n puchi-dev
kubectl scale deployment puchi-fe --replicas=3 -n puchi-dev

# Delete and recreate
kubectl delete deployment puchi-fe -n puchi-dev
kubectl apply -f k8s/deployment.yaml
```

### Database Recovery

```bash
# Backup database
kubectl exec -it deployment/postgres -n puchi-dev -- pg_dump -U postgres puchi > backup.sql

# Restore database
kubectl exec -i deployment/postgres -n puchi-dev -- psql -U postgres puchi < backup.sql

# Check database integrity
kubectl exec -it deployment/postgres -n puchi-dev -- psql -c "VACUUM ANALYZE;"
```

### Rollback Procedures

```bash
# Rollback deployment
kubectl rollout undo deployment/puchi-fe -n puchi-dev

# Check rollout history
kubectl rollout history deployment/puchi-fe -n puchi-dev

# Rollback to specific revision
kubectl rollout undo deployment/puchi-fe --to-revision=2 -n puchi-dev
```

## Getting Help

### Internal Resources

1. **Check Documentation**: Look in the `docs/` directory
2. **Review Logs**: Use `kubectl logs` to check service logs
3. **Check Monitoring**: Use Grafana dashboards for metrics
4. **Ask Team**: Use team communication channels

### External Resources

1. **Kubernetes Documentation**: https://kubernetes.io/docs/
2. **Docker Documentation**: https://docs.docker.com/
3. **Community Forums**: Stack Overflow, Reddit
4. **Professional Support**: Contact DevOps team

### Emergency Contacts

- **On-call Engineer**: +1-XXX-XXX-XXXX
- **Team Lead**: +1-XXX-XXX-XXXX
- **DevOps Team**: devops@puchi.io.vn
- **Emergency Escalation**: emergency@puchi.io.vn

## Prevention

### Best Practices

1. **Regular Monitoring**: Set up alerts and dashboards
2. **Health Checks**: Implement proper health checks
3. **Resource Limits**: Set appropriate resource limits
4. **Backup Strategy**: Regular backups and disaster recovery
5. **Testing**: Comprehensive testing before deployment
6. **Documentation**: Keep documentation updated
7. **Training**: Regular team training on troubleshooting

### Proactive Measures

1. **Capacity Planning**: Monitor resource usage trends
2. **Security Updates**: Keep dependencies updated
3. **Performance Testing**: Regular performance testing
4. **Disaster Recovery**: Regular disaster recovery drills
5. **Incident Response**: Well-defined incident response procedures
