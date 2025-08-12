# Basic Usage Examples

This document provides fundamental examples of using the Gowright testing framework. These examples demonstrate the core concepts and basic setup patterns that form the foundation for more advanced testing scenarios.

## Table of Contents

1. [Framework Initialization](#framework-initialization)
2. [Configuration Examples](#configuration-examples)
3. [Basic Test Patterns](#basic-test-patterns)
4. [Resource Management](#resource-management)
5. [Error Handling](#error-handling)
6. [Logging and Debugging](#logging-and-debugging)

## Framework Initialization

### Default Configuration

The simplest way to get started with Gowright is using the default configuration:

```go
package main

import (
    "fmt"
    "log"
    "time"
    
    "github.com/gowright/framework/pkg/gowright"
)

func main() {
    // Create framework with default configuration
    framework := gowright.NewWithDefaults()
    defer framework.Close()
    
    // Initialize the framework
    if err := framework.Initialize(); err != nil {
        log.Fatalf("Failed to initialize framework: %v", err)
    }
    
    fmt.Println("Gowright framework initialized successfully!")
    
    // Framework is ready for testing
    fmt.Println("Framework ready for testing operations")
}


### Custom Configuration

For more control over the framework behavior, create a custom configuration:

```go
package main

import (
    "fmt"
    "log"
    "time"
    
    "github.com/gowright/framework/pkg/gowright"
)

func main() {
    // Create custom configuration
    config := &gowright.Config{
        LogLevel: "info",
        Parallel: true,
        MaxRetries: 3,
        BrowserConfig: &gowright.BrowserConfig{
            Headless:   true,
            Timeout:    30 * time.Second,
            WindowSize: &gowright.WindowSize{Width: 1920, Height: 1080},
        },
        APIConfig: &gowright.APIConfig{
            BaseURL: "https://api.example.com",
            Timeout: 10 * time.Second,
            Headers: map[string]string{
                "User-Agent": "Gowright-Test-Client",
                "Accept":     "application/json",
            },
        },
        DatabaseConfig: &gowright.DatabaseConfig{
            Connections: map[string]*gowright.DBConnection{
                "main": {
                    Driver: "postgres",
                    DSN:    "postgres://user:pass@localhost/testdb?sslmode=disable",
                },
                "cache": {
                    Driver: "redis",
                    DSN:    "redis://localhost:6379/0",
                },
            },
        },
        AppiumConfig: &gowright.AppiumConfig{
            ServerURL: "http://localhost:4723",
            Timeout:   30 * time.Second,
            DefaultCapabilities: gowright.AppiumCapabilities{
                NewCommandTimeout: 60,
                NoReset:           true,
            },
        },
        // OpenAPI testing is handled separately via openapi.NewOpenAPITester()
        // See OpenAPI Testing documentation for detailed examples
        ReportConfig: &gowright.ReportConfig{
            LocalReports: gowright.LocalReportConfig{
                JSON:      true,
                HTML:      true,
                OutputDir: "./test-reports",
            },
        },
        ParallelRunnerConfig: &gowright.ParallelRunnerConfig{
            MaxConcurrency: 4,
            ResourceLimits: gowright.ResourceLimits{
                MaxMemoryMB:      1024,
                MaxCPUPercent:    80,
                MaxOpenFiles:     100,
                MaxNetworkConns:  50,
            },
        },
    }
    
    // Create framework with custom configuration
    framework := gowright.New(config)
    defer framework.Close()
    
    // Initialize the framework
    if err := framework.Initialize(); err != nil {
        log.Fatalf("Failed to initialize framework: %v", err)
    }
    
    fmt.Println("Gowright framework initialized with custom configuration!")
}
```

## Configuration Examples

### Configuration from File

Load configuration from a JSON file for better maintainability:

```go
package main

import (
    "fmt"
    "log"
    
    "github.com/gowright/framework/pkg/gowright"
)

func main() {
    // Load configuration from file
    config, err := gowright.LoadConfigFromFile("gowright-config.json")
    if err != nil {
        log.Fatalf("Failed to load configuration: %v", err)
    }
    
    // Create framework with loaded configuration
    framework := gowright.New(config)
    defer framework.Close()
    
    // Initialize the framework
    if err := framework.Initialize(); err != nil {
        log.Fatalf("Failed to initialize framework: %v", err)
    }
    
    fmt.Println("Framework initialized from configuration file!")
}
```

Example `gowright-config.json`:

```json
{
  "log_level": "info",
  "parallel": true,
  "max_retries": 3,
  "browser_config": {
    "headless": true,
    "timeout": "30s",
    "window_size": {
      "width": 1920,
      "height": 1080
    }
  },
  "api_config": {
    "base_url": "https://api.example.com",
    "timeout": "10s",
    "headers": {
      "User-Agent": "Gowright-Test-Client",
      "Accept": "application/json"
    }
  },
  "database_config": {
    "connections": {
      "main": {
        "driver": "postgres",
        "dsn": "postgres://user:pass@localhost/testdb?sslmode=disable"
      }
    }
  },
  "appium_config": {
    "server_url": "http://localhost:4723",
    "timeout": "30s",
    "default_capabilities": {
      "newCommandTimeout": 60,
      "noReset": true
    }
  },
  // OpenAPI testing is handled separately via openapi.NewOpenAPITester()
  // See OpenAPI Testing documentation for detailed examples
  "report_config": {
    "local_reports": {
      "json": true,
      "html": true,
      "output_dir": "./test-reports"
    }
  },
  "parallel_runner_config": {
    "max_concurrency": 4,
    "resource_limits": {
      "max_memory_mb": 1024,
      "max_cpu_percent": 80,
      "max_open_files": 100,
      "max_network_conns": 50
    }
  }
}
```

### Environment-Based Configuration

Use environment variables to override configuration values:

```go
package main

import (
    "fmt"
    "log"
    "os"
    "strconv"
    "time"
    
    "github.com/gowright/framework/pkg/gowright"
)

func main() {
    // Start with default configuration
    config := gowright.DefaultConfig()
    
    // Override with environment variables
    if baseURL := os.Getenv("API_BASE_URL"); baseURL != "" {
        config.APIConfig.BaseURL = baseURL
    }
    
    if timeoutStr := os.Getenv("API_TIMEOUT"); timeoutStr != "" {
        if timeout, err := time.ParseDuration(timeoutStr); err == nil {
            config.APIConfig.Timeout = timeout
        }
    }
    
    if headlessStr := os.Getenv("BROWSER_HEADLESS"); headlessStr != "" {
        if headless, err := strconv.ParseBool(headlessStr); err == nil {
            config.BrowserConfig.Headless = headless
        }
    }
    
    if dbDSN := os.Getenv("DATABASE_DSN"); dbDSN != "" {
        config.DatabaseConfig.Connections["main"].DSN = dbDSN
    }
    
    // Create framework with environment-aware configuration
    framework := gowright.New(config)
    defer framework.Close()
    
    if err := framework.Initialize(); err != nil {
        log.Fatalf("Failed to initialize framework: %v", err)
    }
    
    fmt.Println("Framework initialized with environment configuration!")
}
```

## Basic Test Patterns

### Simple Test Function

```go
package main

import (
    "fmt"
    "testing"
    
    "github.com/gowright/framework/pkg/gowright"
    "github.com/stretchr/testify/assert"
)

func TestBasicFrameworkUsage(t *testing.T) {
    // Initialize framework
    framework := gowright.NewWithDefaults()
    defer framework.Close()
    
    err := framework.Initialize()
    assert.NoError(t, err, "Framework should initialize without error")
    
    // Verify framework is ready
    assert.True(t, framework.IsInitialized(), "Framework should be initialized")
    
    fmt.Println("Basic framework test passed!")
}

func TestFrameworkWithCustomConfig(t *testing.T) {
    // Create custom configuration
    config := &gowright.Config{
        LogLevel: "debug",
        Parallel: false, // Disable parallel for this test
    }
    
    framework := gowright.New(config)
    defer framework.Close()
    
    err := framework.Initialize()
    assert.NoError(t, err, "Framework should initialize with custom config")
    
    // Test configuration was applied
    assert.Equal(t, "debug", framework.GetLogLevel())
    assert.False(t, framework.IsParallelEnabled())
}
```

### Test with Setup and Teardown

```go
package main

import (
    "fmt"
    "testing"
    
    "github.com/gowright/framework/pkg/gowright"
    "github.com/stretchr/testify/assert"
)

func TestWithSetupTeardown(t *testing.T) {
    var framework *gowright.Framework
    
    // Setup
    setup := func() error {
        framework = gowright.NewWithDefaults()
        return framework.Initialize()
    }
    
    // Teardown
    teardown := func() error {
        if framework != nil {
            return framework.Close()
        }
        return nil
    }
    
    // Execute setup
    err := setup()
    assert.NoError(t, err, "Setup should complete without error")
    defer func() {
        err := teardown()
        assert.NoError(t, err, "Teardown should complete without error")
    }()
    
    // Test logic
    assert.True(t, framework.IsInitialized(), "Framework should be initialized after setup")
    
    fmt.Println("Test with setup/teardown completed!")
}
```

## Resource Management

### Memory and CPU Monitoring

```go
package main

import (
    "fmt"
    "log"
    "time"
    
    "github.com/gowright/framework/pkg/gowright"
)

func main() {
    // Create framework with resource limits
    config := &gowright.Config{
        ParallelRunnerConfig: &gowright.ParallelRunnerConfig{
            ResourceLimits: gowright.ResourceLimits{
                MaxMemoryMB:      512,
                MaxCPUPercent:    70,
                MaxOpenFiles:     50,
                MaxNetworkConns:  25,
            },
        },
    }
    
    framework := gowright.New(config)
    defer framework.Close()
    
    if err := framework.Initialize(); err != nil {
        log.Fatalf("Failed to initialize framework: %v", err)
    }
    
    // Get resource manager
    resourceManager := framework.GetResourceManager()
    
    // Monitor resource usage
    go func() {
        ticker := time.NewTicker(5 * time.Second)
        defer ticker.Stop()
        
        for range ticker.C {
            usage := resourceManager.GetCurrentUsage()
            fmt.Printf("Resources: Memory=%dMB CPU=%.1f%% Files=%d Connections=%d\n",
                usage.MemoryMB, usage.CPUPercent, usage.OpenFiles, usage.NetworkConns)
            
            // Check if limits are exceeded
            if usage.MemoryMB > 512 {
                fmt.Println("Warning: Memory usage exceeded limit!")
            }
            if usage.CPUPercent > 70 {
                fmt.Println("Warning: CPU usage exceeded limit!")
            }
        }
    }()
    
    // Simulate some work
    time.Sleep(30 * time.Second)
    
    fmt.Println("Resource monitoring completed!")
}
```

### Connection Pooling

```go
package main

import (
    "fmt"
    "log"
    
    "github.com/gowright/framework/pkg/gowright"
)

func main() {
    // Configure connection pooling
    config := &gowright.Config{
        DatabaseConfig: &gowright.DatabaseConfig{
            Connections: map[string]*gowright.DBConnection{
                "main": {
                    Driver:      "postgres",
                    DSN:         "postgres://user:pass@localhost/testdb?sslmode=disable",
                    MaxOpenConns: 10,
                    MaxIdleConns: 5,
                    MaxLifetime:  "1h",
                },
            },
        },
        APIConfig: &gowright.APIConfig{
            BaseURL: "https://api.example.com",
            ConnectionPooling: &gowright.ConnectionPoolConfig{
                MaxIdleConns:        10,
                MaxIdleConnsPerHost: 5,
                IdleConnTimeout:     "90s",
            },
        },
    }
    
    framework := gowright.New(config)
    defer framework.Close()
    
    if err := framework.Initialize(); err != nil {
        log.Fatalf("Failed to initialize framework: %v", err)
    }
    
    fmt.Println("Framework initialized with connection pooling!")
    
    // Connection pools are automatically managed by the framework
    // Database connections will be reused across tests
    // HTTP connections will be pooled for API testing
}
```

## Error Handling

### Retry Configuration

```go
package main

import (
    "context"
    "fmt"
    "log"
    "time"
    
    "github.com/gowright/framework/pkg/gowright"
)

func main() {
    // Configure retry behavior
    config := &gowright.Config{
        MaxRetries: 3,
        RetryConfig: &gowright.RetryConfig{
            MaxRetries:   3,
            InitialDelay: time.Second,
            MaxDelay:     10 * time.Second,
            Multiplier:   2.0,
        },
    }
    
    framework := gowright.New(config)
    defer framework.Close()
    
    if err := framework.Initialize(); err != nil {
        log.Fatalf("Failed to initialize framework: %v", err)
    }
    
    // Example of using retry functionality
    ctx := context.Background()
    retryConfig := framework.GetRetryConfig()
    
    err := gowright.RetryWithBackoff(ctx, retryConfig, func() error {
        // Simulate an operation that might fail
        fmt.Println("Attempting operation...")
        
        // This would be your actual test operation
        // For demo purposes, we'll simulate success after some attempts
        return nil
    })
    
    if err != nil {
        log.Printf("Operation failed after retries: %v", err)
    } else {
        fmt.Println("Operation succeeded!")
    }
}
```

### Graceful Error Recovery

```go
package main

import (
    "fmt"
    "log"
    "testing"
    
    "github.com/gowright/framework/pkg/gowright"
    "github.com/stretchr/testify/assert"
)

func TestGracefulErrorRecovery(t *testing.T) {
    framework := gowright.NewWithDefaults()
    defer framework.Close()
    
    err := framework.Initialize()
    assert.NoError(t, err)
    
    // Test error recovery mechanisms
    t.Run("RecoverFromPanic", func(t *testing.T) {
        defer func() {
            if r := recover(); r != nil {
                fmt.Printf("Recovered from panic: %v\n", r)
                // Framework should still be functional after recovery
                assert.True(t, framework.IsInitialized())
            }
        }()
        
        // Simulate a panic scenario
        // panic("simulated panic")
        
        // In real scenarios, the framework handles panics gracefully
        fmt.Println("Error recovery test completed")
    })
    
    t.Run("HandleResourceExhaustion", func(t *testing.T) {
        // Test framework behavior when resources are exhausted
        resourceManager := framework.GetResourceManager()
        
        // Check current resource usage
        usage := resourceManager.GetCurrentUsage()
        fmt.Printf("Current resource usage: %+v\n", usage)
        
        // Framework should handle resource exhaustion gracefully
        assert.NotNil(t, resourceManager)
    })
}
```

## Logging and Debugging

### Debug Mode Configuration

```go
package main

import (
    "fmt"
    "log"
    
    "github.com/gowright/framework/pkg/gowright"
)

func main() {
    // Enable debug logging
    config := &gowright.Config{
        LogLevel: "debug",
        DebugConfig: &gowright.DebugConfig{
            EnableVerboseLogging: true,
            LogRequests:          true,
            LogResponses:         true,
            LogDatabaseQueries:   true,
            LogBrowserActions:    true,
            SaveScreenshots:     true,
            ScreenshotDir:       "./debug-screenshots",
        },
    }
    
    framework := gowright.New(config)
    defer framework.Close()
    
    if err := framework.Initialize(); err != nil {
        log.Fatalf("Failed to initialize framework: %v", err)
    }
    
    fmt.Println("Framework initialized in debug mode!")
    
    // All operations will now be logged in detail
    // Screenshots will be saved for UI operations
    // Database queries will be logged
    // API requests/responses will be logged
}
```

### Custom Logger Integration

```go
package main

import (
    "fmt"
    "log"
    "os"
    
    "github.com/gowright/framework/pkg/gowright"
    "github.com/sirupsen/logrus"
)

func main() {
    // Create custom logger
    logger := logrus.New()
    logger.SetLevel(logrus.DebugLevel)
    logger.SetFormatter(&logrus.JSONFormatter{})
    
    // Optional: log to file
    logFile, err := os.OpenFile("gowright.log", os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666)
    if err == nil {
        logger.SetOutput(logFile)
        defer logFile.Close()
    }
    
    // Configure framework with custom logger
    config := &gowright.Config{
        LogLevel: "debug",
        Logger:   logger,
    }
    
    framework := gowright.New(config)
    defer framework.Close()
    
    if err := framework.Initialize(); err != nil {
        log.Fatalf("Failed to initialize framework: %v", err)
    }
    
    fmt.Println("Framework initialized with custom logger!")
    
    // All framework logs will now use the custom logger
    // Logs will be in JSON format and written to file
}
```

## Best Practices

### 1. Always Use Defer for Cleanup

```go
func TestExample(t *testing.T) {
    framework := gowright.NewWithDefaults()
    defer framework.Close() // Always cleanup resources
    
    // Your test code here
}
```

### 2. Check Initialization Errors

```go
func TestExample(t *testing.T) {
    framework := gowright.NewWithDefaults()
    defer framework.Close()
    
    err := framework.Initialize()
    if err != nil {
        t.Fatalf("Failed to initialize framework: %v", err)
    }
    
    // Continue with test
}
```

### 3. Use Environment-Specific Configuration

```go
func getConfig() *gowright.Config {
    env := os.Getenv("TEST_ENV")
    if env == "" {
        env = "development"
    }
    
    configFile := fmt.Sprintf("config-%s.json", env)
    config, err := gowright.LoadConfigFromFile(configFile)
    if err != nil {
        // Fallback to default configuration
        return gowright.DefaultConfig()
    }
    
    return config
}
```

### 4. Monitor Resource Usage

```go
func TestWithResourceMonitoring(t *testing.T) {
    framework := gowright.NewWithDefaults()
    defer framework.Close()
    
    err := framework.Initialize()
    assert.NoError(t, err)
    
    // Monitor resources during test
    resourceManager := framework.GetResourceManager()
    initialUsage := resourceManager.GetCurrentUsage()
    
    // Run your test operations
    
    finalUsage := resourceManager.GetCurrentUsage()
    
    // Verify no resource leaks
    assert.LessOrEqual(t, finalUsage.MemoryMB-initialUsage.MemoryMB, 100,
        "Memory usage should not increase significantly")
}
```

### 5. Use Structured Logging

```go
func TestWithStructuredLogging(t *testing.T) {
    logger := logrus.New()
    logger.SetFormatter(&logrus.JSONFormatter{})
    
    config := &gowright.Config{
        LogLevel: "info",
        Logger:   logger,
    }
    
    framework := gowright.New(config)
    defer framework.Close()
    
    err := framework.Initialize()
    assert.NoError(t, err)
    
    // All framework operations will be logged with structured data
    logger.WithFields(logrus.Fields{
        "test_name": "TestWithStructuredLogging",
        "framework": "gowright",
    }).Info("Test started")
}
```

## Next Steps

After mastering these basic usage patterns, you can explore:

- [API Testing Examples](api-testing.md) - REST API testing with validation
- [UI Testing Examples](ui-testing.md) - Browser automation examples
- [Mobile Testing Examples](mobile-testing.md) - Mobile app automation
- [Database Testing Examples](database-testing.md) - Database operations
- [Integration Testing Examples](integration-testing.md) - End-to-end workflows
- [OpenAPI Testing Examples](openapi-testing.md) - OpenAPI specification testing

For more advanced topics, see:

- [Architecture Overview](../advanced/architecture.md) - Framework architecture
- [Test Suites](../advanced/test-suites.md) - Advanced test organization
- [Parallel Execution](../advanced/parallel-execution.md) - Concurrent testing
- [Resource Management](../advanced/resource-management.md) - Performance optimization

---

These examples provide a solid foundation for using the Gowright testing framework. The framework's modular design allows you to start simple and gradually add more sophisticated testing capabilities as your needs grow.