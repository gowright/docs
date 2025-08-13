# Best Practices

Best practices for using the Gowright testing framework effectively.

## Test Organization

### Modular Test Structure
- Use individual testers for focused testing scenarios
- Combine modules only when necessary for integration testing
- Organize tests by service or functional domain in microservices architectures

### Service-Specific Testing
- Create separate test suites for each microservice
- Use service-specific configurations and database connections
- Implement parallel testing for independent services
- Maintain service test isolation to prevent cross-contamination

### Test Suite Organization
```go
// Good: Service-specific test organization
func TestUserService() {
    userServiceTests := createUserServiceTestSuite()
    // Run user service specific tests
}

func TestOrderService() {
    orderServiceTests := createOrderServiceTestSuite()
    // Run order service specific tests
}

// Good: Combined integration testing
func TestUserOrderFlow() {
    integrationTests := createUserOrderIntegrationSuite()
    // Test cross-service interactions
}
```

## Performance Optimization

### Parallel Execution
- Use parallel testing for independent test suites
- Configure appropriate concurrency limits based on system resources
- Implement proper resource isolation between parallel tests

### Resource Management
- Use connection pooling for database and HTTP clients
- Implement proper cleanup in test teardown methods
- Monitor resource usage during test execution

### Service Testing Optimization
```go
// Good: Parallel service testing
func testIndividualServices() {
    var wg sync.WaitGroup
    results := make(chan ServiceTestResult, len(services))
    
    for _, service := range services {
        wg.Add(1)
        go func(svc ServiceConfig) {
            defer wg.Done()
            result := testService(svc)
            results <- result
        }(service)
    }
    
    wg.Wait()
    close(results)
}
```

## Plugin Development

### Custom Plugin Best Practices
- Implement proper initialization and cleanup methods
- Use meaningful plugin names and descriptions
- Handle errors gracefully and provide informative error messages
- Document plugin configuration requirements

### Plugin Types
- **Metrics Plugins**: For collecting custom performance data
- **Notification Plugins**: For sending alerts to external systems
- **Reporting Plugins**: For generating custom report formats
- **Business Logic Plugins**: For domain-specific validation rules

### Plugin Implementation Example
```go
type CustomPlugin struct {
    name   string
    config interface{}
}

func (p *CustomPlugin) GetName() string {
    return p.name
}

func (p *CustomPlugin) Initialize(config interface{}) error {
    p.config = config
    // Initialize plugin resources
    return nil
}

func (p *CustomPlugin) Cleanup() error {
    // Clean up plugin resources
    return nil
}
```

## Microservices Testing

### Service Isolation
- Test each microservice independently before integration testing
- Use separate databases and configurations for each service
- Implement proper service mocking for dependencies

### Integration Testing Strategy
- Start with individual service testing
- Progress to pairwise service interaction testing
- Finish with full orchestration testing

### Service Orchestration Testing
```go
// Good: Structured orchestration testing
func testServiceOrchestration() {
    orchestrationTests := []OrchestrationTest{
        {
            Name: "E-commerce Purchase Flow",
            Services: []string{"user-service", "inventory-service", "order-service", "payment-service"},
            Scenario: "complete_purchase",
        },
    }
    
    for _, test := range orchestrationTests {
        result := runOrchestrationTest(test)
        // Handle results
    }
}
```

## Environment Configuration

### Environment-Specific Settings
- Use environment variables for configuration overrides
- Implement different configurations for development, testing, staging, and production
- Avoid hardcoded values in test code

### Configuration Management
```go
// Good: Environment-based configuration
func loadEnvironmentConfig() *gowright.Config {
    env := getEnvironment()
    
    switch env {
    case "development":
        return loadDevelopmentConfig()
    case "testing":
        return loadTestingConfig()
    case "production":
        return loadProductionConfig()
    default:
        return gowright.DefaultConfig()
    }
}
```

## Error Handling

### Graceful Error Handling
- Implement proper error handling in all test methods
- Use meaningful error messages for debugging
- Implement retry mechanisms for flaky operations
- Log errors with sufficient context for troubleshooting

### Service Testing Error Handling
```go
// Good: Comprehensive error handling
func testService(service ServiceConfig) ServiceTestResult {
    framework := gowright.NewFramework()
    defer framework.Close()
    
    err := framework.Initialize(config)
    if err != nil {
        return ServiceTestResult{
            ServiceName: service.Name,
            Status:      "failed",
            Errors:      []string{err.Error()},
        }
    }
    
    // Execute tests with proper error handling
}
```

## Maintenance

### Test Suite Maintenance
- Regularly review and update test configurations
- Remove obsolete tests and update test data
- Monitor test execution times and optimize slow tests
- Keep test dependencies up to date

### Plugin Maintenance
- Regularly update plugin dependencies
- Monitor plugin performance impact
- Document plugin configuration changes
- Test plugin compatibility with framework updates

### Service Testing Maintenance
- Update service configurations when services change
- Maintain service test data and mock responses
- Monitor service test execution in CI/CD pipelines
- Update orchestration tests when business processes change

## Development Workflow

### Local Testing Before Commits
- Always run comprehensive local testing before committing changes
- Use the MCP server's local testing script to replicate CI/CD pipeline locally
- Validate both framework and MCP server changes in development environment

### MCP Server Development
For MCP server development, use the comprehensive local testing script:

```bash
# Unix/Linux/macOS
cd mcpserver
./test-local.sh

# Windows
cd mcpserver
test-local.bat
# or
npm run test-local-win
```

This script performs:
- Node.js version validation (requires 18+)
- Dependency installation and verification
- TypeScript type checking and compilation
- Code formatting validation (if Prettier is configured)
- Build compilation and executable creation
- Build validation (verifies executable file exists with proper permissions)
- Test execution and coverage analysis
- Package integrity verification
- Bundle size analysis and optimization checks
- Code quality analysis (TODO/FIXME comments, console.log usage)

### Framework Development
For framework development, use the comprehensive Make targets:

```bash
# Run complete local CI/CD simulation
make ci

# Individual validation steps
make test-all          # All test types
make lint             # Code quality
make security         # Security scanning
make examples         # Validate examples
```

### Example Validation
Always validate examples before committing:

```bash
# Comprehensive example validation
./examples/validate_examples.sh
```

The validation script checks:
- **Structure Requirements**: Build tags, package declarations, main functions
- **Import Validation**: Proper Gowright framework imports
- **Compilation Testing**: Syntax and dependency verification
- **Documentation**: README and index files
- **Script Permissions**: Executable permissions on shell scripts

**Example Structure Requirements:**
```go
//go:build ignore
// +build ignore

// Example: Feature Description
// This example demonstrates specific functionality.

package main

import (
    "fmt"
    "github.com/gowright/framework/pkg/gowright"
)

func main() {
    // Example implementation
}
```

### Pre-Commit Checklist
- [ ] Local testing script passes completely
- [ ] All tests pass (unit, integration, performance)
- [ ] Code formatting and linting pass
- [ ] Security scans show no issues
- [ ] Example validation passes (`./examples/validate_examples.sh`)
- [ ] Documentation updated for any API changes
- [ ] Examples updated if functionality changed
- [ ] Configuration files validated