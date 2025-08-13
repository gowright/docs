# Integration Testing Examples (1/4 - 25% Complete)

This section contains integration testing examples for the Gowright testing framework, demonstrating multi-system integration patterns and end-to-end workflows.

## 📁 Integration Testing Examples

### 🔗 Basic Integration Testing (`integration-testing/integration_basic.go`) ✅ **NEW**
Multi-system integration patterns with comprehensive workflow testing.

**Key Concepts Covered:**
- Multi-system integration patterns
- Database → API → UI flows
- System health checks
- Data synchronization testing
- End-to-end workflow validation
- Cross-system data consistency
- Integration error handling

**Example Usage:**
```bash
go run examples/integration-testing/integration_basic.go
```

**Integration Features:**
- Database setup and validation
- API endpoint testing
- UI workflow automation
- Cross-system data verification
- Health check monitoring
- Error recovery testing

### 🛒 E-commerce Workflow (`integration-testing/integration_ecommerce.go`) ⏳ **PLANNED**
Complete e-commerce integration testing from product browsing to order completion.

**Planned Features:**
- Product catalog integration
- Shopping cart functionality
- Payment processing workflows
- Order management systems
- Inventory synchronization
- Customer notification systems

### 🏗️ Microservices Testing (`integration-testing/integration_microservices.go`) ⏳ **PLANNED**
Microservices architecture testing with service discovery and communication.

**Planned Features:**
- Service discovery testing
- Inter-service communication
- Circuit breaker patterns
- Load balancing validation
- Service mesh integration
- Distributed tracing

### 📡 Event-Driven Architecture (`integration-testing/integration_event_driven.go`) ⏳ **PLANNED**
Event-driven system testing with message queues and event processing.

**Planned Features:**
- Message queue integration
- Event processing workflows
- Saga pattern testing
- Event sourcing validation
- CQRS pattern testing
- Eventual consistency verification

## 🚀 Quick Start

### Running Integration Examples

```bash
# Run basic integration testing
go run examples/integration-testing/integration_basic.go

# Run all integration examples
./examples/run_category.sh integration-testing

# Or run all examples
./examples/run_all_examples.sh
```

## 📋 Configuration Examples

### Basic Integration Configuration
```json
{
  "integrationConfig": {
    "database": {
      "driver": "sqlite3",
      "dsn": ":memory:",
      "timeout": "30s"
    },
    "api": {
      "baseURL": "http://localhost:8080",
      "timeout": "30s"
    },
    "ui": {
      "headless": false,
      "timeout": "30s"
    }
  }
}
```

### Advanced Integration Configuration
```json
{
  "integrationConfig": {
    "systems": {
      "database": {
        "primary": {
          "driver": "postgres",
          "dsn": "postgres://user:pass@localhost/testdb",
          "timeout": "30s"
        },
        "cache": {
          "driver": "redis",
          "dsn": "redis://localhost:6379/0",
          "timeout": "10s"
        }
      },
      "apis": {
        "userService": {
          "baseURL": "http://user-service:8080",
          "timeout": "30s"
        },
        "orderService": {
          "baseURL": "http://order-service:8080",
          "timeout": "30s"
        }
      },
      "ui": {
        "baseURL": "http://frontend:3000",
        "headless": false,
        "timeout": "30s"
      }
    },
    "healthChecks": {
      "enabled": true,
      "timeout": "10s",
      "retries": 3
    }
  }
}
```

## 🎯 Learning Path

### Beginner Path
1. **Start with Basic Integration**: `integration-testing/integration_basic.go`
2. **Understand Multi-System Flows**: Study database → API → UI patterns
3. **Practice Health Checks**: Learn system validation techniques

### Intermediate Path
1. **E-commerce Workflows**: Complete business process testing
2. **Error Handling**: Integration failure scenarios
3. **Performance Testing**: Multi-system performance validation

### Advanced Path
1. **Microservices Testing**: Service mesh and discovery patterns
2. **Event-Driven Systems**: Asynchronous processing validation
3. **Custom Integration Patterns**: Build domain-specific workflows

## 📊 Integration Test Patterns

### Database → API → UI Flow
```go
// 1. Setup database with test data
dbTest := gowright.NewDatabaseTest("User Setup", "primary")
dbTest.AddSetupQuery(`
    INSERT INTO users (username, email, active) 
    VALUES ('testuser', 'test@example.com', 1)
`)

// 2. Test API endpoint
apiTest := gowright.NewAPITest("User API Test")
apiTest.SetMethod("GET")
apiTest.SetURL("/api/users/testuser")
apiTest.AddExpectedStatusCode(200)

// 3. Validate UI displays user data
uiTest := gowright.NewUITest("User Profile UI")
uiTest.AddAction(gowright.NewNavigateAction("/profile/testuser"))
uiTest.AddAssertion(gowright.NewElementTextAssertion(".username", "testuser"))
uiTest.AddAssertion(gowright.NewElementTextAssertion(".email", "test@example.com"))
```

### Health Check Pattern
```go
// System health validation
healthSuite := gowright.NewTestSuite("System Health Checks")

// Database health
dbHealth := gowright.NewDatabaseTest("Database Health", "primary")
dbHealth.SetQuery("SELECT 1")
dbHealth.SetExpectedRowCount(1)

// API health
apiHealth := gowright.NewAPITest("API Health Check")
apiHealth.SetMethod("GET")
apiHealth.SetURL("/health")
apiHealth.AddExpectedStatusCode(200)

// UI health
uiHealth := gowright.NewUITest("UI Health Check")
uiHealth.AddAction(gowright.NewNavigateAction("/"))
uiHealth.AddAssertion(gowright.NewPageTitleAssertion("Application"))
```

### Data Synchronization Pattern
```go
// Test data consistency across systems
syncSuite := gowright.NewTestSuite("Data Synchronization")

// 1. Create data in primary system
createTest := gowright.NewAPITest("Create User")
createTest.SetMethod("POST")
createTest.SetURL("/api/users")
createTest.SetRequestBody(map[string]interface{}{
    "username": "syncuser",
    "email": "sync@example.com",
})

// 2. Verify data in secondary systems
dbVerify := gowright.NewDatabaseTest("Verify User in DB", "primary")
dbVerify.SetQuery("SELECT * FROM users WHERE username = 'syncuser'")
dbVerify.SetExpectedRowCount(1)

cacheVerify := gowright.NewDatabaseTest("Verify User in Cache", "cache")
cacheVerify.SetQuery("GET user:syncuser")
cacheVerify.AddCustomAssertion(func(result interface{}) error {
    if result == nil {
        return fmt.Errorf("user not found in cache")
    }
    return nil
})
```

## 🔧 Prerequisites

### Required
- **Go 1.23.0+** with toolchain 1.24.5
- **Database systems** (SQLite, PostgreSQL, MySQL)
- **Web browser** (Chrome/Chromium)
- **API services** or mock services

### Optional
- **Docker** for containerized services
- **Redis** for caching integration
- **Message queues** (RabbitMQ, Apache Kafka)
- **Service mesh** (Istio, Linkerd)

## 📚 Related Examples

- [API Testing Examples](api-testing.md) - REST API testing fundamentals
- [UI Testing Examples](ui-testing.md) - Browser automation basics
- [Database Testing Examples](database-testing.md) - Database operation testing
- [Advanced Patterns](advanced-patterns.md) - Enterprise integration patterns

## 🤝 Best Practices

### Integration Test Design
- **Test isolation**: Ensure tests don't interfere with each other
- **Data cleanup**: Clean up test data after execution
- **Health checks**: Validate system health before testing
- **Error handling**: Include comprehensive error scenarios

### Maintenance
- **Environment management**: Use consistent test environments
- **Service dependencies**: Manage service startup and shutdown
- **Data management**: Use realistic but safe test data
- **Monitoring**: Monitor integration test performance

---

These integration testing examples provide comprehensive coverage of multi-system testing scenarios, from basic database-API-UI flows to complex microservices architectures. The current basic integration example offers a solid foundation for building more complex integration test suites.