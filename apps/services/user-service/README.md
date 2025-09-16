# Puchi User Service

A microservice for user management and translation functionality built with Go, following clean architecture principles.

## 🚀 Features

- **Translation Service**: Translate text using Google Translate API
- **History Management**: Store and retrieve translation history
- **Multiple Protocols**: HTTP REST API, gRPC, and AMQP RPC
- **Swagger Documentation**: Auto-generated API documentation
- **Health Checks**: Built-in health monitoring endpoints
- **Metrics**: Prometheus metrics integration

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   HTTP API      │    │   gRPC API      │    │   AMQP RPC      │
│   (Port 8002)   │    │   (Port 9002)   │    │   (Port 5672)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Application   │
                    │     Layer       │
                    └─────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Repository    │
                    │     Layer       │
                    └─────────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         │                       │                       │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   PostgreSQL    │    │   Google API    │    │   RabbitMQ      │
│   (Port 5432)   │    │   (External)    │    │   (Port 5672)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🛠️ Tech Stack

- **Language**: Go 1.24
- **Framework**: Fiber (HTTP), gRPC, AMQP
- **Database**: PostgreSQL
- **Message Queue**: RabbitMQ
- **Documentation**: Swagger/OpenAPI
- **Monitoring**: Prometheus
- **Containerization**: Docker & Docker Compose

## 📋 Prerequisites

- Go 1.24+
- Docker & Docker Compose
- PostgreSQL
- RabbitMQ

## 🚀 Quick Start

### Using Docker Compose

```bash
# Start all services
make compose-up-all

# Or start only dependencies
make compose-up
```

### Manual Setup

```bash
# Install dependencies
make deps

# Run migrations
make migrate-up

# Start the service
make run
```

## 📚 API Endpoints

### HTTP API (Port 8002)

- `GET /v1/translation/history` - Get translation history
- `POST /v1/translation/do-translate` - Translate text
- `GET /healthz` - Health check
- `GET /metrics` - Prometheus metrics
- `GET /swagger/*` - API documentation

### gRPC API (Port 9002)

- Translation service with history management

### AMQP RPC (Port 5672)

- Asynchronous translation requests

## 🧪 Testing

```bash
# Run all tests
make test

# Run integration tests
make integration-test

# Run pre-commit checks
make pre-commit
```

## 📊 Monitoring

- **Health Check**: `http://localhost:8002/healthz`
- **Metrics**: `http://localhost:8002/metrics`
- **Swagger UI**: `http://localhost:8002/swagger/`

## 🔧 Development

```bash
# Format code
make format

# Run linter
make linter-golangci

# Generate mocks
make mock

# Generate swagger docs
make swag-v1
```

## 📦 Environment Variables

```bash
# App
APP_NAME=puchi-user-service
APP_VERSION=1.0.0

# HTTP settings
HTTP_PORT=8002
HTTP_USE_PREFORK_MODE=false

# gRPC
GRPC_PORT=9002

# Database
PG_URL=postgres://user:password@localhost:5432/userdb
PG_POOL_MAX=2

# RabbitMQ
RMQ_URL=amqp://guest:guest@localhost:5672/
RMQ_RPC_SERVER=user_rpc_server
RMQ_RPC_CLIENT=user_rpc_client

# Features
METRICS_ENABLED=true
SWAGGER_ENABLED=true
LOG_LEVEL=debug
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Run pre-commit checks (`make pre-commit`)
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
