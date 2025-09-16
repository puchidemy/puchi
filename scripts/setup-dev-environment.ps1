# 🚀 Puchi Development Environment Setup Script (PowerShell)

param(
    [switch]$SkipMonitoring
)

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Reset = "`e[0m"

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = $Reset
    )
    Write-Host "${Color}${Message}${Reset}"
}

function Check-Prerequisites {
    Write-ColorOutput "📋 Checking prerequisites..." $Blue
    
    # Check if kubectl is installed
    if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
        Write-ColorOutput "❌ kubectl is not installed. Please install kubectl first." $Red
        exit 1
    }
    
    # Check if helm is installed
    if (-not (Get-Command helm -ErrorAction SilentlyContinue)) {
        Write-ColorOutput "❌ helm is not installed. Please install helm first." $Red
        exit 1
    }
    
    # Check if docker is installed
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-ColorOutput "❌ docker is not installed. Please install docker first." $Red
        exit 1
    }
    
    Write-ColorOutput "✅ All prerequisites are installed" $Green
}

function Setup-Cluster {
    Write-ColorOutput "☸️ Setting up Kubernetes cluster..." $Blue
    
    # Check if cluster is accessible
    try {
        kubectl cluster-info | Out-Null
        Write-ColorOutput "✅ Kubernetes cluster is accessible" $Green
    }
    catch {
        Write-ColorOutput "❌ Kubernetes cluster is not accessible. Please check your kubeconfig." $Red
        exit 1
    }
}

function Deploy-Infrastructure {
    Write-ColorOutput "🏗️ Deploying infrastructure..." $Blue
    
    # Deploy base infrastructure
    kubectl apply -k infra/k8s/base/
    Write-ColorOutput "✅ Base infrastructure deployed" $Green
    
    # Deploy platform services
    kubectl apply -k infra/k8s/platform/
    Write-ColorOutput "✅ Platform services deployed" $Green
    
    # Deploy development overlay
    kubectl apply -k infra/k8s/overlays/dev/
    Write-ColorOutput "✅ Development environment deployed" $Green
}

function Setup-Monitoring {
    if ($SkipMonitoring) {
        Write-ColorOutput "⏭️ Skipping monitoring setup" $Yellow
        return
    }
    
    Write-ColorOutput "📊 Setting up monitoring..." $Blue
    
    # Add Prometheus Helm repository
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    # Install Prometheus
    helm upgrade --install prometheus prometheus-community/kube-prometheus-stack `
        --namespace monitoring `
        --create-namespace `
        --values infra/charts/monitoring/values.yaml
    
    Write-ColorOutput "✅ Monitoring setup completed" $Green
}

function Verify-Deployment {
    Write-ColorOutput "🔍 Verifying deployment..." $Blue
    
    # Wait for pods to be ready
    Write-ColorOutput "Waiting for pods to be ready..." $Yellow
    kubectl wait --for=condition=Ready pod -l app=puchi-fe -n puchi-dev --timeout=300s
    kubectl wait --for=condition=Ready pod -l app=user-service -n puchi-dev --timeout=300s
    
    # Check pod status
    Write-ColorOutput "📋 Pod status:" $Yellow
    kubectl get pods -n puchi-dev
    
    # Check services
    Write-ColorOutput "🌐 Services:" $Yellow
    kubectl get services -n puchi-dev
    
    Write-ColorOutput "✅ Deployment verification completed" $Green
}

function Setup-PortForwarding {
    Write-ColorOutput "🔗 Setting up port forwarding..." $Blue
    
    Write-ColorOutput "Setting up port forwarding for development access:" $Yellow
    Write-ColorOutput "- Frontend: http://localhost:3000" $Yellow
    Write-ColorOutput "- User Service: http://localhost:8080" $Yellow
    Write-ColorOutput "- PostgreSQL: localhost:5432" $Yellow
    
    # Create port forwarding script
    $portForwardScript = @'
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
'@
    
    $portForwardScript | Out-File -FilePath "scripts/port-forward.sh" -Encoding UTF8
    
    Write-ColorOutput "✅ Port forwarding script created" $Green
}

function Main {
    Write-ColorOutput "🚀 Starting Puchi development environment setup..." $Green
    
    Check-Prerequisites
    Setup-Cluster
    Deploy-Infrastructure
    Setup-Monitoring
    Verify-Deployment
    Setup-PortForwarding
    
    Write-ColorOutput "🎉 Development environment setup completed!" $Green
    Write-Host ""
    Write-ColorOutput "📋 Next steps:" $Yellow
    Write-ColorOutput "1. Run 'make dev-start' to start development environment" $Yellow
    Write-ColorOutput "2. Or run './scripts/port-forward.sh' for port forwarding" $Yellow
    Write-ColorOutput "3. Access your applications:" $Yellow
    Write-ColorOutput "   - Frontend: http://localhost:3000" $Yellow
    Write-ColorOutput "   - API: http://localhost:8080" $Yellow
    Write-Host ""
    Write-ColorOutput "📚 For more information, check the documentation in docs/" $Blue
}

# Run main function
Main
