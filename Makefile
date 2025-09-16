# 🏗️ Puchi Platform - Build Automation
# Modern microservices-based language learning platform

.PHONY: help init update clean build test lint format security-scan
.PHONY: dev-start dev-stop deploy-dev deploy-prod argocd-install argocd-sync argocd-status
.PHONY: rollback status logs apisix-apply docs-serve

# Default target
.DEFAULT_GOAL := help

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

##@ General

help: ## Display this help message
	@echo "$(BLUE)🏗️ Puchi Platform - Build Commands$(NC)"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make $(BLUE)<target>$(NC)\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  $(BLUE)%-15s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(YELLOW)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

init: ## Initialize project and submodules
	@echo "$(GREEN)🚀 Initializing Puchi platform...$(NC)"
	git submodule update --init --recursive
	@echo "$(GREEN)✅ Project initialized successfully$(NC)"

update: ## Update all submodules to latest
	@echo "$(GREEN)🔄 Updating submodules...$(NC)"
	git submodule foreach "git fetch --all"
	git submodule foreach "git checkout main && git pull"
	@echo "$(GREEN)✅ Submodules updated$(NC)"

clean: ## Clean build artifacts and temporary files
	@echo "$(YELLOW)🧹 Cleaning build artifacts...$(NC)"
	docker system prune -f
	find . -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name ".next" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name "dist" -type d -exec rm -rf {} + 2>/dev/null || true
	@echo "$(GREEN)✅ Clean completed$(NC)"

##@ Development

dev-start: ## Start development environment with Tilt
	@echo "$(GREEN)🚀 Starting development environment...$(NC)"
	tilt up

dev-stop: ## Stop development environment
	@echo "$(YELLOW)🛑 Stopping development environment...$(NC)"
	tilt down

build: ## Build all services
	@echo "$(BLUE)🔨 Building all services...$(NC)"
	@$(MAKE) -C apps/frontend build
	@$(MAKE) -C apps/services/user-service build
	@echo "$(GREEN)✅ Build completed$(NC)"

##@ Testing

test: test-unit test-integration ## Run all tests

test-unit: ## Run unit tests
	@echo "$(BLUE)🧪 Running unit tests...$(NC)"
	@$(MAKE) -C apps/frontend test
	@$(MAKE) -C apps/services/user-service test
	@echo "$(GREEN)✅ Unit tests completed$(NC)"

test-integration: ## Run integration tests
	@echo "$(BLUE)🔗 Running integration tests...$(NC)"
	@$(MAKE) -C apps/services/user-service test-integration
	@echo "$(GREEN)✅ Integration tests completed$(NC)"

test-e2e: ## Run end-to-end tests
	@echo "$(BLUE)🎯 Running E2E tests...$(NC)"
	@$(MAKE) -C apps/frontend test-e2e
	@echo "$(GREEN)✅ E2E tests completed$(NC)"

##@ Code Quality

lint: ## Lint all code
	@echo "$(BLUE)🔍 Linting code...$(NC)"
	@$(MAKE) -C apps/frontend lint
	@$(MAKE) -C apps/services/user-service lint
	@echo "$(GREEN)✅ Linting completed$(NC)"

format: ## Format all code
	@echo "$(BLUE)💅 Formatting code...$(NC)"
	@$(MAKE) -C apps/frontend format
	@$(MAKE) -C apps/services/user-service format
	@echo "$(GREEN)✅ Formatting completed$(NC)"

security-scan: ## Run security scans
	@echo "$(BLUE)🔒 Running security scans...$(NC)"
	docker run --rm -v $(PWD):/app aquasec/trivy fs /app
	@echo "$(GREEN)✅ Security scan completed$(NC)"

##@ Deployment

deploy-dev: ## Deploy to development environment
	@echo "$(GREEN)🚀 Deploying to development...$(NC)"
	kubectl apply -k infra/k8s/overlays/dev
	kubectl rollout status deployment/puchi-fe -n puchi-dev
	@echo "$(GREEN)✅ Development deployment completed$(NC)"

deploy-prod: ## Deploy to production environment
	@echo "$(RED)⚠️  Deploying to PRODUCTION...$(NC)"
	@read -p "Are you sure? [y/N]: " confirm && [ "$$confirm" = "y" ]
	kubectl apply -k infra/k8s/overlays/prod
	kubectl rollout status deployment/puchi-fe -n puchi-prod
	@echo "$(GREEN)✅ Production deployment completed$(NC)"

argocd-install: ## Install/Upgrade Argo CD and applications
	@echo "$(GREEN)🚀 Installing Argo CD...$(NC)"
	kubectl apply -k infra/k8s/platform/argocd
	@echo "$(GREEN)✅ Argo CD applied$(NC)"

argocd-sync: ## Force sync all Argo CD applications
	@echo "$(GREEN)🔄 Syncing Argo CD apps...$(NC)"
	kubectl -n argocd rollout status deploy/argocd-server --timeout=120s || true
	kubectl -n argocd rollout status deploy/argocd-repo-server --timeout=120s || true
	kubectl -n argocd rollout status deploy/argocd-application-controller --timeout=120s || true
	kubectl -n argocd get applications -o name | ForEach-Object { kubectl -n argocd patch $_ -p '{"spec":{"syncPolicy":{"automated":{"prune":true,"selfHeal":true}}}}' --type merge }
	@echo "$(GREEN)✅ Sync requested$(NC)"

argocd-status: ## Show Argo CD applications status
	@echo "$(GREEN)📊 Argo CD apps status$(NC)"
	kubectl -n argocd get applications

rollback: ## Rollback deployment (usage: make rollback ENV=dev VERSION=v1.0.0)
	@echo "$(YELLOW)⏪ Rolling back deployment in $(ENV) to $(VERSION)...$(NC)"
	kubectl rollout undo deployment/puchi-fe -n puchi-$(ENV)
	kubectl rollout status deployment/puchi-fe -n puchi-$(ENV)
	@echo "$(GREEN)✅ Rollback completed$(NC)"

##@ Monitoring & Operations

status: ## Check deployment status
	@echo "$(BLUE)📊 Checking deployment status...$(NC)"
	@echo "\n$(YELLOW)=== Development ===$(NC)"
	kubectl get pods -n puchi-dev
	@echo "\n$(YELLOW)=== Staging ===$(NC)"
	kubectl get pods -n puchi-staging
	@echo "\n$(YELLOW)=== Production ===$(NC)"
	kubectl get pods -n puchi-prod

logs: ## Show logs (usage: make logs ENV=dev SERVICE=puchi-fe)
	@echo "$(BLUE)📋 Showing logs for $(SERVICE) in $(ENV)...$(NC)"
	kubectl logs -f deployment/$(SERVICE) -n puchi-$(ENV)

apisix-apply: ## Apply APISIX configurations
	@echo "$(BLUE)🛡️ Applying APISIX configurations...$(NC)"
	kubectl -n platform apply -f infra/k8s/platform/apisix/route/
	@echo "$(GREEN)✅ APISIX configurations applied$(NC)"

##@ Documentation

docs-serve: ## Serve documentation locally
	@echo "$(BLUE)📚 Serving documentation...$(NC)"
	@if command -v mkdocs >/dev/null 2>&1; then \
		mkdocs serve; \
	else \
		echo "$(YELLOW)⚠️  MkDocs not installed. Install with: pip install mkdocs$(NC)"; \
	fi

docs-build: ## Build documentation
	@echo "$(BLUE)📚 Building documentation...$(NC)"
	@if command -v mkdocs >/dev/null 2>&1; then \
		mkdocs build; \
	else \
		echo "$(YELLOW)⚠️  MkDocs not installed. Install with: pip install mkdocs$(NC)"; \
	fi
