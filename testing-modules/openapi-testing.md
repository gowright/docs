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

### Simple Validation

```go
package main

import (
    "fmt"
    "testing"
    
    "github.com/gowright/framework/pkg/openapi"
    "github.com/stretchr/testify/assert"
)

func TestOpenAPIValidation(t *testing.T) {
    // Create OpenAPI tester
    tester, err := openapi.NewOpenAPITester("./api/openapi.yaml")
    assert.NoError(t, err)
    
    // Validate the specification
    result := tester.ValidateSpec()
    
    // Check validation result
    assert.True(t, result.Passed, "OpenAPI specification should be valid")
    
    // Print any warnings
    for _, warning := range result.Warnings {
        t.Logf("Warning at %s: %s", warning.Path, warning.Message)
    }
    
    // Print any errors
    for _, err := range result.Errors {
        t.Errorf("Error at %s: %s", err.Path, err.Message)
    }
    
    fmt.Printf("Validation completed: %d warnings, %d errors\n", 
        len(result.Warnings), len(result.Errors))
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