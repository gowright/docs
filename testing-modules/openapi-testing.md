# OpenAPI Testing

The Gowright framework provides comprehensive OpenAPI specification testing capabilities, including validation, breaking change detection, and circular reference detection. This module helps ensure API specifications are correct, consistent, and maintain backward compatibility.

## Table of Contents

1. [Overview](#overview)
2. [Installation and Setup](#installation-and-setup)
3. [Basic Usage](#basic-usage)
4. [Specification Validation](#specification-validation)
5. [Breaking Change Detection](#breaking-change-detection)
6. [Circular Reference Detection](#circular-reference-detection)
7. [Integration with Gowright Framework](#integration-with-gowright-framework)
8. [Test Builder Pattern](#test-builder-pattern)
9. [Configuration and Best Practices](#configuration-and-best-practices)
10. [Troubleshooting](#troubleshooting)

## Overview

The OpenAPI testing module provides:

- **Specification Validation**: Validate OpenAPI 3.0.3 specifications against the standard
- **Breaking Change Detection**: Compare specifications across git commits to detect breaking changes
- **Circular Reference Detection**: Identify circular references in schema definitions
- **Framework Integration**: Seamless integration with the Gowright testing framework
- **Comprehensive Reporting**: Detailed reports with warnings, errors, and recommendations

### Supported Features

- OpenAPI 3.0.3 specification validation using pb33f/libopenapi
- JSON and YAML format support
- Git-based comparison for breaking changes
- Schema validation and circular reference detection
- Integration with Gowright test framework via core.Test interface
- Detailed error reporting with paths and descriptions

## Installation and Setup

### Prerequisites

- Go 1.23+ with the Gowright framework
- Git (for breaking change detection)
- OpenAPI specification file (JSON or YAML)

### Dependencies

The OpenAPI module uses the `pb33f/libopenapi` library for specification parsing and validation:

```go
import (
    "github.com/gowright/framework/pkg/openapi"
    "github.com/pb33f/libopenapi"
)
```

### Basic Setup

```go
package main

import (
    "fmt"
    "log"
    
    "github.com/gowright/framework/pkg/openapi"
)

func main() {
    // Create OpenAPI tester
    tester, err := openapi.NewOpenAPITester("path/to/openapi.yaml")
    if err != nil {
        log.Fatalf("Failed to create OpenAPI tester: %v", err)
    }
    
    fmt.Println("OpenAPI tester initialized successfully!")
}
```

## Basic Usage

### Framework Integration

The OpenAPI module integrates seamlessly with the Gowright framework for comprehensive API testing:

```go
package main

import (
    "fmt"
    "log"
    "time"
    
    "github.com/gowright/framework/pkg/gowright"
    "github.com/gowright/framework/pkg/openapi"
)

func main() {
    // Initialize Gowright framework with OpenAPI configuration
    config := gowright.Config{
        ProjectName: "OpenAPI Validation Demo",
        Environment: "development",
        API: gowright.APIConfig{
            BaseURL: "https://petstore.swagger.io/v2",
            Timeout: 30 * time.Second,
        },
        OpenAPI: gowright.OpenAPIConfig{
            SpecURL:        "https://petstore.swagger.io/v2/swagger.json",
            ValidateSchema: true,
            ValidateParams: true,
            ValidateResponse: true,
        },
        Reporting: gowright.ReportingConfig{
            Enabled:   true,
            OutputDir: "reports/openapi-tests",
            Formats:   []string{"html", "json"},
        },
    }

    framework, err := gowright.New(config)
    if err != nil {
        log.Fatalf("Failed to create framework: %v", err)
    }
    defer framework.Close()

    // Get OpenAPI tester from framework
    openAPITester, err := framework.OpenAPI()
    if err != nil {
        log.Fatalf("Failed to get OpenAPI tester: %v", err)
    }

    // Load and validate specification
    spec, err := openAPITester.LoadSpecification()
    if err != nil {
        log.Fatalf("Failed to load specification: %v", err)
    }

    fmt.Printf("Loaded OpenAPI specification: %s v%s\n", 
        spec.Info.Title, spec.Info.Version)
    
    // Validate request schema
    petData := map[string]interface{}{
        "name":      "Fluffy",
        "photoUrls": []string{"https://example.com/photo.jpg"},
        "status":    "available",
    }
    
    isValid, errors := openAPITester.ValidateRequestSchema("POST", "/pet", petData)
    if isValid {
        fmt.Println("✅ Pet data is valid according to OpenAPI schema")
    } else {
        fmt.Printf("❌ Pet data validation failed: %v\n", errors)
    }
}
```

### Simple Validation

```go
package main

import (
    "fmt"
    "testing"
    
    "github.com/gowright/framework/pkg/gowright"
    "github.com/stretchr/testify/assert"
)

func TestOpenAPIValidation(t *testing.T) {
    // Create framework with OpenAPI configuration
    config := gowright.DefaultConfig()
    config.OpenAPI.SpecURL = "./api/openapi.yaml"
    config.OpenAPI.ValidateSchema = true
    
    framework, err := gowright.New(config)
    assert.NoError(t, err)
    defer framework.Close()
    
    // Get OpenAPI tester
    tester, err := framework.OpenAPI()
    assert.NoError(t, err)
    
    // Load specification
    spec, err := tester.LoadSpecification()
    assert.NoError(t, err)
    assert.NotNil(t, spec.Info, "Specification should have info section")
    
    // Validate basic structure
    assert.NotEmpty(t, spec.Info.Title, "API should have a title")
    assert.NotEmpty(t, spec.Info.Version, "API should have a version")
    assert.NotEmpty(t, spec.Paths, "API should have paths defined")
    
    fmt.Printf("Validated OpenAPI specification: %s v%s\n", 
        spec.Info.Title, spec.Info.Version)
}
```

### Running All Tests

```go
func TestAllOpenAPITests(t *testing.T) {
    tester, err := openapi.NewOpenAPITester("openapi.yaml")
    assert.NoError(t, err)
    
    // Run all available tests (validation + circular reference detection)
    results := tester.RunAllTests("")
    
    fmt.Printf("Total tests run: %d\n", len(results))
    for _, result := range results {
        fmt.Printf("Test: %s - Status: %s\n", result.TestName, getStatusString(result.Passed))
        fmt.Printf("Message: %s\n", result.Message)
        
        if len(result.Details) > 0 {
            fmt.Println("Details:")
            for _, detail := range result.Details {
                fmt.Printf("  - %s\n", detail)
            }
        }
    }
    
    // Print summary
    summary := tester.GetSummary(results)
    fmt.Printf("\n%s\n", summary)
}

func getStatusString(passed bool) string {
    if passed {
        return "✅ PASSED"
    }
    return "❌ FAILED"
}
```

## Comprehensive Validation Capabilities

The Gowright OpenAPI module provides extensive validation capabilities beyond basic specification validation:

### Request and Response Schema Validation

```go
func TestSchemaValidation(t *testing.T) {
    framework, err := gowright.New(gowright.DefaultConfig())
    assert.NoError(t, err)
    defer framework.Close()
    
    tester, err := framework.OpenAPI()
    assert.NoError(t, err)
    
    // Validate request schema
    requestData := map[string]interface{}{
        "name":      "Test Pet",
        "photoUrls": []string{"https://example.com/photo.jpg"},
        "status":    "available",
    }
    
    isValid, errors := tester.ValidateRequestSchema("POST", "/pet", requestData)
    assert.True(t, isValid, "Request should be valid")
    assert.Empty(t, errors, "Should have no validation errors")
    
    // Test invalid request
    invalidRequest := map[string]interface{}{
        "name": 123, // Should be string
        // Missing required photoUrls
    }
    
    isValid, errors = tester.ValidateRequestSchema("POST", "/pet", invalidRequest)
    assert.False(t, isValid, "Invalid request should fail validation")
    assert.NotEmpty(t, errors, "Should have validation errors")
}
```

### Parameter Validation

```go
func TestParameterValidation(t *testing.T) {
    framework, err := gowright.New(gowright.DefaultConfig())
    assert.NoError(t, err)
    defer framework.Close()
    
    tester, err := framework.OpenAPI()
    assert.NoError(t, err)
    
    // Validate path parameters
    isValid, errors := tester.ValidatePathParameter("GET", "/pet/{petId}", "petId", "12345")
    assert.True(t, isValid, "Valid path parameter should pass")
    
    // Validate query parameters
    queryParams := map[string]string{
        "status": "available",
        "limit":  "10",
    }
    
    isValid, errors = tester.ValidateQueryParameters("GET", "/pet/findByStatus", queryParams)
    assert.True(t, isValid, "Valid query parameters should pass")
    
    // Test invalid query parameter
    invalidParams := map[string]string{
        "status": "invalid-status", // Not in enum
    }
    
    isValid, errors = tester.ValidateQueryParameters("GET", "/pet/findByStatus", invalidParams)
    assert.False(t, isValid, "Invalid query parameter should fail")
}
```

### Response Validation

```go
func TestResponseValidation(t *testing.T) {
    framework, err := gowright.New(gowright.DefaultConfig())
    assert.NoError(t, err)
    defer framework.Close()
    
    apiTester, err := framework.API()
    assert.NoError(t, err)
    
    openAPITester, err := framework.OpenAPI()
    assert.NoError(t, err)
    
    // Make API call
    resp, err := apiTester.GET("/pet/findByStatus?status=available")
    assert.NoError(t, err)
    
    // Validate response status
    expectedCodes := []int{200}
    isValid := openAPITester.ValidateResponseStatus("GET", "/pet/findByStatus", resp.StatusCode, expectedCodes)
    assert.True(t, isValid, "Response status should be valid")
    
    // Validate response headers
    expectedHeaders := map[string]string{
        "Content-Type": "application/json",
    }
    isValid = openAPITester.ValidateResponseHeaders("GET", "/pet/findByStatus", resp.Headers, expectedHeaders)
    assert.True(t, isValid, "Response headers should be valid")
    
    // Validate response schema
    var responseBody interface{}
    err = resp.JSON(&responseBody)
    assert.NoError(t, err)
    
    isValid, errors := openAPITester.ValidateResponseSchema("GET", "/pet/findByStatus", resp.StatusCode, responseBody)
    assert.True(t, isValid, "Response schema should be valid")
    assert.Empty(t, errors, "Should have no schema errors")
}
```

### Security Validation

```go
func TestSecurityValidation(t *testing.T) {
    framework, err := gowright.New(gowright.DefaultConfig())
    assert.NoError(t, err)
    defer framework.Close()
    
    tester, err := framework.OpenAPI()
    assert.NoError(t, err)
    
    // Check if operation requires security
    requiresSecurity := tester.IsSecurityRequired("POST", "/pet")
    t.Logf("POST /pet requires security: %v", requiresSecurity)
    
    // Load specification to check security schemes
    spec, err := tester.LoadSpecification()
    assert.NoError(t, err)
    
    if spec.SecurityDefinitions != nil {
        for name, scheme := range spec.SecurityDefinitions {
            t.Logf("Security scheme: %s (type: %s)", name, scheme.Type)
        }
    }
    
    if spec.Components.SecuritySchemes != nil {
        for name, scheme := range spec.Components.SecuritySchemes {
            t.Logf("Security scheme: %s (type: %s)", name, scheme.Type)
        }
    }
}
```

### Data Type and Format Validation

```go
func TestDataTypeValidation(t *testing.T) {
    framework, err := gowright.New(gowright.DefaultConfig())
    assert.NoError(t, err)
    defer framework.Close()
    
    tester, err := framework.OpenAPI()
    assert.NoError(t, err)
    
    // Test data type validation
    assert.True(t, tester.ValidateDataType(12345, "integer"))
    assert.False(t, tester.ValidateDataType("12345", "integer"))
    assert.True(t, tester.ValidateDataType("test", "string"))
    assert.False(t, tester.ValidateDataType(123, "string"))
    
    // Test format validation
    assert.True(t, tester.ValidateFormat("test@example.com", "email"))
    assert.False(t, tester.ValidateFormat("not-an-email", "email"))
    assert.True(t, tester.ValidateFormat("2023-12-25", "date"))
    assert.False(t, tester.ValidateFormat("not-a-date", "date"))
}
```

## Specification Validation

### Basic Validation

The OpenAPI module validates specifications against the OpenAPI 3.0.3 standard:

```go
func TestSpecificationValidation(t *testing.T) {
    tester, err := openapi.NewOpenAPITester("openapi.yaml")
    assert.NoError(t, err)
    
    // Validate OpenAPI specification
    result := tester.ValidateSpec()
    
    if result.Passed {
        fmt.Println("✅ OpenAPI specification is valid")
    } else {
        fmt.Println("❌ OpenAPI specification has issues:")
        
        // Print errors
        for _, err := range result.Errors {
            fmt.Printf("  Error at %s: %s\n", err.Path, err.Message)
        }
        
        // Print warnings
        for _, warning := range result.Warnings {
            fmt.Printf("  Warning at %s: %s\n", warning.Path, warning.Message)
        }
    }
}
```

### Validation Features

The validation checks for:

- **Required Fields**: Ensures info, paths, and other required sections are present
- **OpenAPI Version**: Validates the OpenAPI version is specified
- **Path Structure**: Validates path items and operations
- **Response Definitions**: Checks for proper response definitions
- **Schema Validation**: Validates component schemas
- **Operation Completeness**: Warns about missing descriptions or examples

### Validation Result Structure

```go
type TestResult struct {
    TestName string
    Passed   bool
    Message  string
    Details  []string
    Errors   []ValidationError
    Warnings []ValidationWarning
}

type ValidationError struct {
    Path     string
    Message  string
    Severity string
    Line     int
    Column   int
}

type ValidationWarning struct {
    Path       string
    Message    string
    Suggestion string
}
```

## Breaking Change Detection

The OpenAPI module can detect breaking changes between different versions of your API specification by comparing against previous git commits.

### Basic Breaking Change Detection

```go
func TestBreakingChangeDetection(t *testing.T) {
    tester, err := openapi.NewOpenAPITester("openapi.yaml")
    assert.NoError(t, err)
    
    // Check for breaking changes compared to previous commit
    result := tester.CheckBreakingChanges("HEAD~1")
    
    if result.Passed {
        fmt.Println("✅ No breaking changes detected")
    } else {
        fmt.Println("❌ Breaking changes detected:")
        
        for _, detail := range result.Details {
            fmt.Printf("  - %s\n", detail)
        }
    }
}
```

### Types of Breaking Changes Detected

The OpenAPI module detects several types of breaking changes:

- **PATH_REMOVED**: API endpoints that were removed
- **OPERATION_REMOVED**: HTTP methods that were removed from existing paths
- **REQUIRED_PARAMETER_ADDED**: New required parameters that break existing clients
- **SCHEMA_CHANGES**: Changes to response/request schemas that break compatibility

### Breaking Change Structure

```go
type BreakingChange struct {
    Type        string
    Path        string
    OldValue    interface{}
    NewValue    interface{}
    Description string
    Impact      string
}
```

### Git Integration

The breaking change detection integrates with git to compare specifications:

```go
func TestGitIntegration(t *testing.T) {
    tester, err := openapi.NewOpenAPITester("openapi.yaml")
    assert.NoError(t, err)
    
    // Compare with specific commit
    result1 := tester.CheckBreakingChanges("abc123")
    
    // Compare with branch
    result2 := tester.CheckBreakingChanges("origin/main")
    
    // Compare with tag
    result3 := tester.CheckBreakingChanges("v1.0.0")
    
    // Each result contains breaking change information
    for _, result := range []*openapi.TestResult{result1, result2, result3} {
        if !result.Passed {
            fmt.Printf("Breaking changes found: %s\n", result.Message)
        }
    }
}
```

## Circular Reference Detection

Circular references in OpenAPI specifications can cause issues with code generation and API documentation. The module can detect these automatically.

### Basic Circular Reference Detection

```go
func TestCircularReferenceDetection(t *testing.T) {
    tester, err := openapi.NewOpenAPITester("openapi.yaml")
    assert.NoError(t, err)
    
    // Check for circular references
    result := tester.DetectCircularReferences()
    
    if result.Passed {
        fmt.Println("✅ No circular references found")
    } else {
        fmt.Println("❌ Circular references detected:")
        
        for _, detail := range result.Details {
            fmt.Printf("  - %s\n", detail)
        }
    }
}
```

### Circular Reference Structure

```go
type CircularReference struct {
    Path        string
    RefChain    []string
    Description string
}
```

### Example Circular Reference

```yaml
components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
        profile:
          $ref: '#/components/schemas/Profile'
    Profile:
      type: object
      properties:
        user:
          $ref: '#/components/schemas/User'  # Circular reference
        bio:
          type: string
```

## Integration with Gowright Framework

The OpenAPI module integrates seamlessly with the Gowright testing framework, implementing the `core.Test` interface.

### Creating OpenAPI Integration

```go
func TestGowrightIntegration(t *testing.T) {
    // Create OpenAPI integration
    integration, err := openapi.NewOpenAPIIntegration("openapi.yaml")
    assert.NoError(t, err)
    
    // Create individual tests
    validationTest := integration.CreateValidationTest()
    circularRefTest := integration.CreateCircularReferenceTest()
    breakingChangesTest := integration.CreateBreakingChangesTest("HEAD~1")
    
    // Execute individual tests
    validationResult := validationTest.Execute()
    circularRefResult := circularRefTest.Execute()
    breakingChangesResult := breakingChangesTest.Execute()
    
    // Check results
    assert.Equal(t, core.TestStatusPassed, validationResult.Status)
    assert.Equal(t, core.TestStatusPassed, circularRefResult.Status)
    assert.Equal(t, core.TestStatusPassed, breakingChangesResult.Status)
}
```

### Creating Full Test Suite

```go
func TestFullTestSuite(t *testing.T) {
    integration, err := openapi.NewOpenAPIIntegration("openapi.yaml")
    assert.NoError(t, err)
    
    // Create a full test suite
    suite := integration.CreateFullTestSuite("HEAD~1")
    
    fmt.Printf("Running OpenAPI test suite: %s\n", suite.Name)
    fmt.Printf("Number of tests: %d\n", len(suite.Tests))
    
    // Run each test in the suite
    for _, test := range suite.Tests {
        fmt.Printf("\nRunning test: %s\n", test.GetName())
        
        result := test.Execute()
        
        if result.Status == core.TestStatusPassed {
            fmt.Println("Test passed successfully!")
        } else {
            fmt.Printf("Test failed: %v\n", result.Error)
        }
        
        // Print test logs
        for _, log := range result.Logs {
            fmt.Printf("  - %s\n", log)
        }
    }
}
```

### Available Integration Methods

- `CreateValidationTest()`: Creates a test for OpenAPI specification validation
- `CreateCircularReferenceTest()`: Creates a test for circular reference detection
- `CreateBreakingChangesTest(previousCommit string)`: Creates a test for breaking changes detection
- `CreateFullTestSuite(previousCommit string)`: Creates a complete test suite with all tests

### Test Interface Implementation

Each OpenAPI test implements the `core.Test` interface:

```go
type Test interface {
    GetName() string
    Execute() *TestCaseResult
}

type TestCaseResult struct {
    Name      string
    Status    TestStatus
    StartTime time.Time
    EndTime   time.Time
    Duration  time.Duration
    Error     error
    Logs      []string
}
```

## Test Builder Pattern

The OpenAPI module provides a fluent builder pattern for creating customized test suites.

### Basic Builder Usage

```go
func TestBuilderPattern(t *testing.T) {
    // Use the builder pattern to create a customized test suite
    suite, err := openapi.NewOpenAPITestBuilder("openapi.yaml").
        WithValidation(true).
        WithCircularReferenceDetection(true).
        WithBreakingChangesDetection(true, "HEAD~1").
        Build()
    
    assert.NoError(t, err)
    assert.NotNil(t, suite)
    
    fmt.Printf("Created test suite: %s\n", suite.Name)
    fmt.Printf("Number of tests: %d\n", len(suite.Tests))
    
    for i, test := range suite.Tests {
        fmt.Printf("  %d. %s\n", i+1, test.GetName())
    }
}
```

### Builder Methods

- `WithValidation(enabled bool)`: Enable/disable specification validation
- `WithCircularReferenceDetection(enabled bool)`: Enable/disable circular reference detection
- `WithBreakingChangesDetection(enabled bool, commit string)`: Enable/disable breaking changes detection
- `WithPreviousCommit(commit string)`: Set the git commit to compare against
- `Build()`: Create the final test suite

### Advanced Builder Configuration

```go
func TestAdvancedBuilder(t *testing.T) {
    // Create a minimal test suite with only validation
    minimalSuite, err := openapi.NewOpenAPITestBuilder("openapi.yaml").
        WithValidation(true).
        WithCircularReferenceDetection(false).
        WithBreakingChangesDetection(false, "").
        Build()
    
    assert.NoError(t, err)
    assert.Equal(t, 1, len(minimalSuite.Tests)) // Only validation test
    
    // Create a comprehensive test suite
    comprehensiveSuite, err := openapi.NewOpenAPITestBuilder("openapi.yaml").
        WithValidation(true).
        WithCircularReferenceDetection(true).
        WithBreakingChangesDetection(true, "HEAD~1").
        Build()
    
    assert.NoError(t, err)
    assert.Equal(t, 3, len(comprehensiveSuite.Tests)) // All tests included
}
```

## Configuration and Best Practices

### Environment-Based Configuration

```go
func getOpenAPIConfig() (string, string) {
    specPath := os.Getenv("OPENAPI_SPEC_PATH")
    if specPath == "" {
        specPath = "openapi.yaml" // default
    }
    
    previousCommit := os.Getenv("OPENAPI_PREVIOUS_COMMIT")
    if previousCommit == "" {
        previousCommit = "HEAD~1" // default
    }
    
    return specPath, previousCommit
}

func TestEnvironmentConfig(t *testing.T) {
    specPath, previousCommit := getOpenAPIConfig()
    
    tester, err := openapi.NewOpenAPITester(specPath)
    assert.NoError(t, err)
    
    // Run tests with environment configuration
    results := tester.RunAllTests(previousCommit)
    
    for _, result := range results {
        if !result.Passed {
            t.Errorf("Test %s failed: %s", result.TestName, result.Message)
        }
    }
}
```

### CI/CD Integration

```go
func TestCIIntegration(t *testing.T) {
    if os.Getenv("CI") == "" {
        t.Skip("Skipping CI-specific test")
    }
    
    tester, err := openapi.NewOpenAPITester("openapi.yaml")
    assert.NoError(t, err)
    
    // In CI, always check breaking changes against main branch
    result := tester.CheckBreakingChanges("origin/main")
    
    if !result.Passed {
        // Fail the build if breaking changes are detected
        t.Fatalf("Breaking changes detected in CI: %s", result.Message)
    }
}
```

### Best Practices

1. **Version Control Integration**: Always check breaking changes in CI/CD pipelines
2. **Comprehensive Testing**: Run all three test types for complete coverage
3. **Error Handling**: Check both errors and warnings
4. **Automation**: Use the builder pattern for customized test suites
5. **Documentation**: Keep OpenAPI specifications up-to-date

### Example CI/CD Workflow

```yaml
# .github/workflows/openapi-validation.yml
name: OpenAPI Validation

on:
  pull_request:
    paths:
      - 'api/openapi.yaml'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Needed for git history
      
      - uses: actions/setup-go@v3
        with:
          go-version: '1.23'
      
      - name: Run OpenAPI Tests
        run: |
          go test -v ./tests/openapi_test.go
        env:
          OPENAPI_SPEC_PATH: api/openapi.yaml
          OPENAPI_PREVIOUS_COMMIT: origin/main
```

## Troubleshooting

### Common Issues

#### 1. Specification File Not Found

```go
func TestFileHandling(t *testing.T) {
    // Test with non-existent file
    _, err := openapi.NewOpenAPITester("non-existent.yaml")
    assert.Error(t, err)
    assert.Contains(t, err.Error(), "failed to read spec file")
}
```

**Solution**: Ensure the OpenAPI specification file exists and the path is correct.

#### 2. Invalid OpenAPI Specification

```go
func TestInvalidSpec(t *testing.T) {
    // Create invalid spec
    invalidSpec := `
openapi: 3.0.3
info:
  title: Test API
  # Missing version field
paths: {}
`
    
    tmpFile, err := os.CreateTemp("", "invalid-*.yaml")
    assert.NoError(t, err)
    defer os.Remove(tmpFile.Name())
    
    _, err = tmpFile.WriteString(invalidSpec)
    assert.NoError(t, err)
    tmpFile.Close()
    
    tester, err := openapi.NewOpenAPITester(tmpFile.Name())
    if err != nil {
        t.Logf("Expected error for invalid spec: %v", err)
        return
    }
    
    result := tester.ValidateSpec()
    assert.False(t, result.Passed)
    assert.Greater(t, len(result.Errors), 0)
}
```

**Solution**: Fix the OpenAPI specification according to the validation errors reported.

#### 3. Git Repository Issues

```go
func TestGitIssues(t *testing.T) {
    tester, err := openapi.NewOpenAPITester("openapi.yaml")
    assert.NoError(t, err)
    
    // Test with invalid commit
    result := tester.CheckBreakingChanges("invalid-commit")
    assert.False(t, result.Passed)
    assert.Contains(t, result.Message, "Failed to get previous spec")
}
```

**Solution**: Ensure you're in a git repository and the specified commit exists.

#### 4. Large Specification Performance

For large OpenAPI specifications, consider:

- Using the builder pattern to run only necessary tests
- Implementing caching for repeated validations
- Running tests in parallel when possible

```go
func TestLargeSpecOptimization(t *testing.T) {
    // For large specs, run only essential tests
    suite, err := openapi.NewOpenAPITestBuilder("large-openapi.yaml").
        WithValidation(true).
        WithCircularReferenceDetection(false). // Skip if not needed
        WithBreakingChangesDetection(false, ""). // Skip if not needed
        Build()
    
    assert.NoError(t, err)
    
    // Run tests
    for _, test := range suite.Tests {
        result := test.Execute()
        assert.Equal(t, core.TestStatusPassed, result.Status)
    }
}
```

### Debug Mode

Enable debug logging for troubleshooting:

```go
func TestDebugMode(t *testing.T) {
    // Set debug environment variable
    os.Setenv("GOWRIGHT_DEBUG", "true")
    defer os.Unsetenv("GOWRIGHT_DEBUG")
    
    tester, err := openapi.NewOpenAPITester("openapi.yaml")
    assert.NoError(t, err)
    
    // Debug information will be logged during execution
    result := tester.ValidateSpec()
    
    // Check result
    if !result.Passed {
        t.Logf("Debug: Validation failed with %d errors", len(result.Errors))
        for _, err := range result.Errors {
            t.Logf("Debug: Error at %s: %s", err.Path, err.Message)
        }
    }
}
```

## Summary

The OpenAPI testing module provides comprehensive validation capabilities for OpenAPI specifications:

- **Specification Validation**: Ensures compliance with OpenAPI 3.0.3 standard
- **Breaking Change Detection**: Compares specifications across git commits
- **Circular Reference Detection**: Identifies problematic schema references
- **Framework Integration**: Seamless integration with Gowright testing framework
- **Flexible Configuration**: Builder pattern and environment-based configuration

This module helps maintain API quality and backward compatibility throughout the development lifecycle.