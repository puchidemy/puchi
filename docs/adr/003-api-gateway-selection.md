# ADR-003: API Gateway Selection

## Status

**Accepted** - 2024-01-15

## Context

We need to select an API Gateway for the Puchi platform to handle:

- Request routing to microservices
- Authentication and authorization
- Rate limiting and throttling
- Load balancing
- Monitoring and logging
- API versioning
- Circuit breaking
- Request/response transformation

### Requirements

- **Performance**: High throughput and low latency
- **Scalability**: Horizontal scaling capabilities
- **Features**: Rich feature set for API management
- **Integration**: Easy integration with Kubernetes
- **Monitoring**: Comprehensive observability
- **Security**: Built-in security features
- **Cost**: Cost-effective solution

### Options Considered

1. **Kong**

   - Mature and feature-rich
   - Plugin ecosystem
   - Good documentation
   - Complex configuration

2. **Istio Gateway**

   - Service mesh integration
   - Kubernetes-native
   - Limited API management features
   - Complex setup

3. **AWS API Gateway**

   - Fully managed service
   - Rich feature set
   - Vendor lock-in
   - Cost concerns for high traffic

4. **APISIX**

   - High performance
   - Cloud-native design
   - Kubernetes integration
   - Active development

5. **Traefik**

   - Kubernetes-native
   - Automatic service discovery
   - Limited advanced features
   - Good for simple use cases

6. **NGINX Plus**
   - High performance
   - Advanced features
   - Commercial license required
   - Complex configuration

## Decision

We will use **Apache APISIX** as our API Gateway.

### Rationale

- **High Performance**: Built on NGINX with Lua, excellent performance
- **Cloud-Native**: Designed for Kubernetes and microservices
- **Rich Features**: Comprehensive API management capabilities
- **Open Source**: No licensing costs
- **Active Community**: Strong community support and development
- **Kubernetes Integration**: Native Kubernetes support
- **Plugin Architecture**: Extensible with custom plugins

### Implementation Details

#### Core Features

- **Request Routing**: Advanced routing based on headers, paths, and methods
- **Load Balancing**: Multiple load balancing algorithms
- **Rate Limiting**: Sophisticated rate limiting and throttling
- **Authentication**: JWT, OAuth 2.0, API key authentication
- **Monitoring**: Prometheus metrics and Grafana dashboards
- **Logging**: Structured logging with correlation IDs
- **Circuit Breaking**: Fault tolerance and resilience

#### Architecture Integration

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   External      │    │   APISIX         │    │  Microservices  │
│   Clients       │◄──►│   Gateway        │◄──►│                 │
│                 │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌──────────────────┐
                       │   Monitoring     │
                       │   & Logging      │
                       └──────────────────┘
```

#### Configuration Strategy

- **Route Configuration**: YAML-based route definitions
- **Plugin Management**: Centralized plugin configuration
- **Environment-Specific**: Different configs for dev/prod
- **GitOps**: Configuration managed through Git

#### Security Features

- **Authentication**: Integration with Supertokens
- **Authorization**: Role-based access control
- **Rate Limiting**: IP and user-based rate limiting
- **CORS**: Cross-origin resource sharing configuration
- **Security Headers**: Automatic security headers injection
- **SSL/TLS**: End-to-end encryption

## Implementation Plan

### Phase 1: Core Setup (Week 1-2)

- Deploy APISIX on Kubernetes
- Configure basic routing to services
- Set up monitoring and logging
- Implement basic rate limiting

### Phase 2: Authentication (Week 3-4)

- Integrate with Supertokens
- Configure JWT validation
- Set up API key authentication
- Implement CORS policies

### Phase 3: Advanced Features (Week 5-6)

- Configure advanced rate limiting
- Implement circuit breaking
- Set up request/response transformation
- Configure load balancing strategies

### Phase 4: Optimization (Week 7-8)

- Performance tuning
- Security hardening
- Monitoring optimization
- Documentation and runbooks

## Configuration Examples

### Route Configuration

```yaml
apiVersion: apisix.apache.org/v2beta3
kind: ApisixRoute
metadata:
  name: user-service-route
spec:
  http:
    - name: user-service
      match:
        hosts:
          - api.puchi.io.vn
        paths:
          - /api/v1/users/*
      backends:
        - serviceName: user-service
          servicePort: 80
      plugins:
        jwt-auth:
          secret: "your-secret-key"
        rate-limit:
          count: 100
          time_window: 60
        prometheus:
          prefer_name: true
```

### Plugin Configuration

```yaml
apiVersion: apisix.apache.org/v2beta3
kind: ApisixPluginConfig
metadata:
  name: security-config
spec:
  plugins:
    cors:
      allow_origins: "https://puchi.io.vn,https://dev.puchi.io.vn"
      allow_methods: "GET,POST,PUT,DELETE,OPTIONS"
      allow_headers: "Content-Type,Authorization"
    security-headers:
      x-frame-options: "DENY"
      x-content-type-options: "nosniff"
      x-xss-protection: "1; mode=block"
```

## Consequences

### Positive

- **Performance**: High throughput and low latency
- **Features**: Rich API management capabilities
- **Scalability**: Horizontal scaling with Kubernetes
- **Cost**: Open source, no licensing costs
- **Integration**: Native Kubernetes integration
- **Monitoring**: Comprehensive observability
- **Security**: Built-in security features

### Negative

- **Learning Curve**: Team needs to learn APISIX
- **Configuration**: Complex configuration for advanced features
- **Maintenance**: Need to maintain and update the gateway
- **Debugging**: Can be complex to debug routing issues

### Mitigation Strategies

- **Training**: Team training on APISIX
- **Documentation**: Comprehensive documentation and examples
- **Testing**: Extensive testing of configurations
- **Monitoring**: Proactive monitoring and alerting
- **Support**: Community support and professional services

## Monitoring and Observability

### Metrics

- **Request Metrics**: Request count, latency, error rates
- **System Metrics**: CPU, memory, network usage
- **Business Metrics**: API usage patterns, user behavior
- **Security Metrics**: Authentication failures, rate limit hits

### Dashboards

- **APISIX Dashboard**: Built-in dashboard for configuration
- **Grafana Dashboards**: Custom dashboards for monitoring
- **Prometheus Metrics**: Detailed metrics collection
- **Alerting**: Automated alerts for anomalies

### Logging

- **Access Logs**: Detailed request/response logging
- **Error Logs**: Error tracking and debugging
- **Audit Logs**: Security and compliance logging
- **Correlation IDs**: Request tracing across services

## Security Considerations

### Network Security

- **TLS Termination**: SSL/TLS termination at gateway
- **Network Policies**: Kubernetes network segmentation
- **DDoS Protection**: Rate limiting and circuit breaking
- **IP Whitelisting**: IP-based access control

### Application Security

- **Authentication**: JWT validation and API key management
- **Authorization**: Role-based access control
- **Input Validation**: Request validation and sanitization
- **Output Encoding**: Response encoding and sanitization

### Compliance

- **GDPR**: Data privacy and protection
- **PCI DSS**: Payment card industry compliance
- **SOC 2**: Security and availability compliance
- **Audit Trails**: Comprehensive audit logging

## Performance Optimization

### Caching Strategy

- **Response Caching**: Cache frequently requested data
- **Upstream Caching**: Cache responses from backend services
- **CDN Integration**: Integration with Cloudflare CDN
- **Cache Invalidation**: Smart cache invalidation strategies

### Load Balancing

- **Round Robin**: Default load balancing algorithm
- **Least Connections**: Route to least busy upstream
- **IP Hash**: Consistent routing based on client IP
- **Health Checks**: Automatic health checking and failover

### Connection Management

- **Connection Pooling**: Efficient connection reuse
- **Keep-Alive**: HTTP keep-alive connections
- **Timeout Configuration**: Appropriate timeout settings
- **Circuit Breaking**: Automatic failover and recovery

## Future Considerations

### Planned Enhancements

- **GraphQL Support**: GraphQL query processing
- **WebSocket Support**: Real-time communication
- **gRPC Support**: High-performance RPC communication
- **Machine Learning**: AI-driven traffic management

### Technology Evolution

- **Service Mesh**: Integration with Istio service mesh
- **Edge Computing**: Edge deployment for low latency
- **Serverless**: Function-as-a-Service integration
- **Multi-Cloud**: Cross-cloud deployment strategies

## References

- [Apache APISIX Documentation](https://apisix.apache.org/docs/)
- [APISIX Kubernetes Integration](https://apisix.apache.org/docs/ingress-controller/getting-started/)
- [API Gateway Patterns](https://microservices.io/patterns/apigateway.html)
- [Kong vs APISIX Comparison](https://apisix.apache.org/docs/general/comparison/)
