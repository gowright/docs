# Modular Usage Examples

This document demonstrates how to use the GoWright framework in a modular way, allowing you to use individual testing components independently or combine them as needed. The modular architecture provides flexibility for different project requirements and testing scenarios.

## Table of Contents

1. [Framework Architecture Overview](#framework-architecture-overview)
2. [Individual Tester Usage](#individual-tester-usage)
3. [Selective Module Integration](#selective-module-integration)
4. [Custom Framework Configuration](#custom-framework-configuration)
5. [Microservices Testing Patterns](#microservices-testing-patterns)
6. [Plugin-Based Extensions](#plugin-based-extensions)

## Framework Architecture Overview

The GoWright framework is built with a modular architecture that allows you to use components independently:

```mermaid
graph TB
    subgraph "GoWright Framework"
        A[Framework Controller] --> B[Configuration Manager]
        A --> C[Resource Manager]
        A --> D[Test Suite Manager]
        
        subgraph "Testing Modules"
            E[UI Tester] --> E1[Rod Browser]
            F[API Tester] --> F1[Resty HTTP Client]
            G[Mobile Tester] --> G1[Appium Client]
            H[Database Tester] --> H1[SQL Drivers]
            I[Integration Tester] --> I1[Workflow Engine]
            J[OpenAPI Tester] --> J1[Specification Parser]
        end
        
        subgraph "Core Services"
            K[Assertion Engine]
            L[Reporting Engine]
            M[Parallel Runner]
            N[Resource Monitor]
        end
        
        A --> E
        A --> F
        A --> G
        A --> H
        A --> I
        A --> J
        
        E --> K
        F --> K
        G --> K
        H --> K
        I --> K
        J --> K
        
        K --> L
        M --> N
    end
    
    style A fill:#e1f5fe
    style E fill:#c8e6c9
    style F fill:#ffecb3
    style G fill:#f8bbd9
    style H fill:#d1c4e9
    style I fill:#ffcdd2
    style J fill:#fff3e0
```

## Individual Tester Usage

### Using API Tester Independently

```go
package main

import (
    "fmt"
    "log"
    "net/http"
    "time"
    
    "github.com/gowright/framework/pkg/api"
)

func main() {
    fmt.Println("=== Individual API Tester Usage ===")
    
    // Create API tester configuration
    config := &api.Config{
        BaseURL: "https://jsonplaceholder.typicode.com",
        Timeout: 10 * time.Second,
        Headers: map[string]string{
            "User-Agent": "GoWright-API-Tester/1.0",
        },
    }
    
    // Create and initialize API tester
    apiTester := api.NewTester()
    err := apiTester.Initialize(config)
    if err != nil {
        log.Fatalf("Failed to initialize API tester: %v", err)
    }
    defer apiTester.Cleanup()
    
    fmt.Printf("API Tester initialized: %s\n", apiTester.GetName())
    
    // Perform API operations
    testBasicAPIOperations(apiTester)
    testAPIWithValidation(apiTester)
}

func testBasicAPIOperations(tester api.Tester) {
    fmt.Println("\n--- Basic API Operations ---")
    
    // GET request
    response, err := tester.Get("/posts/1", nil)
    if err != nil {
        log.Printf("GET request failed: %v", err)
        return
    }
    
    fmt.Printf("GET /posts/1: Status %d\n", response.StatusCode)
    
    // POST request
    postData := map[string]interface{}{
        "title":  "Test Post",
        "body":   "This is a test post",
        "userId": 1,
    }
    
    response, err = tester.Post("/posts", postData, nil)
    if err != nil {
        log.Printf("POST request failed: %v", err)
        return
    }
    
    fmt.Printf("POST /posts: Status %d\n", response.StatusCode)
}

func testAPIWithValidation(tester api.Tester) {
    fmt.Println("\n--- API Testing with Validation ---")
    
    // Create API test with validation
    test := &api.Test{
        Name:     "Get User Posts",
        Method:   "GET",
        Endpoint: "/users/1/posts",
        ExpectedStatus: http.StatusOK,
        Validations: []api.Validation{
            {
                Type:     "json_path",
                Path:     "$[0].userId",
                Expected: 1,
            },
            {
                Type:     "response_time",
                Expected: "< 2s",
            },
        },
    }
    
    result := tester.ExecuteTest(test)
    fmt.Printf("Test '%s': %s\n", test.Name, result.Status)
    
    if result.Status != api.TestStatusPassed {
        fmt.Printf("Test failed: %s\n", result.Message)
        for _, err := range result.Errors {
            fmt.Printf("  Error: %s\n", err.Message)
        }
    }
}
```

### Using UI Tester Independently

```go
package main

import (
    "fmt"
    "log"
    "time"
    
    "github.com/gowright/framework/pkg/ui"
)

func main() {
    fmt.Println("=== Individual UI Tester Usage ===")
    
    // Create UI tester configuration
    config := &ui.Config{
        Headless: true,
        Timeout:  30 * time.Second,
        WindowSize: &ui.WindowSize{
            Width:  1920,
            Height: 1080,
        },
    }
    
    // Create and initialize UI tester
    uiTester := ui.NewRodTester()
    err := uiTester.Initialize(config)
    if err != nil {
        log.Fatalf("Failed to initialize UI tester: %v", err)
    }
    defer uiTester.Cleanup()
    
    fmt.Printf("UI Tester initialized: %s\n", uiTester.GetName())
    
    // Perform UI operations
    testBasicUIOperations(uiTester)
    testUIWithAssertions(uiTester)
}

func testBasicUIOperations(tester ui.Tester) {
    fmt.Println("\n--- Basic UI Operations ---")
    
    // Navigate to page
    err := tester.Navigate("https://example.com")
    if err != nil {
        log.Printf("Navigation failed: %v", err)
        return
    }
    
    fmt.Println("Navigated to example.com")
    
    // Get page title
    title, err := tester.GetTitle()
    if err != nil {
        log.Printf("Failed to get title: %v", err)
        return
    }
    
    fmt.Printf("Page title: %s\n", title)
    
    // Take screenshot
    screenshotPath, err := tester.TakeScreenshot("example-page.png")
    if err != nil {
        log.Printf("Failed to take screenshot: %v", err)
        return
    }
    
    fmt.Printf("Screenshot saved: %s\n", screenshotPath)
}

func testUIWithAssertions(tester ui.Tester) {
    fmt.Println("\n--- UI Testing with Assertions ---")
    
    // Create UI test
    test := &ui.Test{
        Name: "Example.com Page Test",
        Steps: []ui.Step{
            {
                Action: ui.ActionNavigate,
                Target: "https://example.com",
            },
            {
                Action: ui.ActionWaitForElement,
                Target: "h1",
                Timeout: 10 * time.Second,
            },
            {
                Action: ui.ActionAssertText,
                Target: "h1",
                Expected: "Example Domain",
            },
        },
    }
    
    result := tester.ExecuteTest(test)
    fmt.Printf("Test '%s': %s\n", test.Name, result.Status)
    
    if result.Status != ui.TestStatusPassed {
        fmt.Printf("Test failed: %s\n", result.Message)
    }
}
```

### Using Database Tester Independently

```go
package main

import (
    "fmt"
    "log"
    
    "github.com/gowright/framework/pkg/database"
)

func main() {
    fmt.Println("=== Individual Database Tester Usage ===")
    
    // Create database tester configuration
    config := &database.Config{
        Connections: map[string]*database.Connection{
            "test": {
                Driver: "sqlite3",
                DSN:    ":memory:",
                MaxOpenConns: 5,
                MaxIdleConns: 2,
            },
        },
    }
    
    // Create and initialize database tester
    dbTester := database.NewTester()
    err := dbTester.Initialize(config)
    if err != nil {
        log.Fatalf("Failed to initialize database tester: %v", err)
    }
    defer dbTester.Cleanup()
    
    fmt.Printf("Database Tester initialized: %s\n", dbTester.GetName())
    
    // Perform database operations
    testBasicDatabaseOperations(dbTester)
    testDatabaseWithTransactions(dbTester)
}

func testBasicDatabaseOperations(tester database.Tester) {
    fmt.Println("\n--- Basic Database Operations ---")
    
    // Create table
    _, err := tester.Execute("test", `
        CREATE TABLE users (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL
        )
    `)
    if err != nil {
        log.Printf("Failed to create table: %v", err)
        return
    }
    
    fmt.Println("Table created successfully")
    
    // Insert data
    _, err = tester.Execute("test", 
        "INSERT INTO users (name, email) VALUES (?, ?)", 
        "John Doe", "john@example.com")
    if err != nil {
        log.Printf("Failed to insert data: %v", err)
        return
    }
    
    fmt.Println("Data inserted successfully")
    
    // Query data
    rows, err := tester.Query("test", "SELECT id, name, email FROM users")
    if err != nil {
        log.Printf("Failed to query data: %v", err)
        return
    }
    defer rows.Close()
    
    fmt.Println("Query results:")
    for rows.Next() {
        var id int
        var name, email string
        err := rows.Scan(&id, &name, &email)
        if err != nil {
            log.Printf("Failed to scan row: %v", err)
            continue
        }
        fmt.Printf("  ID: %d, Name: %s, Email: %s\n", id, name, email)
    }
}

func testDatabaseWithTransactions(tester database.Tester) {
    fmt.Println("\n--- Database Testing with Transactions ---")
    
    // Create database test
    test := &database.Test{
        Name:       "User Creation Test",
        Connection: "test",
        Setup: []string{
            "INSERT INTO users (name, email) VALUES ('Jane Doe', 'jane@example.com')",
        },
        Query: "SELECT COUNT(*) as count FROM users WHERE name = 'Jane Doe'",
        Expected: &database.Expectation{
            RowCount: 1,
            Values: map[string]interface{}{
                "count": 1,
            },
        },
        Teardown: []string{
            "DELETE FROM users WHERE email = 'jane@example.com'",
        },
    }
    
    result := tester.ExecuteTest(test)
    fmt.Printf("Test '%s': %s\n", test.Name, result.Status)
    
    if result.Status != database.TestStatusPassed {
        fmt.Printf("Test failed: %s\n", result.Message)
    }
}
```## Select
ive Module Integration

### Custom Framework with Selected Modules

```go
package main

import (
    "fmt"
    "log"
    
    "github.com/gowright/framework/pkg/gowright"
    "github.com/gowright/framework/pkg/api"
    "github.com/gowright/framework/pkg/database"
)

func main() {
    fmt.Println("=== Selective Module Integration ===")
    
    // Create custom framework with only API and Database testing
    customFrameworkExample()
    
    // Create framework with specific configuration
    configuredFrameworkExample()
}

func customFrameworkExample() {
    fmt.Println("\n--- Custom Framework (API + Database Only) ---")
    
    // Create base configuration
    config := gowright.DefaultConfig()
    config.APIConfig.BaseURL = "https://api.example.com"
    config.DatabaseConfig.Connections = map[string]*gowright.DBConnection{
        "main": {
            Driver: "sqlite3",
            DSN:    ":memory:",
        },
    }
    
    // Create framework with selected modules
    framework := gowright.NewFramework()
    
    // Add only the modules we need
    apiTester := api.NewTester()
    dbTester := database.NewTester()
    
    framework.AddTester("api", apiTester)
    framework.AddTester("database", dbTester)
    
    // Initialize framework
    err := framework.Initialize(config)
    if err != nil {
        log.Fatalf("Failed to initialize framework: %v", err)
    }
    defer framework.Close()
    
    fmt.Printf("Custom framework initialized with %d testers\n", framework.GetTesterCount())
    
    // Use the testers
    apiTester = framework.GetTester("api").(api.Tester)
    dbTester = framework.GetTester("database").(database.Tester)
    
    fmt.Printf("API Tester: %s\n", apiTester.GetName())
    fmt.Printf("Database Tester: %s\n", dbTester.GetName())
}

func configuredFrameworkExample() {
    fmt.Println("\n--- Configured Framework Example ---")
    
    // Create framework builder for custom configuration
    builder := gowright.NewFrameworkBuilder()
    
    framework, err := builder.
        WithAPITesting(true).
        WithDatabaseTesting(true).
        WithUITesting(false).        // Explicitly disable UI testing
        WithMobileTesting(false).    // Explicitly disable mobile testing
        WithIntegrationTesting(false). // Explicitly disable integration testing
        WithAPIConfig(&gowright.APIConfig{
            BaseURL: "https://api.myservice.com",
            Timeout: 30 * time.Second,
        }).
        WithDatabaseConfig(&gowright.DatabaseConfig{
            Connections: map[string]*gowright.DBConnection{
                "primary": {
                    Driver: "postgres",
                    DSN:    "postgres://user:pass@localhost/testdb?sslmode=disable",
                },
                "secondary": {
                    Driver: "sqlite3",
                    DSN:    ":memory:",
                },
            },
        }).
        Build()
    
    if err != nil {
        log.Fatalf("Failed to build framework: %v", err)
    }
    defer framework.Close()
    
    fmt.Printf("Configured framework built successfully\n")
    fmt.Printf("Available testers: %v\n", framework.GetAvailableTesters())
}
```

### Module-Specific Test Suites

```go
func moduleSpecificTestSuites() {
    fmt.Println("=== Module-Specific Test Suites ===")
    
    // API-only test suite
    apiOnlyTestSuite()
    
    // Database-only test suite
    databaseOnlyTestSuite()
    
    // Combined API + Database test suite
    combinedTestSuite()
}

func apiOnlyTestSuite() {
    fmt.Println("\n--- API-Only Test Suite ---")
    
    // Create API tester
    apiTester := api.NewTester()
    config := &api.Config{
        BaseURL: "https://jsonplaceholder.typicode.com",
        Timeout: 10 * time.Second,
    }
    
    err := apiTester.Initialize(config)
    if err != nil {
        log.Fatalf("Failed to initialize API tester: %v", err)
    }
    defer apiTester.Cleanup()
    
    // Create API test suite
    suite := &api.TestSuite{
        Name: "API Integration Tests",
        Tests: []*api.Test{
            {
                Name:           "Get All Posts",
                Method:         "GET",
                Endpoint:       "/posts",
                ExpectedStatus: 200,
                Validations: []api.Validation{
                    {Type: "json_array", Expected: true},
                    {Type: "response_time", Expected: "< 2s"},
                },
            },
            {
                Name:           "Get Single Post",
                Method:         "GET",
                Endpoint:       "/posts/1",
                ExpectedStatus: 200,
                Validations: []api.Validation{
                    {Type: "json_path", Path: "$.id", Expected: 1},
                    {Type: "json_path", Path: "$.userId", Expected: 1},
                },
            },
            {
                Name:           "Create New Post",
                Method:         "POST",
                Endpoint:       "/posts",
                RequestBody: map[string]interface{}{
                    "title":  "Test Post",
                    "body":   "Test Body",
                    "userId": 1,
                },
                ExpectedStatus: 201,
                Validations: []api.Validation{
                    {Type: "json_path", Path: "$.id", Expected: "exists"},
                },
            },
        },
    }
    
    // Execute test suite
    results := apiTester.ExecuteTestSuite(suite)
    fmt.Printf("API Test Suite Results: %d passed, %d failed\n", 
        results.PassedTests, results.FailedTests)
}

func databaseOnlyTestSuite() {
    fmt.Println("\n--- Database-Only Test Suite ---")
    
    // Create database tester
    dbTester := database.NewTester()
    config := &database.Config{
        Connections: map[string]*database.Connection{
            "test": {
                Driver: "sqlite3",
                DSN:    ":memory:",
            },
        },
    }
    
    err := dbTester.Initialize(config)
    if err != nil {
        log.Fatalf("Failed to initialize database tester: %v", err)
    }
    defer dbTester.Cleanup()
    
    // Setup test database
    _, err = dbTester.Execute("test", `
        CREATE TABLE products (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            price DECIMAL(10,2),
            category_id INTEGER
        )
    `)
    if err != nil {
        log.Fatalf("Failed to create table: %v", err)
    }
    
    // Create database test suite
    suite := &database.TestSuite{
        Name: "Product Database Tests",
        Tests: []*database.Test{
            {
                Name:       "Insert Product",
                Connection: "test",
                Setup: []string{
                    "INSERT INTO products (name, price, category_id) VALUES ('Test Product', 19.99, 1)",
                },
                Query: "SELECT COUNT(*) as count FROM products WHERE name = 'Test Product'",
                Expected: &database.Expectation{
                    RowCount: 1,
                    Values: map[string]interface{}{
                        "count": 1,
                    },
                },
                Teardown: []string{
                    "DELETE FROM products WHERE name = 'Test Product'",
                },
            },
            {
                Name:       "Product Price Validation",
                Connection: "test",
                Setup: []string{
                    "INSERT INTO products (name, price, category_id) VALUES ('Expensive Product', 999.99, 2)",
                },
                Query: "SELECT price FROM products WHERE name = 'Expensive Product'",
                Expected: &database.Expectation{
                    RowCount: 1,
                    Values: map[string]interface{}{
                        "price": 999.99,
                    },
                },
                Teardown: []string{
                    "DELETE FROM products WHERE name = 'Expensive Product'",
                },
            },
        },
    }
    
    // Execute test suite
    results := dbTester.ExecuteTestSuite(suite)
    fmt.Printf("Database Test Suite Results: %d passed, %d failed\n", 
        results.PassedTests, results.FailedTests)
}

func combinedTestSuite() {
    fmt.Println("\n--- Combined API + Database Test Suite ---")
    
    // Create framework with API and Database testers
    config := gowright.DefaultConfig()
    config.APIConfig.BaseURL = "https://jsonplaceholder.typicode.com"
    config.DatabaseConfig.Connections = map[string]*gowright.DBConnection{
        "test": {
            Driver: "sqlite3",
            DSN:    ":memory:",
        },
    }
    
    framework := gowright.NewFramework()
    framework.AddTester("api", api.NewTester())
    framework.AddTester("database", database.NewTester())
    
    err := framework.Initialize(config)
    if err != nil {
        log.Fatalf("Failed to initialize framework: %v", err)
    }
    defer framework.Close()
    
    // Setup database
    dbTester := framework.GetTester("database").(database.Tester)
    _, err = dbTester.Execute("test", `
        CREATE TABLE api_logs (
            id INTEGER PRIMARY KEY,
            endpoint TEXT NOT NULL,
            status_code INTEGER,
            response_time INTEGER,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    `)
    if err != nil {
        log.Fatalf("Failed to create api_logs table: %v", err)
    }
    
    // Create combined test suite
    suite := &gowright.TestSuite{
        Name: "API + Database Integration Tests",
        Tests: []gowright.Test{
            &gowright.CombinedTest{
                Name: "API Call with Database Logging",
                Steps: []gowright.TestStep{
                    {
                        Type: "api",
                        Action: map[string]interface{}{
                            "method":   "GET",
                            "endpoint": "/posts/1",
                        },
                        Validation: map[string]interface{}{
                            "status_code": 200,
                        },
                    },
                    {
                        Type: "database",
                        Action: map[string]interface{}{
                            "connection": "test",
                            "query": "INSERT INTO api_logs (endpoint, status_code, response_time) VALUES (?, ?, ?)",
                            "args": []interface{}{"/posts/1", 200, 150},
                        },
                    },
                    {
                        Type: "database",
                        Action: map[string]interface{}{
                            "connection": "test",
                            "query": "SELECT COUNT(*) as count FROM api_logs WHERE endpoint = '/posts/1'",
                        },
                        Validation: map[string]interface{}{
                            "row_count": 1,
                            "values": map[string]interface{}{
                                "count": 1,
                            },
                        },
                    },
                },
            },
        },
    }
    
    // Execute combined test suite
    results, err := framework.ExecuteTestSuite(suite)
    if err != nil {
        log.Printf("Failed to execute test suite: %v", err)
        return
    }
    
    fmt.Printf("Combined Test Suite Results: %d passed, %d failed\n", 
        results.PassedTests, results.FailedTests)
}
```

## Custom Framework Configuration

### Environment-Based Configuration

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
    fmt.Println("=== Environment-Based Configuration ===")
    
    // Load configuration based on environment
    config := loadEnvironmentConfig()
    
    // Create framework with environment-specific configuration
    framework := createEnvironmentFramework(config)
    defer framework.Close()
    
    fmt.Printf("Framework configured for environment: %s\n", getEnvironment())
}

func getEnvironment() string {
    env := os.Getenv("GOWRIGHT_ENV")
    if env == "" {
        return "development"
    }
    return env
}

func loadEnvironmentConfig() *gowright.Config {
    env := getEnvironment()
    
    config := gowright.DefaultConfig()
    
    switch env {
    case "development":
        config = loadDevelopmentConfig()
    case "testing":
        config = loadTestingConfig()
    case "staging":
        config = loadStagingConfig()
    case "production":
        config = loadProductionConfig()
    default:
        log.Printf("Unknown environment: %s, using default config", env)
    }
    
    // Override with environment variables
    overrideWithEnvVars(config)
    
    return config
}

func loadDevelopmentConfig() *gowright.Config {
    return &gowright.Config{
        LogLevel: "debug",
        Parallel: false,
        BrowserConfig: &gowright.BrowserConfig{
            Headless: false,  // Show browser in development
            Timeout:  30 * time.Second,
        },
        APIConfig: &gowright.APIConfig{
            BaseURL: "http://localhost:8080",
            Timeout: 10 * time.Second,
        },
        DatabaseConfig: &gowright.DatabaseConfig{
            Connections: map[string]*gowright.DBConnection{
                "dev": {
                    Driver: "sqlite3",
                    DSN:    "./dev-test.db",
                },
            },
        },
    }
}

func loadTestingConfig() *gowright.Config {
    return &gowright.Config{
        LogLevel: "info",
        Parallel: true,
        BrowserConfig: &gowright.BrowserConfig{
            Headless: true,
            Timeout:  20 * time.Second,
        },
        APIConfig: &gowright.APIConfig{
            BaseURL: "http://test-api:8080",
            Timeout: 15 * time.Second,
        },
        DatabaseConfig: &gowright.DatabaseConfig{
            Connections: map[string]*gowright.DBConnection{
                "test": {
                    Driver: "postgres",
                    DSN:    "postgres://test:test@test-db:5432/testdb?sslmode=disable",
                },
            },
        },
    }
}

func loadStagingConfig() *gowright.Config {
    return &gowright.Config{
        LogLevel: "warn",
        Parallel: true,
        BrowserConfig: &gowright.BrowserConfig{
            Headless: true,
            Timeout:  45 * time.Second,
        },
        APIConfig: &gowright.APIConfig{
            BaseURL: "https://staging-api.example.com",
            Timeout: 30 * time.Second,
        },
        DatabaseConfig: &gowright.DatabaseConfig{
            Connections: map[string]*gowright.DBConnection{
                "staging": {
                    Driver: "postgres",
                    DSN:    "postgres://staging:password@staging-db:5432/stagingdb?sslmode=require",
                },
            },
        },
    }
}

func loadProductionConfig() *gowright.Config {
    return &gowright.Config{
        LogLevel: "error",
        Parallel: true,
        BrowserConfig: &gowright.BrowserConfig{
            Headless: true,
            Timeout:  60 * time.Second,
        },
        APIConfig: &gowright.APIConfig{
            BaseURL: "https://api.example.com",
            Timeout: 45 * time.Second,
        },
        // Note: Production typically doesn't include database testing
        // against production databases
    }
}

func overrideWithEnvVars(config *gowright.Config) {
    // Override log level
    if logLevel := os.Getenv("GOWRIGHT_LOG_LEVEL"); logLevel != "" {
        config.LogLevel = logLevel
    }
    
    // Override parallel execution
    if parallel := os.Getenv("GOWRIGHT_PARALLEL"); parallel != "" {
        if p, err := strconv.ParseBool(parallel); err == nil {
            config.Parallel = p
        }
    }
    
    // Override API base URL
    if baseURL := os.Getenv("GOWRIGHT_API_BASE_URL"); baseURL != "" {
        if config.APIConfig == nil {
            config.APIConfig = &gowright.APIConfig{}
        }
        config.APIConfig.BaseURL = baseURL
    }
    
    // Override browser headless mode
    if headless := os.Getenv("GOWRIGHT_BROWSER_HEADLESS"); headless != "" {
        if h, err := strconv.ParseBool(headless); err == nil {
            if config.BrowserConfig == nil {
                config.BrowserConfig = &gowright.BrowserConfig{}
            }
            config.BrowserConfig.Headless = h
        }
    }
}

func createEnvironmentFramework(config *gowright.Config) *gowright.Framework {
    env := getEnvironment()
    
    // Create framework builder
    builder := gowright.NewFrameworkBuilder()
    
    // Configure based on environment
    switch env {
    case "development":
        return builder.
            WithAllTesters(). // Enable all testers in development
            WithConfig(config).
            Build()
            
    case "testing":
        return builder.
            WithAPITesting(true).
            WithDatabaseTesting(true).
            WithUITesting(true).
            WithMobileTesting(false). // Skip mobile in CI
            WithConfig(config).
            Build()
            
    case "staging":
        return builder.
            WithAPITesting(true).
            WithUITesting(true).
            WithDatabaseTesting(false). // No DB access in staging
            WithMobileTesting(false).
            WithConfig(config).
            Build()
            
    case "production":
        return builder.
            WithAPITesting(true).
            WithUITesting(false). // No UI testing in production
            WithDatabaseTesting(false).
            WithMobileTesting(false).
            WithConfig(config).
            Build()
            
    default:
        return builder.
            WithConfig(config).
            Build()
    }
}
```## Micr
oservices Testing Patterns

### Service-Specific Testing

```go
package main

import (
    "fmt"
    "log"
    "sync"
    
    "github.com/gowright/framework/pkg/gowright"
)

func main() {
    fmt.Println("=== Microservices Testing Patterns ===")
    
    // Test individual microservices
    testIndividualServices()
    
    // Test service interactions
    testServiceInteractions()
    
    // Test service orchestration
    testServiceOrchestration()
}

func testIndividualServices() {
    fmt.Println("\n--- Individual Service Testing ---")
    
    services := []ServiceConfig{
        {
            Name:    "user-service",
            BaseURL: "http://user-service:8080",
            Database: "user_db",
        },
        {
            Name:    "order-service",
            BaseURL: "http://order-service:8080",
            Database: "order_db",
        },
        {
            Name:    "payment-service",
            BaseURL: "http://payment-service:8080",
            Database: "payment_db",
        },
    }
    
    var wg sync.WaitGroup
    results := make(chan ServiceTestResult, len(services))
    
    // Test services in parallel
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
    
    // Collect results
    fmt.Println("Service Test Results:")
    for result := range results {
        fmt.Printf("  %s: %s (%d tests)\n", 
            result.ServiceName, result.Status, result.TestCount)
    }
}

type ServiceConfig struct {
    Name     string
    BaseURL  string
    Database string
}

type ServiceTestResult struct {
    ServiceName string
    Status      string
    TestCount   int
    Errors      []string
}

func testService(service ServiceConfig) ServiceTestResult {
    // Create service-specific framework
    config := &gowright.Config{
        APIConfig: &gowright.APIConfig{
            BaseURL: service.BaseURL,
            Timeout: 15 * time.Second,
        },
        DatabaseConfig: &gowright.DatabaseConfig{
            Connections: map[string]*gowright.DBConnection{
                service.Database: {
                    Driver: "postgres",
                    DSN:    fmt.Sprintf("postgres://test:test@%s-db:5432/%s?sslmode=disable", 
                        service.Name, service.Database),
                },
            },
        },
    }
    
    framework := gowright.NewFramework()
    framework.AddTester("api", api.NewTester())
    framework.AddTester("database", database.NewTester())
    
    err := framework.Initialize(config)
    if err != nil {
        return ServiceTestResult{
            ServiceName: service.Name,
            Status:      "failed",
            Errors:      []string{err.Error()},
        }
    }
    defer framework.Close()
    
    // Create service-specific test suite
    testSuite := createServiceTestSuite(service)
    
    // Execute tests
    results, err := framework.ExecuteTestSuite(testSuite)
    if err != nil {
        return ServiceTestResult{
            ServiceName: service.Name,
            Status:      "error",
            Errors:      []string{err.Error()},
        }
    }
    
    status := "passed"
    if results.FailedTests > 0 {
        status = "failed"
    }
    
    return ServiceTestResult{
        ServiceName: service.Name,
        Status:      status,
        TestCount:   results.TotalTests,
    }
}

func createServiceTestSuite(service ServiceConfig) *gowright.TestSuite {
    switch service.Name {
    case "user-service":
        return createUserServiceTestSuite()
    case "order-service":
        return createOrderServiceTestSuite()
    case "payment-service":
        return createPaymentServiceTestSuite()
    default:
        return createGenericServiceTestSuite(service.Name)
    }
}

func createUserServiceTestSuite() *gowright.TestSuite {
    return &gowright.TestSuite{
        Name: "User Service Tests",
        Tests: []gowright.Test{
            &gowright.APITest{
                Name:           "Get User Profile",
                Method:         "GET",
                Endpoint:       "/users/1",
                ExpectedStatus: 200,
            },
            &gowright.APITest{
                Name:           "Create User",
                Method:         "POST",
                Endpoint:       "/users",
                RequestBody: map[string]interface{}{
                    "name":  "Test User",
                    "email": "test@example.com",
                },
                ExpectedStatus: 201,
            },
            &gowright.DatabaseTest{
                Name:       "User Database Integrity",
                Connection: "user_db",
                Query:      "SELECT COUNT(*) as count FROM users",
                Expected: &gowright.DatabaseExpectation{
                    RowCount: 1,
                },
            },
        },
    }
}

func createOrderServiceTestSuite() *gowright.TestSuite {
    return &gowright.TestSuite{
        Name: "Order Service Tests",
        Tests: []gowright.Test{
            &gowright.APITest{
                Name:           "Get Orders",
                Method:         "GET",
                Endpoint:       "/orders",
                ExpectedStatus: 200,
            },
            &gowright.APITest{
                Name:           "Create Order",
                Method:         "POST",
                Endpoint:       "/orders",
                RequestBody: map[string]interface{}{
                    "userId":    1,
                    "productId": 1,
                    "quantity":  2,
                },
                ExpectedStatus: 201,
            },
        },
    }
}

func createPaymentServiceTestSuite() *gowright.TestSuite {
    return &gowright.TestSuite{
        Name: "Payment Service Tests",
        Tests: []gowright.Test{
            &gowright.APITest{
                Name:           "Process Payment",
                Method:         "POST",
                Endpoint:       "/payments",
                RequestBody: map[string]interface{}{
                    "orderId": 1,
                    "amount":  99.99,
                    "method":  "credit_card",
                },
                ExpectedStatus: 200,
            },
        },
    }
}

func createGenericServiceTestSuite(serviceName string) *gowright.TestSuite {
    return &gowright.TestSuite{
        Name: fmt.Sprintf("%s Tests", serviceName),
        Tests: []gowright.Test{
            &gowright.APITest{
                Name:           "Health Check",
                Method:         "GET",
                Endpoint:       "/health",
                ExpectedStatus: 200,
            },
        },
    }
}

func testServiceInteractions() {
    fmt.Println("\n--- Service Interaction Testing ---")
    
    // Create integration framework
    config := gowright.DefaultConfig()
    config.APIConfig.BaseURL = "http://api-gateway:8080"
    
    framework := gowright.NewWithDefaults()
    defer framework.Close()
    
    err := framework.Initialize(config)
    if err != nil {
        log.Printf("Failed to initialize framework: %v", err)
        return
    }
    
    // Test service interactions
    interactionSuite := &gowright.TestSuite{
        Name: "Service Interaction Tests",
        Tests: []gowright.Test{
            &gowright.IntegrationTest{
                Name: "User Order Flow",
                Steps: []gowright.IntegrationStep{
                    {
                        Type: gowright.StepTypeAPI,
                        Action: gowright.APIStepAction{
                            Method:   "POST",
                            Endpoint: "/users",
                            Body: map[string]interface{}{
                                "name":  "Integration User",
                                "email": "integration@example.com",
                            },
                        },
                        Validation: gowright.APIStepValidation{
                            ExpectedStatusCode: 201,
                        },
                        Name: "Create User",
                    },
                    {
                        Type: gowright.StepTypeAPI,
                        Action: gowright.APIStepAction{
                            Method:   "POST",
                            Endpoint: "/orders",
                            Body: map[string]interface{}{
                                "userId":    "{{previous.response.id}}",
                                "productId": 1,
                                "quantity":  1,
                            },
                        },
                        Validation: gowright.APIStepValidation{
                            ExpectedStatusCode: 201,
                        },
                        Name: "Create Order",
                    },
                    {
                        Type: gowright.StepTypeAPI,
                        Action: gowright.APIStepAction{
                            Method:   "POST",
                            Endpoint: "/payments",
                            Body: map[string]interface{}{
                                "orderId": "{{previous.response.id}}",
                                "amount":  29.99,
                                "method":  "credit_card",
                            },
                        },
                        Validation: gowright.APIStepValidation{
                            ExpectedStatusCode: 200,
                        },
                        Name: "Process Payment",
                    },
                },
            },
        },
    }
    
    results, err := framework.ExecuteTestSuite(interactionSuite)
    if err != nil {
        log.Printf("Failed to execute interaction tests: %v", err)
        return
    }
    
    fmt.Printf("Service Interaction Tests: %d passed, %d failed\n", 
        results.PassedTests, results.FailedTests)
}

func testServiceOrchestration() {
    fmt.Println("\n--- Service Orchestration Testing ---")
    
    // Test complex orchestration scenarios
    orchestrationTests := []OrchestrationTest{
        {
            Name: "E-commerce Purchase Flow",
            Services: []string{"user-service", "inventory-service", "order-service", "payment-service", "notification-service"},
            Scenario: "complete_purchase",
        },
        {
            Name: "User Registration Flow",
            Services: []string{"user-service", "email-service", "notification-service"},
            Scenario: "user_registration",
        },
    }
    
    for _, test := range orchestrationTests {
        fmt.Printf("Running orchestration test: %s\n", test.Name)
        result := runOrchestrationTest(test)
        fmt.Printf("  Result: %s\n", result.Status)
    }
}

type OrchestrationTest struct {
    Name     string
    Services []string
    Scenario string
}

type OrchestrationResult struct {
    Status   string
    Duration time.Duration
    Errors   []string
}

func runOrchestrationTest(test OrchestrationTest) OrchestrationResult {
    start := time.Now()
    
    // Create orchestration framework
    framework := gowright.NewWithDefaults()
    defer framework.Close()
    
    // Configure for orchestration testing
    config := &gowright.Config{
        Parallel: true,
        ParallelRunnerConfig: &gowright.ParallelRunnerConfig{
            MaxConcurrency: len(test.Services),
        },
        IntegrationConfig: &gowright.IntegrationConfig{
            Services: test.Services,
            Scenario: test.Scenario,
        },
    }
    
    err := framework.Initialize(config)
    if err != nil {
        return OrchestrationResult{
            Status:   "failed",
            Duration: time.Since(start),
            Errors:   []string{err.Error()},
        }
    }
    
    // Create orchestration test suite based on scenario
    testSuite := createOrchestrationTestSuite(test)
    
    results, err := framework.ExecuteTestSuite(testSuite)
    if err != nil {
        return OrchestrationResult{
            Status:   "error",
            Duration: time.Since(start),
            Errors:   []string{err.Error()},
        }
    }
    
    status := "passed"
    if results.FailedTests > 0 {
        status = "failed"
    }
    
    return OrchestrationResult{
        Status:   status,
        Duration: time.Since(start),
    }
}

func createOrchestrationTestSuite(test OrchestrationTest) *gowright.TestSuite {
    switch test.Scenario {
    case "complete_purchase":
        return createPurchaseOrchestrationSuite()
    case "user_registration":
        return createRegistrationOrchestrationSuite()
    default:
        return createGenericOrchestrationSuite(test.Name)
    }
}

func createPurchaseOrchestrationSuite() *gowright.TestSuite {
    return &gowright.TestSuite{
        Name: "E-commerce Purchase Orchestration",
        Tests: []gowright.Test{
            &gowright.IntegrationTest{
                Name: "Complete Purchase Flow",
                Steps: []gowright.IntegrationStep{
                    // User authentication
                    {Type: gowright.StepTypeAPI, Name: "Authenticate User"},
                    // Check inventory
                    {Type: gowright.StepTypeAPI, Name: "Check Product Availability"},
                    // Reserve inventory
                    {Type: gowright.StepTypeAPI, Name: "Reserve Product"},
                    // Create order
                    {Type: gowright.StepTypeAPI, Name: "Create Order"},
                    // Process payment
                    {Type: gowright.StepTypeAPI, Name: "Process Payment"},
                    // Confirm order
                    {Type: gowright.StepTypeAPI, Name: "Confirm Order"},
                    // Send notification
                    {Type: gowright.StepTypeAPI, Name: "Send Order Confirmation"},
                    // Verify database state
                    {Type: gowright.StepTypeDatabase, Name: "Verify Order in Database"},
                },
            },
        },
    }
}

func createRegistrationOrchestrationSuite() *gowright.TestSuite {
    return &gowright.TestSuite{
        Name: "User Registration Orchestration",
        Tests: []gowright.Test{
            &gowright.IntegrationTest{
                Name: "User Registration Flow",
                Steps: []gowright.IntegrationStep{
                    // Create user
                    {Type: gowright.StepTypeAPI, Name: "Create User Account"},
                    // Send welcome email
                    {Type: gowright.StepTypeAPI, Name: "Send Welcome Email"},
                    // Send notification
                    {Type: gowright.StepTypeAPI, Name: "Send Registration Notification"},
                    // Verify user in database
                    {Type: gowright.StepTypeDatabase, Name: "Verify User in Database"},
                },
            },
        },
    }
}

func createGenericOrchestrationSuite(name string) *gowright.TestSuite {
    return &gowright.TestSuite{
        Name: fmt.Sprintf("%s Orchestration", name),
        Tests: []gowright.Test{
            &gowright.APITest{
                Name:           "Health Check All Services",
                Method:         "GET",
                Endpoint:       "/health",
                ExpectedStatus: 200,
            },
        },
    }
}
```

## Plugin-Based Extensions

### Custom Plugin System

```go
package main

import (
    "fmt"
    "log"
    
    "github.com/gowright/framework/pkg/gowright"
)

func main() {
    fmt.Println("=== Plugin-Based Extensions ===")
    
    // Create framework with plugins
    frameworkWithPlugins()
    
    // Create custom plugins
    customPluginExample()
}

func frameworkWithPlugins() {
    fmt.Println("\n--- Framework with Plugins ---")
    
    // Create framework
    framework := gowright.NewFramework()
    
    // Add built-in testers
    framework.AddTester("api", api.NewTester())
    framework.AddTester("database", database.NewTester())
    
    // Add custom plugins
    framework.AddPlugin("metrics", NewMetricsPlugin())
    framework.AddPlugin("notifications", NewNotificationPlugin())
    framework.AddPlugin("reporting", NewCustomReportingPlugin())
    
    // Initialize framework
    config := gowright.DefaultConfig()
    err := framework.Initialize(config)
    if err != nil {
        log.Fatalf("Failed to initialize framework: %v", err)
    }
    defer framework.Close()
    
    fmt.Printf("Framework initialized with %d testers and %d plugins\n", 
        framework.GetTesterCount(), framework.GetPluginCount())
    
    // Use plugins
    metricsPlugin := framework.GetPlugin("metrics").(*MetricsPlugin)
    metricsPlugin.StartCollection()
    
    // Run some tests...
    
    metricsPlugin.StopCollection()
    metrics := metricsPlugin.GetMetrics()
    fmt.Printf("Collected metrics: %+v\n", metrics)
}

// Custom Metrics Plugin
type MetricsPlugin struct {
    collecting bool
    metrics    map[string]interface{}
}

func NewMetricsPlugin() *MetricsPlugin {
    return &MetricsPlugin{
        metrics: make(map[string]interface{}),
    }
}

func (p *MetricsPlugin) GetName() string {
    return "MetricsPlugin"
}

func (p *MetricsPlugin) Initialize(config interface{}) error {
    fmt.Println("Metrics plugin initialized")
    return nil
}

func (p *MetricsPlugin) Cleanup() error {
    fmt.Println("Metrics plugin cleaned up")
    return nil
}

func (p *MetricsPlugin) StartCollection() {
    p.collecting = true
    fmt.Println("Started metrics collection")
}

func (p *MetricsPlugin) StopCollection() {
    p.collecting = false
    fmt.Println("Stopped metrics collection")
}

func (p *MetricsPlugin) GetMetrics() map[string]interface{} {
    return p.metrics
}

// Custom Notification Plugin
type NotificationPlugin struct {
    webhookURL string
    enabled    bool
}

func NewNotificationPlugin() *NotificationPlugin {
    return &NotificationPlugin{
        webhookURL: "https://hooks.slack.com/services/...",
        enabled:    true,
    }
}

func (p *NotificationPlugin) GetName() string {
    return "NotificationPlugin"
}

func (p *NotificationPlugin) Initialize(config interface{}) error {
    fmt.Println("Notification plugin initialized")
    return nil
}

func (p *NotificationPlugin) Cleanup() error {
    fmt.Println("Notification plugin cleaned up")
    return nil
}

func (p *NotificationPlugin) SendNotification(message string) error {
    if !p.enabled {
        return nil
    }
    
    fmt.Printf("Sending notification: %s\n", message)
    // Implementation would send actual notification
    return nil
}

// Custom Reporting Plugin
type CustomReportingPlugin struct {
    outputDir string
    format    string
}

func NewCustomReportingPlugin() *CustomReportingPlugin {
    return &CustomReportingPlugin{
        outputDir: "./custom-reports",
        format:    "json",
    }
}

func (p *CustomReportingPlugin) GetName() string {
    return "CustomReportingPlugin"
}

func (p *CustomReportingPlugin) Initialize(config interface{}) error {
    fmt.Println("Custom reporting plugin initialized")
    return nil
}

func (p *CustomReportingPlugin) Cleanup() error {
    fmt.Println("Custom reporting plugin cleaned up")
    return nil
}

func (p *CustomReportingPlugin) GenerateReport(results interface{}) error {
    fmt.Printf("Generating custom report in %s format to %s\n", p.format, p.outputDir)
    // Implementation would generate actual report
    return nil
}

func customPluginExample() {
    fmt.Println("\n--- Custom Plugin Example ---")
    
    // Create a custom plugin for specific business logic
    businessPlugin := NewBusinessLogicPlugin()
    
    // Create framework and add the plugin
    framework := gowright.NewFramework()
    framework.AddTester("api", api.NewTester())
    framework.AddPlugin("business", businessPlugin)
    
    config := gowright.DefaultConfig()
    err := framework.Initialize(config)
    if err != nil {
        log.Fatalf("Failed to initialize framework: %v", err)
    }
    defer framework.Close()
    
    // Use the business plugin
    plugin := framework.GetPlugin("business").(*BusinessLogicPlugin)
    
    // Execute business-specific validation
    err = plugin.ValidateBusinessRules(map[string]interface{}{
        "user_id": 123,
        "order_total": 99.99,
        "discount_code": "SAVE10",
    })
    
    if err != nil {
        fmt.Printf("Business validation failed: %v\n", err)
    } else {
        fmt.Println("Business validation passed")
    }
}

// Custom Business Logic Plugin
type BusinessLogicPlugin struct {
    rules map[string]BusinessRule
}

type BusinessRule struct {
    Name        string
    Description string
    Validator   func(data map[string]interface{}) error
}

func NewBusinessLogicPlugin() *BusinessLogicPlugin {
    plugin := &BusinessLogicPlugin{
        rules: make(map[string]BusinessRule),
    }
    
    // Add business rules
    plugin.AddRule("minimum_order", BusinessRule{
        Name:        "Minimum Order Value",
        Description: "Order must be at least $10",
        Validator: func(data map[string]interface{}) error {
            if total, ok := data["order_total"].(float64); ok {
                if total < 10.0 {
                    return fmt.Errorf("order total %.2f is below minimum $10.00", total)
                }
            }
            return nil
        },
    })
    
    plugin.AddRule("valid_discount", BusinessRule{
        Name:        "Valid Discount Code",
        Description: "Discount code must be valid",
        Validator: func(data map[string]interface{}) error {
            if code, ok := data["discount_code"].(string); ok {
                validCodes := []string{"SAVE10", "WELCOME20", "LOYAL15"}
                for _, validCode := range validCodes {
                    if code == validCode {
                        return nil
                    }
                }
                return fmt.Errorf("invalid discount code: %s", code)
            }
            return nil
        },
    })
    
    return plugin
}

func (p *BusinessLogicPlugin) GetName() string {
    return "BusinessLogicPlugin"
}

func (p *BusinessLogicPlugin) Initialize(config interface{}) error {
    fmt.Println("Business logic plugin initialized")
    return nil
}

func (p *BusinessLogicPlugin) Cleanup() error {
    fmt.Println("Business logic plugin cleaned up")
    return nil
}

func (p *BusinessLogicPlugin) AddRule(name string, rule BusinessRule) {
    p.rules[name] = rule
}

func (p *BusinessLogicPlugin) ValidateBusinessRules(data map[string]interface{}) error {
    for name, rule := range p.rules {
        if err := rule.Validator(data); err != nil {
            return fmt.Errorf("business rule '%s' failed: %w", name, err)
        }
    }
    return nil
}

func (p *BusinessLogicPlugin) GetRules() map[string]BusinessRule {
    return p.rules
}
```

This comprehensive modular usage documentation demonstrates how to use the GoWright framework in flexible, modular ways, allowing developers to choose exactly the components they need for their specific testing requirements.