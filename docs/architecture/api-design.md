# API Design Guidelines

## Overview

This document outlines the API design principles and standards for the Puchi platform. Our APIs follow RESTful principles with modern best practices for security, performance, and developer experience.

## Design Principles

### 1. RESTful Design

- Use HTTP methods appropriately (GET, POST, PUT, DELETE, PATCH)
- Resource-based URLs
- Stateless operations
- Cacheable responses where appropriate

### 2. Consistency

- Consistent naming conventions
- Standardized response formats
- Uniform error handling
- Predictable URL patterns

### 3. Security First

- Authentication required for all endpoints
- Input validation and sanitization
- Rate limiting and abuse prevention
- HTTPS only

### 4. Developer Experience

- Clear and intuitive API design
- Comprehensive documentation
- Helpful error messages
- SDK support

## API Standards

### URL Structure

```
https://api.puchi.io.vn/v1/{resource}/{id}/{sub-resource}
```

**Examples:**

```
GET    /api/v1/users
GET    /api/v1/users/123
POST   /api/v1/users
PUT    /api/v1/users/123
DELETE /api/v1/users/123
GET    /api/v1/users/123/lessons
POST   /api/v1/users/123/lessons
```

### HTTP Methods

| Method | Usage                  | Idempotent | Body |
| ------ | ---------------------- | ---------- | ---- |
| GET    | Retrieve resource(s)   | Yes        | No   |
| POST   | Create new resource    | No         | Yes  |
| PUT    | Update entire resource | Yes        | Yes  |
| PATCH  | Partial update         | No         | Yes  |
| DELETE | Remove resource        | Yes        | No   |

### Status Codes

| Code | Meaning               | Usage                                     |
| ---- | --------------------- | ----------------------------------------- |
| 200  | OK                    | Successful GET, PUT, PATCH                |
| 201  | Created               | Successful POST                           |
| 204  | No Content            | Successful DELETE                         |
| 400  | Bad Request           | Invalid request data                      |
| 401  | Unauthorized          | Missing or invalid authentication         |
| 403  | Forbidden             | Insufficient permissions                  |
| 404  | Not Found             | Resource doesn't exist                    |
| 409  | Conflict              | Resource conflict (e.g., duplicate email) |
| 422  | Unprocessable Entity  | Validation errors                         |
| 429  | Too Many Requests     | Rate limit exceeded                       |
| 500  | Internal Server Error | Server error                              |

## Request/Response Formats

### Request Headers

```http
Authorization: Bearer <jwt_token>
Content-Type: application/json
Accept: application/json
X-Request-ID: <uuid>
X-Client-Version: 1.0.0
```

### Response Format

#### Success Response

```json
{
  "data": {
    "id": "123",
    "type": "user",
    "attributes": {
      "email": "user@example.com",
      "name": "John Doe",
      "created_at": "2024-01-15T10:30:00Z"
    }
  },
  "meta": {
    "request_id": "req_123",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

#### Collection Response

```json
{
  "data": [
    {
      "id": "123",
      "type": "user",
      "attributes": {
        "email": "user1@example.com",
        "name": "John Doe"
      }
    },
    {
      "id": "124",
      "type": "user",
      "attributes": {
        "email": "user2@example.com",
        "name": "Jane Smith"
      }
    }
  ],
  "meta": {
    "total": 2,
    "page": 1,
    "per_page": 20,
    "request_id": "req_123"
  },
  "links": {
    "self": "/api/v1/users?page=1",
    "next": "/api/v1/users?page=2",
    "prev": null
  }
}
```

#### Error Response

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The request contains invalid data",
    "details": [
      {
        "field": "email",
        "message": "Email format is invalid"
      }
    ]
  },
  "meta": {
    "request_id": "req_123",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

## Authentication & Authorization

### Authentication Methods

#### JWT Token Authentication

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### API Key Authentication

```http
X-API-Key: pk_live_1234567890abcdef
```

### Authorization Levels

| Level  | Description                | Example                       |
| ------ | -------------------------- | ----------------------------- |
| Public | No authentication required | Health checks, public content |
| User   | Authenticated user         | User profile, lessons         |
| Admin  | Administrative access      | User management, analytics    |

### Permission Model

```json
{
  "user": {
    "permissions": [
      "users:read:own",
      "users:write:own",
      "lessons:read",
      "lessons:write:own"
    ]
  },
  "admin": {
    "permissions": [
      "users:read:all",
      "users:write:all",
      "lessons:read:all",
      "lessons:write:all",
      "analytics:read:all"
    ]
  }
}
```

## Data Validation

### Input Validation

```json
{
  "email": {
    "type": "string",
    "format": "email",
    "required": true,
    "maxLength": 255
  },
  "password": {
    "type": "string",
    "required": true,
    "minLength": 8,
    "pattern": "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]"
  },
  "age": {
    "type": "integer",
    "minimum": 13,
    "maximum": 120
  }
}
```

### Validation Error Response

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The request contains invalid data",
    "details": [
      {
        "field": "email",
        "code": "INVALID_FORMAT",
        "message": "Email format is invalid"
      },
      {
        "field": "password",
        "code": "TOO_SHORT",
        "message": "Password must be at least 8 characters long"
      }
    ]
  }
}
```

## Pagination

### Query Parameters

```
GET /api/v1/users?page=2&per_page=20&sort=created_at&order=desc
```

### Response Format

```json
{
  "data": [...],
  "meta": {
    "total": 100,
    "page": 2,
    "per_page": 20,
    "total_pages": 5
  },
  "links": {
    "self": "/api/v1/users?page=2&per_page=20",
    "first": "/api/v1/users?page=1&per_page=20",
    "last": "/api/v1/users?page=5&per_page=20",
    "next": "/api/v1/users?page=3&per_page=20",
    "prev": "/api/v1/users?page=1&per_page=20"
  }
}
```

## Filtering & Sorting

### Filtering

```
GET /api/v1/users?filter[status]=active&filter[created_at][gte]=2024-01-01
```

### Sorting

```
GET /api/v1/users?sort=name&order=asc
GET /api/v1/users?sort=-created_at  # Descending order
```

### Field Selection

```
GET /api/v1/users?fields=id,name,email
```

## Rate Limiting

### Headers

```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1640995200
```

### Rate Limit Response

```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit exceeded. Try again later.",
    "retry_after": 60
  }
}
```

## Caching

### Cache Headers

```http
Cache-Control: public, max-age=3600
ETag: "abc123"
Last-Modified: Wed, 15 Jan 2024 10:30:00 GMT
```

### Conditional Requests

```http
If-None-Match: "abc123"
If-Modified-Since: Wed, 15 Jan 2024 10:30:00 GMT
```

## Webhooks

### Webhook Payload

```json
{
  "event": "user.created",
  "data": {
    "id": "123",
    "type": "user",
    "attributes": {
      "email": "user@example.com",
      "name": "John Doe"
    }
  },
  "meta": {
    "event_id": "evt_123",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

### Webhook Security

```http
X-Webhook-Signature: sha256=abc123...
X-Webhook-Timestamp: 1640995200
```

## API Versioning

### URL Versioning

```
https://api.puchi.io.vn/v1/users
https://api.puchi.io.vn/v2/users
```

### Header Versioning

```http
Accept: application/vnd.puchi.v1+json
API-Version: v1
```

### Version Lifecycle

| Stage      | Duration  | Support               |
| ---------- | --------- | --------------------- |
| Current    | 12 months | Full support          |
| Deprecated | 6 months  | Security updates only |
| Sunset     | -         | No support            |

## Error Handling

### Error Categories

| Category      | Code Range | Description            |
| ------------- | ---------- | ---------------------- |
| Client Error  | 4xx        | Request-related errors |
| Server Error  | 5xx        | Server-related errors  |
| Rate Limiting | 429        | Too many requests      |
| Maintenance   | 503        | Service unavailable    |

### Error Codes

```json
{
  "AUTHENTICATION_REQUIRED": "Authentication is required",
  "INVALID_TOKEN": "The provided token is invalid",
  "INSUFFICIENT_PERMISSIONS": "Insufficient permissions",
  "RESOURCE_NOT_FOUND": "The requested resource was not found",
  "VALIDATION_ERROR": "The request contains invalid data",
  "RATE_LIMIT_EXCEEDED": "Rate limit exceeded",
  "SERVICE_UNAVAILABLE": "Service is temporarily unavailable"
}
```

## API Documentation

### OpenAPI Specification

```yaml
openapi: 3.0.0
info:
  title: Puchi API
  version: 1.0.0
  description: Language learning platform API
servers:
  - url: https://api.puchi.io.vn/v1
paths:
  /users:
    get:
      summary: List users
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: per_page
          in: query
          schema:
            type: integer
            default: 20
      responses:
        "200":
          description: List of users
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/UserList"
```

### Interactive Documentation

- **Swagger UI**: Available at `/docs`
- **ReDoc**: Alternative documentation at `/redoc`
- **Postman Collection**: Available for download

## Testing

### Test Environment

```
https://api-dev.puchi.io.vn/v1/
https://api.puchi.io.vn/v1/
```

### Test Data

- Use test data that doesn't affect production
- Clean up test data after tests
- Use consistent test data across environments

### Mock Responses

```json
{
  "mock": true,
  "data": {
    "id": "test_user_123",
    "type": "user",
    "attributes": {
      "email": "test@example.com",
      "name": "Test User"
    }
  }
}
```

## Performance Guidelines

### Response Time Targets

| Endpoint Type | Target  | Maximum |
| ------------- | ------- | ------- |
| Simple GET    | < 100ms | 200ms   |
| Complex GET   | < 500ms | 1000ms  |
| POST/PUT      | < 300ms | 600ms   |
| DELETE        | < 200ms | 400ms   |

### Optimization Strategies

- Use database indexes
- Implement caching
- Optimize queries
- Use pagination
- Compress responses

## Security Best Practices

### Input Validation

- Validate all inputs
- Sanitize user data
- Use parameterized queries
- Implement CSRF protection

### Authentication

- Use HTTPS only
- Implement token expiration
- Support token refresh
- Log authentication events

### Authorization

- Implement least privilege
- Use role-based access control
- Validate permissions on each request
- Audit access logs

## Monitoring & Analytics

### Metrics

- Request count and response time
- Error rates by endpoint
- Authentication success/failure
- Rate limit hits

### Logging

```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "level": "info",
  "service": "user-service",
  "method": "GET",
  "path": "/api/v1/users/123",
  "status_code": 200,
  "response_time_ms": 45,
  "user_id": "123",
  "request_id": "req_123"
}
```

## Future Considerations

### GraphQL Support

Consider adding GraphQL for:

- Complex data fetching
- Real-time subscriptions
- Flexible query capabilities

### gRPC Integration

Use gRPC for:

- Internal service communication
- High-performance APIs
- Streaming data

### API Gateway Features

- Request/response transformation
- Circuit breaking
- Load balancing
- API analytics
