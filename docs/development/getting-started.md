# Getting Started with Puchi Development

## Prerequisites

Before you begin developing with Puchi, ensure you have the following tools installed:

### Required Tools

- [Docker](https://docs.docker.com/get-docker/) 20.10+
- [Docker Compose](https://docs.docker.com/compose/install/) 2.0+
- [Kubernetes](https://kubernetes.io/docs/tasks/tools/) 1.25+
- [Helm](https://helm.sh/docs/intro/install/) 3.10+
- [Git](https://git-scm.com/downloads) 2.30+

### Development Tools

- [Node.js](https://nodejs.org/) 18+
- [Go](https://golang.org/dl/) 1.21+
- [VS Code](https://code.visualstudio.com/) (recommended)
- [Tilt](https://docs.tilt.dev/install.html)

### Optional Tools

- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [k9s](https://k9scli.io/) (Kubernetes CLI)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/hoan02/puchi-app.git
cd puchi-app
```

### 2. Initialize the Project

```bash
make init
```

This will:

- Initialize all git submodules
- Set up the project structure
- Install dependencies

### 3. Start Development Environment

```bash
# Using Tilt (recommended)
make dev-start

```

### 4. Access the Applications

Once the development environment is running, you can access:

- **Frontend**: http://localhost:3000
- **API Gateway**: http://localhost:9080
- **Auth Service**: http://localhost:3567
- **APISIX Dashboard**: http://localhost:9000

## Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes

Work on your feature in the appropriate service:

- **Frontend**: `apps/frontend/`
- **Backend Services**: `apps/services/`
- **Infrastructure**: `infra/`

### 3. Test Your Changes

```bash
# Run unit tests
make test-unit

# Run integration tests
make test-integration

# Run all tests
make test
```

### 4. Code Quality Checks

```bash
# Lint your code
make lint

# Format your code
make format

# Security scan
make security-scan
```

### 5. Build and Deploy

```bash
# Build all services
make build

# Deploy to development
make deploy-dev
```

### 6. Submit a Pull Request

```bash
git add .
git commit -m "feat: add your feature description"
git push origin feature/your-feature-name
```

## Project Structure

```
puchi-app/
├── apps/                          # Application code
│   ├── frontend/                  # Next.js frontend
│   │   ├── src/                   # Source code
│   │   ├── public/                # Static assets
│   │   ├── k8s/                   # Kubernetes manifests
│   │   └── package.json           # Dependencies
│   └── services/                  # Microservices
│       ├── user-service/          # User management
│       ├── lesson-service/        # Lesson content
│       ├── notification-service/  # Notifications
│       ├── progress-service/      # Progress tracking
│       └── billing-service/       # Payments
├── infra/                         # Infrastructure
│   ├── k8s/                       # Kubernetes configs
│   ├── charts/                    # Helm charts
│   └── cloudflare/                # Cloudflare configs
├── docs/                          # Documentation
├── scripts/                       # Automation scripts
└── ci/                           # CI/CD pipelines
```

## Frontend Development

### Technology Stack

- **Framework**: Next.js 14
- **Language**: TypeScript
- **Styling**: TailwindCSS
- **State Management**: Zustand
- **API Client**: Axios
- **Testing**: Jest, React Testing Library

### Getting Started with Frontend

```bash
cd apps/frontend

# Install dependencies
npm install

# Start development server
npm run dev

# Run tests
npm test

# Build for production
npm run build
```

### Key Directories

- `src/app/`: Next.js app router pages
- `src/components/`: Reusable components
- `src/lib/`: Utility functions and configurations
- `src/services/`: API service functions
- `src/types/`: TypeScript type definitions

### Code Style

- Use TypeScript for all new code
- Follow the existing component patterns
- Use TailwindCSS for styling
- Write tests for new components

## Backend Development

### Technology Stack

- **Language**: Go 1.21+
- **Framework**: Gin (HTTP) + gRPC
- **Database**: PostgreSQL
- **Cache**: Redis
- **Testing**: Go testing package

### Getting Started with Backend

```bash
cd apps/services/user-service

# Install dependencies
go mod tidy

# Run tests
go test ./...

# Run the service
go run cmd/app/main.go
```

### Project Structure (Go Services)

```
user-service/
├── cmd/                    # Application entry points
│   └── app/
│       └── main.go        # Main application
├── internal/               # Private application code
│   ├── handler/           # HTTP handlers
│   ├── service/           # Business logic
│   ├── repository/        # Data access layer
│   └── model/             # Data models
├── pkg/                    # Public packages
├── migrations/             # Database migrations
├── docker-compose.yml      # Local development
└── Dockerfile             # Container image
```

### Code Style

- Follow Go conventions and best practices
- Use meaningful variable and function names
- Write comprehensive tests
- Document public APIs

## Database Development

### PostgreSQL Setup

```bash
# Start PostgreSQL locally
docker-compose up -d postgres

# Run migrations
make migrate-up

# Create a new migration
make migrate-create NAME=your_migration_name
```

### Database Best Practices

- Use migrations for schema changes
- Never modify existing migrations
- Use transactions for complex operations
- Index frequently queried columns
- Use connection pooling

## Testing

### Frontend Testing

```bash
cd apps/frontend

# Unit tests
npm test

# E2E tests
npm run test:e2e

# Coverage report
npm run test:coverage
```

### Backend Testing

```bash
cd apps/services/user-service

# Unit tests
go test ./...

# Integration tests
go test -tags=integration ./...

# Coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

### Test Best Practices

- Write tests for all new features
- Maintain >80% code coverage
- Use descriptive test names
- Test edge cases and error conditions
- Mock external dependencies

## Debugging

### Frontend Debugging

- Use browser developer tools
- React Developer Tools extension
- Console logging and breakpoints
- Network tab for API calls

### Backend Debugging

- Use VS Code debugger
- Logging with structured logs
- Database query analysis
- API endpoint testing with Postman

### Kubernetes Debugging

```bash
# Check pod status
kubectl get pods -n puchi-dev

# View pod logs
kubectl logs -f deployment/user-service -n puchi-dev

# Access pod shell
kubectl exec -it pod-name -n puchi-dev -- /bin/sh

# Port forward for local access
kubectl port-forward service/user-service 8080:80 -n puchi-dev
```

## Common Commands

### Make Commands

```bash
make help              # Show all available commands
make init              # Initialize project
make build             # Build all services
make test              # Run all tests
make lint              # Lint all code
make format            # Format all code
make deploy-dev        # Deploy to development
make status            # Check deployment status
make logs ENV=dev      # View logs
make clean             # Clean build artifacts
```

### Git Commands

```bash
git submodule update --init --recursive  # Update submodules
git submodule foreach git pull origin main  # Update all submodules
```

### Docker Commands

```bash
docker-compose up -d          # Start local services
docker-compose down           # Stop local services
docker-compose logs -f        # View logs
docker system prune -f        # Clean up Docker
```

## Troubleshooting

### Common Issues

#### Port Already in Use

```bash
# Find process using port
lsof -i :3000

# Kill process
kill -9 PID
```

#### Kubernetes Context Issues

```bash
# Check current context
kubectl config current-context

# Switch context
kubectl config use-context docker-desktop
```

#### Docker Issues

```bash
# Restart Docker Desktop
# Or reset Docker
docker system prune -a
```

#### Submodule Issues

```bash
# Reset submodules
git submodule deinit -f .
git submodule update --init --recursive
```

### Getting Help

1. **Check the logs**: Use `make logs` to view service logs
2. **Check documentation**: Look in the `docs/` directory
3. **Ask the team**: Use GitHub Discussions
4. **Create an issue**: Use GitHub Issues for bugs

## Next Steps

1. **Read the Architecture Documentation**: [System Architecture](architecture/system-architecture.md)
2. **Review the API Documentation**: [API Documentation](api-documentation.md)
3. **Check the Testing Strategy**: [Testing Strategy](testing-strategy.md)
4. **Learn the Code Style**: [Code Style Guide](code-style-guide.md)

## Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [Go Documentation](https://golang.org/doc/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [TailwindCSS Documentation](https://tailwindcss.com/docs)
