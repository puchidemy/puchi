#!/bin/bash

# 🚀 Puchi Development Environment Setup Script

set -e

echo "🏗️ Setting up Puchi development environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check prerequisites
check_prerequisites() {
    echo -e "${BLUE}📋 Checking prerequisites...${NC}"
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}❌ kubectl is not installed. Please install kubectl first.${NC}"
        exit 1
    fi
    
    # Check if helm is installed
    if ! command -v helm &> /dev/null; then
        echo -e "${RED}❌ helm is not installed. Please install helm first.${NC}"
        exit 1
    fi
    
    # Check if docker is installed
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ docker is not installed. Please install docker first.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ All prerequisites are installed${NC}"
}

# Setup Kubernetes cluster
setup_cluster() {
    echo -e "${BLUE}☸️ Setting up Kubernetes cluster...${NC}"
    
    # Check if cluster is accessible
    if ! kubectl cluster-info &> /dev/null; then
        echo -e "${RED}❌ Kubernetes cluster is not accessible. Please check your kubeconfig.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Kubernetes cluster is accessible${NC}"
}

# Deploy infrastructure
deploy_infrastructure() {
    echo -e "${BLUE}🏗️ Deploying infrastructure...${NC}"
    
    # Deploy base infrastructure
    kubectl apply -k infra/k8s/base/
    echo -e "${GREEN}✅ Base infrastructure deployed${NC}"
    
    # Deploy platform services
    kubectl apply -k infra/k8s/platform/
    echo -e "${GREEN}✅ Platform services deployed${NC}"
    
    # Deploy development overlay
    kubectl apply -k infra/k8s/overlays/dev/
    echo -e "${GREEN}✅ Development environment deployed${NC}"
}

# Setup monitoring
setup_monitoring() {
    echo -e "${BLUE}📊 Setting up monitoring...${NC}"
    
    # Add Prometheus Helm repository
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    # Install Prometheus
    helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --create-namespace \
        --values infra/charts/monitoring/values.yaml
    
    echo -e "${GREEN}✅ Monitoring setup completed${NC}"
}

# Verify deployment
verify_deployment() {
    echo -e "${BLUE}🔍 Verifying deployment...${NC}"
    
    # Wait for pods to be ready
    echo "Waiting for pods to be ready..."
    kubectl wait --for=condition=Ready pod -l app=puchi-fe -n puchi-dev --timeout=300s
    kubectl wait --for=condition=Ready pod -l app=user-service -n puchi-dev --timeout=300s
    
    # Check pod status
    echo -e "${YELLOW}📋 Pod status:${NC}"
    kubectl get pods -n puchi-dev
    
    # Check services
    echo -e "${YELLOW}🌐 Services:${NC}"
    kubectl get services -n puchi-dev
    
    echo -e "${GREEN}✅ Deployment verification completed${NC}"
}

# Setup port forwarding
setup_port_forwarding() {
    echo -e "${BLUE}🔗 Setting up port forwarding...${NC}"
    
    echo "Setting up port forwarding for development access:"
    echo "- Frontend: http://localhost:3000"
    echo "- User Service: http://localhost:8080"
    echo "- PostgreSQL: localhost:5432"
    
    # Create port forwarding script
    cat > scripts/port-forward.sh << 'EOF'
#!/bin/bash

echo "🔗 Starting port forwarding..."

# Kill existing port forwarding
pkill -f "kubectl port-forward" || true

# Port forward services
kubectl port-forward service/puchi-fe 3000:80 -n puchi-dev &
kubectl port-forward service/user-service 8080:8080 -n puchi-dev &
kubectl port-forward service/postgres 5432:5432 -n puchi-dev &

echo "✅ Port forwarding started"
echo "- Frontend: http://localhost:3000"
echo "- User Service: http://localhost:8080"
echo "- PostgreSQL: localhost:5432"
echo ""
echo "Press Ctrl+C to stop port forwarding"

wait
EOF
    
    chmod +x scripts/port-forward.sh
    echo -e "${GREEN}✅ Port forwarding script created${NC}"
}

# Main execution
main() {
    echo -e "${GREEN}🚀 Starting Puchi development environment setup...${NC}"
    
    check_prerequisites
    setup_cluster
    deploy_infrastructure
    setup_monitoring
    verify_deployment
    setup_port_forwarding
    
    echo -e "${GREEN}🎉 Development environment setup completed!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Next steps:${NC}"
    echo "1. Run 'make dev-start' to start development environment"
    echo "2. Or run './scripts/port-forward.sh' for port forwarding"
    echo "3. Access your applications:"
    echo "   - Frontend: http://localhost:3000"
    echo "   - API: http://localhost:8080"
    echo ""
    echo -e "${BLUE}📚 For more information, check the documentation in docs/${NC}"
}

# Run main function
main "$@"
