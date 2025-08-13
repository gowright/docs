# API Testing Examples

This section contains comprehensive API testing examples for the Gowright testing framework. The examples repository now includes 8 detailed API testing scenarios covering everything from basic REST operations to advanced GraphQL and WebSocket testing.

## 📁 API Testing Examples Structure (5/8 - 63% Complete)

The API testing examples are organized in the `examples/api-testing/` directory:

### 🔌 Core API Testing Examples

#### 1. **Basic API Testing** (`api-testing/api_basic.go`) ✅
Fundamental REST API testing patterns with GET, POST, PUT, DELETE operations.

**Key Concepts:**
- HTTP client configuration
- Request/response validation
- Status code assertions
- JSON response parsing
- Performance testing
- Error handling

#### 2. **Authentication Patterns** (`api-testing/api_authentication.go`) ✅
Comprehensive authentication testing including OAuth, JWT, API keys, and session-based auth.

**Authentication Types:**
- Bearer token authentication
- Basic authentication
- OAuth 2.0 flows
- JWT token validation
- API key authentication
- Session-based authentication
- Multi-step authentication
- Multi-factor authentication

#### 3. **CRUD Operations** (`api-testing/api_crud_operations.go`) ✅ **NEW**
Complete Create, Read, Update, Delete testing patterns with data validation.

**CRUD Features:**
- Resource creation and validation
- Data retrieval and filtering
- Update operations and partial updates
- Deletion and cascade operations
- Bulk operations
- Data integrity testing
- Error handling for invalid operations

#### 4. **Error Handling** (`api-testing/api_error_handling.go`) ✅ **NEW**
Comprehensive error scenario testing and validation.

**Error Scenarios:**
- 4xx client errors
- 5xx server errors
- Network and timeout errors
- Rate limiting responses
- Validation errors
- Custom error formats
- HTTP status code testing

### 🚀 Advanced API Testing Examples

#### 5. **Performance Testing** (`api-testing/api_performance.go`) ✅ **NEW**
Load testing and performance validation for APIs.

**Performance Features:**
- Load testing with concurrent requests
- Response time validation and analysis
- Throughput measurement
- Concurrent user simulation
- Resource usage monitoring
- Performance metrics and thresholds
- Performance regression detection

#### 6. **GraphQL Testing** (`api-testing/api_graphql.go`) ⏳
Comprehensive GraphQL API testing with queries, mutations, and subscriptions.

**GraphQL Features:**
- Query testing and validation
- Mutation operations
- Subscription handling
- Schema validation
- Error handling
- Performance optimization

#### 7. **WebSocket Testing** (`api-testing/api_websockets.go`) ⏳
Real-time WebSocket connection testing and message validation.

**WebSocket Features:**
- Connection establishment
- Message sending and receiving
- Connection lifecycle management
- Error handling
- Performance monitoring

#### 8. **Rate Limiting** (`api-testing/api_rate_limiting.go`) ⏳
Rate limiting behavior testing and validation.

**Rate Limiting Features:**
- Rate limit detection
- Backoff strategies
- Quota management
- Burst handling
- Recovery testing

## 🚀 Quick Start

### Running Individual Examples

```bash
# Basic API testing
go run examples/api-testing/api_basic.go

# Authentication patterns
go run examples/api-testing/api_authentication.go

# CRUD operations
go run examples/api-testing/api_crud_operations.go

# Error handling
go run examples/api-testing/api_error_handling.go

# Performance testing
go run examples/api-testing/api_performance.go
```

### Running All API Examples

```bash
# Run all API testing examples
./examples/run_category.sh api-testing

# Or run all examples
./examples/run_all_examples.sh
```

## 📋 Configuration Examples

### Basic API Configuration
```json
{
  "apiConfig": {
    "baseURL": "https://api.example.com",
    "timeout": "30s",
    "headers": {
      "User-Agent": "Gowright-Test-Client",
      "Accept": "application/json"
    },
    "retries": 3
  }
}
```

### Advanced API Configuration
```json
{
  "apiConfig": {
    "baseURL": "https://api.example.com",
    "timeout": "30s",
    "connectionPooling": {
      "maxIdleConns": 10,
      "maxIdleConnsPerHost": 5,
      "idleConnTimeout": "90s"
    },
    "authentication": {
      "type": "oauth2",
      "clientId": "your-client-id",
      "clientSecret": "your-client-secret",
      "tokenURL": "https://auth.example.com/token"
    },
    "rateLimiting": {
      "requestsPerSecond": 10,
      "burstSize": 20
    }
  }
}
```

## 🎯 Learning Path

### Beginner Path
1. **Start with Basic API Testing**: `api-testing/api_basic.go`
2. **Learn Authentication**: `api-testing/api_authentication.go`
3. **Practice CRUD Operations**: `api-testing/api_crud_operations.go`

### Intermediate Path
1. **Error Handling**: `api-testing/api_error_handling.go`
2. **Performance Testing**: `api-testing/api_performance.go`
3. **Rate Limiting**: `api-testing/api_rate_limiting.go`

### Advanced Path
1. **GraphQL Testing**: `api-testing/api_graphql.go`
2. **WebSocket Testing**: `api-testing/api_websockets.go`
3. **Integration with CI/CD**: See [CI/CD Integration](cicd.md)

## 📊 Example Code Snippets

### Basic API Test
```go
func TestBasicAPIOperations(t *testing.T) {
    framework := gowright.NewWithDefaults()
    defer framework.Close()
    
    apiTester := framework.GetAPITester()
    
    // GET request
    response, err := apiTester.Get("/users/1")
    assert.NoError(t, err)
    assert.Equal(t, 200, response.StatusCode)
    
    // POST request
    userData := map[string]interface{}{
        "name": "John Doe",
        "email": "john@example.com",
    }
    response, err = apiTester.Post("/users", userData)
    assert.NoError(t, err)
    assert.Equal(t, 201, response.StatusCode)
}
```

### Authentication Test
```go
func TestOAuth2Authentication(t *testing.T) {
    framework := gowright.NewWithDefaults()
    defer framework.Close()
    
    apiTester := framework.GetAPITester()
    
    // Configure OAuth2
    oauth2Config := &gowright.OAuth2Config{
        ClientID:     "your-client-id",
        ClientSecret: "your-client-secret",
        TokenURL:     "https://auth.example.com/token",
        Scopes:       []string{"read", "write"},
    }
    
    err := apiTester.SetOAuth2Config(oauth2Config)
    assert.NoError(t, err)
    
    // Make authenticated request
    response, err := apiTester.Get("/protected-resource")
    assert.NoError(t, err)
    assert.Equal(t, 200, response.StatusCode)
}
```

## 🔧 Prerequisites

### Required
- **Go 1.23.0+** with toolchain 1.24.5
- **Network connectivity** for API testing
- **Test API endpoints** or mock services

### Optional
- **Docker** for running mock services
- **PostgreSQL/MySQL** for database-backed APIs
- **Redis** for session/cache testing

## 📚 Related Examples

- [OpenAPI Testing Examples](openapi-testing.md) - OpenAPI specification validation and contract testing
- [Integration Testing Examples](integration-testing.md) - Multi-system API workflows and orchestration
- [Performance Testing](advanced-patterns.md) - Advanced performance testing patterns
- [CI/CD Integration](cicd.md) - API testing in CI/CD pipelines

## 🤝 Best Practices

### API Test Design
- **Test data isolation**: Use unique test data for each test
- **Environment management**: Test against appropriate environments
- **Error scenarios**: Include negative test cases
- **Performance validation**: Monitor response times

### Maintenance
- **Regular updates**: Keep tests updated with API changes
- **Documentation**: Document API test scenarios
- **Monitoring**: Monitor API test results over time
- **Cleanup**: Clean up test data after execution

---

These comprehensive API testing examples provide complete coverage of REST API testing scenarios, from basic CRUD operations to advanced GraphQL and WebSocket testing. The 8 examples in the repository offer real-world patterns for building robust API test suites.