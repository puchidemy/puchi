# 🏗️ Puchi Platform - Build Automation
# Modern microservices-based language learning platform (self-host)

.PHONY: help init update clean build test lint format security-scan
.PHONY: dev-start dev-stop host-bootstrap host-base host-cloudflared host-apisix host-supertokens host-verify

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

dev-start: ## Start development environment (Tilt not required; optional)
	@echo "$(GREEN)🚀 Starting development environment...$(NC)"
	@echo "$(YELLOW)Tip: Use local Docker builds and deploy on host via infra/host-self scripts.$(NC)"

dev-stop: ## Stop development environment
	@echo "$(YELLOW)🛑 Stopping development environment...$(NC)"

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

##@ Self-Host (Infra)

host-bootstrap: ## Install k0s + kubeconfig + helm on host
	chmod +x infra/host-self/scripts/*.sh
	infra/host-self/scripts/bootstrap-k0s.sh

host-base: ## Apply base namespaces/policies/quotas
	kubectl apply -k infra/host-self/manifests/base

host-cloudflared: ## Deploy Cloudflared (requires TUNNEL_TOKEN)
	@if [ -z "$$TUNNEL_TOKEN" ]; then echo "TUNNEL_TOKEN not set" >&2; exit 1; fi
	infra/host-self/scripts/deploy-cloudflared.sh

host-apisix: ## Deploy APISIX (Gateway + Ingress Controller)
	infra/host-self/scripts/deploy-apisix.sh

host-supertokens: ## Deploy SuperTokens (requires ST_DB_URI, CHART_PATH)
	@if [ -z "$$ST_DB_URI" ] || [ -z "$$CHART_PATH" ]; then echo "ST_DB_URI or CHART_PATH not set" >&2; exit 1; fi
	infra/host-self/scripts/deploy-supertokens.sh

host-verify: ## Verify core namespaces and services
	kubectl -n platform get pods,svc || true
	kubectl -n apisix get pods,svc || true
	kubectl -n auth get pods,svc || true

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
