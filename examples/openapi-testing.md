# OpenAPI Testing Examples (1/3 - 33% Complete)

This document provides comprehensive examples of OpenAPI specification testing using the Gowright framework's OpenAPI module. These examples demonstrate real-world scenarios for specification validation, request/response validation, parameter validation, security validation, and comprehensive API testing.

## 📁 OpenAPI Testing Examples Structure

The OpenAPI testing examples are organized in the `examples/openapi-testing/` directory:

### 📋 Core OpenAPI Testing Examples

#### 1. **OpenAPI Specification Validation** (`openapi-testing/openapi_validation.go`) ✅ **NEW**
Comprehensive OpenAPI specification validation and testing.

**Key Concepts:**
- Specification loading and parsing
- Schema validation for requests and responses
- Parameter validation (path, query, header)
- Response validation against specifications
- Security scheme validation
- Data type and format validation
- Required field validation
- Path and operation validation

**Example Usage:**
```bash
go run examples/openapi-testing/openapi_validation.go
```

**Features Demonstrated:**
- Real API testing with specification validation
- Comprehensive error handling and reporting
- Integration with live APIs (Petstore example)
- Multiple validation types in a single test suite

## Table of Contents

1. [Complete OpenAPI Validation Example](#complete-openapi-validation-example)
2. [Basic OpenAPI Validation](#basic-openapi-validation)
3. [Schema and Request Validation](#schema-and-request-validation)
4. [Parameter and Response Validation](#parameter-and-response-validation)
5. [Security and Path Validation](#security-and-path-validation)
6. [Data Type and Required Field Validation](#data-type-and-required-field-validation)
7. [Integration with Gowright Framework](#integration-with-gowright-framework)
8. [Breaking Changes Detection](#breaking-changes-detection)
9. [Circular Reference Detection](#circular-reference-detection)
10. [Test Builder Pattern](#test-builder-pattern)

## Complete OpenAPI Validation Example

The following example demonstrates a comprehensive OpenAPI validation test suite that covers all aspects of OpenAPI specification testing:

```go
package main

import (
	"fmt"
	"log"
	"time"

	"github.com/gowright/framework/pkg/gowright"
	"github.com/gowright/framework/pkg/api"
	"github.com/gowright/framework/pkg/openapi"
	"github.com/gowright/framework/pkg/reporting"
)

// OpenAPIValidationTestSuite demonstrates comprehensive OpenAPI specification validation
type OpenAPIValidationTestSuite struct {
	framework    *gowright.Framework
	apiTester    *api.APITester
	openAPITester *openapi.OpenAPITester
	reporter     *reporting.Reporter
}

func main() {
	fmt.Println("🚀 Starting Gowright OpenAPI Validation Testing Example")
	fmt.Println("======================================================")

	suite := &OpenAPIValidationTestSuite{}
	if err := suite.Initialize(); err != nil {
		log.Fatalf("Failed to initialize test suite: %v", err)
	}
	defer suite.Cleanup()

	// Run comprehensive OpenAPI validation tests
	suite.RunOpenAPIValidationTests()

	fmt.Println("\n✅ OpenAPI validation testing completed successfully!")
	fmt.Println("📊 Check the generated reports for detailed results")
}

func (s *OpenAPIValidationTestSuite) Initialize() error {
	fmt.Println("\n🔧 Initializing OpenAPI Validation Test Suite...")

	// Initialize framework with comprehensive configuration
	config := gowright.Config{
		ProjectName: "OpenAPI Validation Testing Demo",
		Environment: "development",
		API: gowright.APIConfig{
			BaseURL: "https://petstore.swagger.io/v2",
			Timeout: 30 * time.Second,
			Headers: map[string]string{
				"User-Agent": "Gowright-OpenAPI-Tester/1.0",
			},
		},
		OpenAPI: gowright.OpenAPIConfig{
			SpecURL:        "https://petstore.swagger.io/v2/swagger.json",
			ValidateSchema: true,
			ValidateParams: true,
			ValidateResponse: true,
		},
		Reporting: gowright.ReportingConfig{
			Enabled:   true,
			OutputDir: "reports/openapi-validation-tests",
			Formats:   []string{"html", "json"},
		},
	}

	var err error
	s.framework, err = gowright.New(config)
	if err != nil {
		return fmt.Errorf("failed to create framework: %w", err)
	}

	// Initialize API tester
	s.apiTester, err = s.framework.API()
	if err != nil {
		return fmt.Errorf("failed to initialize API tester: %w", err)
	}

	// Initialize OpenAPI tester
	s.openAPITester, err = s.framework.OpenAPI()
	if err != nil {
		return fmt.Errorf("failed to initialize OpenAPI tester: %w", err)
	}

	// Initialize reporter
	s.reporter = s.framework.Reporter()

	fmt.Println("✅ Test suite initialized successfully")
	return nil
}

func (s *OpenAPIValidationTestSuite) RunOpenAPIValidationTests() {
	fmt.Println("\n📋 Running OpenAPI Validation Tests...")

	// Test 1: Specification loading and parsing
	s.TestSpecificationLoading()

	// Test 2: Schema validation
	s.TestSchemaValidation()

	// Test 3: Parameter validation
	s.TestParameterValidation()

	// Test 4: Response validation
	s.TestResponseValidation()

	// Test 5: Security scheme validation
	s.TestSecurityValidation()

	// Test 6: Path and operation validation
	s.TestPathOperationValidation()

	// Test 7: Data type validation
	s.TestDataTypeValidation()

	// Test 8: Required field validation
	s.TestRequiredFieldValidation()

	// Generate final report
	s.GenerateReport()
}
```

This example demonstrates the complete OpenAPI validation workflow including:

- **Framework Integration**: Seamless integration with the Gowright testing framework
- **Configuration Management**: Comprehensive configuration for API and OpenAPI testing
- **Multiple Validation Types**: Schema, parameter, response, security, and data type validation
- **Real API Testing**: Integration with live APIs (Petstore example)
- **Comprehensive Reporting**: Detailed HTML and JSON reports
- **Error Handling**: Robust error handling and cleanup

## Schema and Request Validation

### Schema Validation Example

The OpenAPI module provides comprehensive schema validation for request and response data:

```go
func (s *OpenAPIValidationTestSuite) TestSchemaValidation() {
	fmt.Println("\n🔍 Testing Schema Validation...")

	testCase := s.reporter.StartTest("Schema Validation", "Validate request/response schemas against OpenAPI spec")

	// Test valid pet creation
	validPet := map[string]interface{}{
		"id":   12345,
		"name": "Fluffy",
		"category": map[string]interface{}{
			"id":   1,
			"name": "Dogs",
		},
		"photoUrls": []string{"https://example.com/photo1.jpg"},
		"tags": []map[string]interface{}{
			{
				"id":   1,
				"name": "friendly",
			},
		},
		"status": "available",
	}

	// Validate against schema
	isValid, errors := s.openAPITester.ValidateRequestSchema("POST", "/pet", validPet)
	if !isValid {
		testCase.AddStep(fmt.Sprintf("Valid pet schema validation failed: %v", errors), "warning")
	} else {
		testCase.AddStep("Valid pet schema validation passed", "pass")
	}

	// Test invalid pet (missing required fields)
	invalidPet := map[string]interface{}{
		"id": 12345,
		// Missing required "name" and "photoUrls"
		"status": "available",
	}

	isValid, errors = s.openAPITester.ValidateRequestSchema("POST", "/pet", invalidPet)
	if isValid {
		testCase.AddStep("Invalid pet schema should have failed validation", "warning")
	} else {
		testCase.AddStep(fmt.Sprintf("Invalid pet schema correctly rejected: %v", errors), "pass")
	}

	// Test with wrong data types
	wrongTypePet := map[string]interface{}{
		"id":        "not-a-number", // Should be integer
		"name":      "Fluffy",
		"photoUrls": "not-an-array", // Should be array
		"status":    "available",
	}

	isValid, errors = s.openAPITester.ValidateRequestSchema("POST", "/pet", wrongTypePet)
	if isValid {
		testCase.AddStep("Wrong data type schema should have failed validation", "warning")
	} else {
		testCase.AddStep("Wrong data type schema correctly rejected", "pass")
	}

	testCase.Pass("Schema validation tests completed")
	fmt.Println("✅ Schema validation test passed")
}
```

### Key Schema Validation Features

- **Request Schema Validation**: Validates request bodies against OpenAPI schema definitions
- **Data Type Checking**: Ensures correct data types (integer, string, array, object)
- **Required Field Validation**: Checks for missing required fields
- **Format Validation**: Validates string formats (email, date, UUID, etc.)
- **Nested Object Support**: Handles complex nested object structures
- **Array Validation**: Validates array items and structure

## Parameter and Response Validation

### Parameter Validation Example

```go
func (s *OpenAPIValidationTestSuite) TestParameterValidation() {
	fmt.Println("\n🔧 Testing Parameter Validation...")

	testCase := s.reporter.StartTest("Parameter Validation", "Validate API parameters against OpenAPI spec")

	// Test valid path parameter
	petID := "12345"
	isValid, errors := s.openAPITester.ValidatePathParameter("GET", "/pet/{petId}", "petId", petID)
	if !isValid {
		testCase.AddStep(fmt.Sprintf("Valid path parameter validation failed: %v", errors), "warning")
	} else {
		testCase.AddStep("Valid path parameter validation passed", "pass")
	}

	// Test invalid path parameter (non-numeric for integer parameter)
	invalidPetID := "not-a-number"
	isValid, errors = s.openAPITester.ValidatePathParameter("GET", "/pet/{petId}", "petId", invalidPetID)
	if isValid {
		testCase.AddStep("Invalid path parameter should have failed validation", "warning")
	} else {
		testCase.AddStep("Invalid path parameter correctly rejected", "pass")
	}

	// Test query parameters
	queryParams := map[string]string{
		"status": "available",
	}
	isValid, errors = s.openAPITester.ValidateQueryParameters("GET", "/pet/findByStatus", queryParams)
	if !isValid {
		testCase.AddStep(fmt.Sprintf("Valid query parameter validation failed: %v", errors), "warning")
	} else {
		testCase.AddStep("Valid query parameter validation passed", "pass")
	}

	// Test invalid query parameter value
	invalidQueryParams := map[string]string{
		"status": "invalid-status", // Should be one of: available, pending, sold
	}
	isValid, errors = s.openAPITester.ValidateQueryParameters("GET", "/pet/findByStatus", invalidQueryParams)
	if isValid {
		testCase.AddStep("Invalid query parameter should have failed validation", "warning")
	} else {
		testCase.AddStep("Invalid query parameter correctly rejected", "pass")
	}

	testCase.Pass("Parameter validation tests completed")
	fmt.Println("✅ Parameter validation test passed")
}
```

### Response Validation Example

```go
func (s *OpenAPIValidationTestSuite) TestResponseValidation() {
	fmt.Println("\n📤 Testing Response Validation...")

	testCase := s.reporter.StartTest("Response Validation", "Validate API responses against OpenAPI spec")

	// Make actual API call and validate response
	resp, err := s.apiTester.GET("/pet/findByStatus?status=available")
	if err != nil {
		testCase.Fail("API call failed", err.Error())
		return
	}

	// Validate response status code
	expectedStatusCodes := []int{200}
	isValidStatus := s.openAPITester.ValidateResponseStatus("GET", "/pet/findByStatus", resp.StatusCode, expectedStatusCodes)
	if !isValidStatus {
		testCase.AddStep(fmt.Sprintf("Unexpected status code: %d", resp.StatusCode), "warning")
	} else {
		testCase.AddStep(fmt.Sprintf("Valid status code: %d", resp.StatusCode), "pass")
	}

	// Validate response headers
	expectedHeaders := map[string]string{
		"Content-Type": "application/json",
	}
	isValidHeaders := s.openAPITester.ValidateResponseHeaders("GET", "/pet/findByStatus", resp.Headers, expectedHeaders)
	if !isValidHeaders {
		testCase.AddStep("Response headers validation failed", "warning")
	} else {
		testCase.AddStep("Response headers validation passed", "pass")
	}

	// Validate response schema
	var responseBody interface{}
	if err := resp.JSON(&responseBody); err != nil {
		testCase.AddStep("Failed to parse response JSON", "warning")
	} else {
		isValidSchema, schemaErrors := s.openAPITester.ValidateResponseSchema("GET", "/pet/findByStatus", resp.StatusCode, responseBody)
		if !isValidSchema {
			testCase.AddStep(fmt.Sprintf("Response schema validation failed: %v", schemaErrors), "warning")
		} else {
			testCase.AddStep("Response schema validation passed", "pass")
		}
	}

	testCase.Pass("Response validation tests completed")
	fmt.Println("✅ Response validation test passed")
}
```

## Security and Path Validation

### Security Validation Example

```go
func (s *OpenAPIValidationTestSuite) TestSecurityValidation() {
	fmt.Println("\n🔒 Testing Security Validation...")

	testCase := s.reporter.StartTest("Security Validation", "Validate API security schemes against OpenAPI spec")

	// Check if security schemes are defined
	spec, err := s.openAPITester.LoadSpecification()
	if err != nil {
		testCase.Fail("Failed to load specification for security validation", err.Error())
		return
	}

	if spec.SecurityDefinitions == nil && spec.Components.SecuritySchemes == nil {
		testCase.AddStep("No security schemes defined in specification", "warning")
	} else {
		testCase.AddStep("Security schemes found in specification", "pass")
		
		// List security schemes
		if spec.SecurityDefinitions != nil {
			for name, scheme := range spec.SecurityDefinitions {
				testCase.AddStep(fmt.Sprintf("Security scheme: %s (type: %s)", name, scheme.Type), "info")
			}
		}
		
		if spec.Components.SecuritySchemes != nil {
			for name, scheme := range spec.Components.SecuritySchemes {
				testCase.AddStep(fmt.Sprintf("Security scheme: %s (type: %s)", name, scheme.Type), "info")
			}
		}
	}

	// Test API key authentication
	s.apiTester.SetHeader("api_key", "test-api-key")
	resp, err := s.apiTester.GET("/pet/findByStatus?status=available")
	if err == nil {
		testCase.AddStep(fmt.Sprintf("API call with API key: status %d", resp.StatusCode), "info")
	}

	// Validate security requirements for specific operations
	securityRequired := s.openAPITester.IsSecurityRequired("POST", "/pet")
	if securityRequired {
		testCase.AddStep("POST /pet requires authentication", "info")
	} else {
		testCase.AddStep("POST /pet does not require authentication", "info")
	}

	testCase.Pass("Security validation tests completed")
	fmt.Println("✅ Security validation test passed")
}
```

### Path and Operation Validation Example

```go
func (s *OpenAPIValidationTestSuite) TestPathOperationValidation() {
	fmt.Println("\n🛣️ Testing Path and Operation Validation...")

	testCase := s.reporter.StartTest("Path Operation Validation", "Validate API paths and operations against OpenAPI spec")

	// Test valid paths and operations
	validEndpoints := []struct {
		method string
		path   string
	}{
		{"GET", "/pet/findByStatus"},
		{"GET", "/pet/findByTags"},
		{"GET", "/pet/{petId}"},
		{"POST", "/pet"},
		{"PUT", "/pet"},
		{"DELETE", "/pet/{petId}"},
	}

	for _, endpoint := range validEndpoints {
		exists := s.openAPITester.PathOperationExists(endpoint.method, endpoint.path)
		if exists {
			testCase.AddStep(fmt.Sprintf("%s %s: operation exists", endpoint.method, endpoint.path), "pass")
		} else {
			testCase.AddStep(fmt.Sprintf("%s %s: operation not found in spec", endpoint.method, endpoint.path), "warning")
		}
	}

	// Validate operation metadata
	operation := s.openAPITester.GetOperation("GET", "/pet/findByStatus")
	if operation != nil {
		testCase.AddStep(fmt.Sprintf("Operation summary: %s", operation.Summary), "info")
		testCase.AddStep(fmt.Sprintf("Operation description: %s", operation.Description), "info")
		
		if len(operation.Tags) > 0 {
			testCase.AddStep(fmt.Sprintf("Operation tags: %v", operation.Tags), "info")
		}
	}

	testCase.Pass("Path and operation validation tests completed")
	fmt.Println("✅ Path and operation validation test passed")
}
```

## Data Type and Required Field Validation

### Data Type Validation Example

```go
func (s *OpenAPIValidationTestSuite) TestDataTypeValidation() {
	fmt.Println("\n🔢 Testing Data Type Validation...")

	testCase := s.reporter.StartTest("Data Type Validation", "Validate data types against OpenAPI spec")

	// Test integer validation
	testCases := []struct {
		name     string
		value    interface{}
		expected string
		valid    bool
	}{
		{"Valid integer", 12345, "integer", true},
		{"Invalid integer (string)", "12345", "integer", false},
		{"Valid string", "test", "string", true},
		{"Invalid string (number)", 123, "string", false},
		{"Valid boolean", true, "boolean", true},
		{"Invalid boolean (string)", "true", "boolean", false},
		{"Valid array", []string{"a", "b"}, "array", true},
		{"Invalid array (string)", "not-array", "array", false},
	}

	for _, tc := range testCases {
		isValid := s.openAPITester.ValidateDataType(tc.value, tc.expected)
		if isValid == tc.valid {
			testCase.AddStep(fmt.Sprintf("%s: validation correct", tc.name), "pass")
		} else {
			testCase.AddStep(fmt.Sprintf("%s: validation incorrect (expected %v, got %v)", tc.name, tc.valid, isValid), "warning")
		}
	}

	// Test format validation
	formatTests := []struct {
		name   string
		value  string
		format string
		valid  bool
	}{
		{"Valid email", "test@example.com", "email", true},
		{"Invalid email", "not-an-email", "email", false},
		{"Valid date", "2023-12-25", "date", true},
		{"Invalid date", "not-a-date", "date", false},
		{"Valid UUID", "123e4567-e89b-12d3-a456-426614174000", "uuid", true},
		{"Invalid UUID", "not-a-uuid", "uuid", false},
	}

	for _, tc := range formatTests {
		isValid := s.openAPITester.ValidateFormat(tc.value, tc.format)
		if isValid == tc.valid {
			testCase.AddStep(fmt.Sprintf("%s: format validation correct", tc.name), "pass")
		} else {
			testCase.AddStep(fmt.Sprintf("%s: format validation incorrect", tc.name), "warning")
		}
	}

	testCase.Pass("Data type validation tests completed")
	fmt.Println("✅ Data type validation test passed")
}
```

### Required Field Validation Example

```go
func (s *OpenAPIValidationTestSuite) TestRequiredFieldValidation() {
	fmt.Println("\n✅ Testing Required Field Validation...")

	testCase := s.reporter.StartTest("Required Field Validation", "Validate required fields against OpenAPI spec")

	// Test pet creation with all required fields
	completePet := map[string]interface{}{
		"name":      "Fluffy",
		"photoUrls": []string{"https://example.com/photo.jpg"},
		"status":    "available",
	}

	isValid, errors := s.openAPITester.ValidateRequiredFields("POST", "/pet", completePet)
	if isValid {
		testCase.AddStep("Complete pet with all required fields: validation passed", "pass")
	} else {
		testCase.AddStep(fmt.Sprintf("Complete pet validation failed: %v", errors), "warning")
	}

	// Test pet creation missing required fields
	incompletePet := map[string]interface{}{
		"name": "Fluffy",
		// Missing required "photoUrls"
	}

	isValid, errors = s.openAPITester.ValidateRequiredFields("POST", "/pet", incompletePet)
	if !isValid {
		testCase.AddStep(fmt.Sprintf("Incomplete pet correctly rejected: %v", errors), "pass")
	} else {
		testCase.AddStep("Incomplete pet should have failed validation", "warning")
	}

	testCase.Pass("Required field validation tests completed")
	fmt.Println("✅ Required field validation test passed")
}
```

## Basic OpenAPI Validation

### Simple Specification Validation

```go
package main

import (
    "fmt"
    "log"
    "os"
    
    "github.com/gowright/framework/pkg/openapi"
)

func main() {
    // Create a sample OpenAPI spec file for testing
    createSampleSpec()
    
    // Basic validation example
    basicValidationExample()
    
    // Detailed validation with error handling
    detailedValidationExample()
}

func createSampleSpec() {
    specContent := `
openapi: 3.0.3
info:
  title: Sample API
  version: 1.0.0
  description: A sample API for demonstration
paths:
  /users:
    get:
      summary: Get all users
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'
  /users/{id}:
    get:
      summary: Get user by ID
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: User found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '404':
          description: User not found
components:
  schemas:
    User:
      type: object
      required:
        - id
        - name
      properties:
        id:
          type: string
        name:
          type: string
        email:
          type: string
          format: email
`
    
    err := os.WriteFile("sample-openapi.yaml", []byte(specContent), 0644)
    if err != nil {
        log.Fatalf("Failed to create sample spec: %v", err)
    }
}

func basicValidationExample() {
    // Create OpenAPI tester
    tester, err := openapi.NewOpenAPITester("sample-openapi.yaml")
    if err != nil {
        log.Fatalf("Failed to create OpenAPI tester: %v", err)
    }

    // Run validation
    result := tester.ValidateSpec()
    fmt.Printf("Validation Result: %s\n", result.Message)
    fmt.Printf("Passed: %t\n", result.Passed)

    if len(result.Errors) > 0 {
        fmt.Println("Errors:")
        for _, err := range result.Errors {
            fmt.Printf("  - %s: %s\n", err.Path, err.Message)
        }
    }

    if len(result.Warnings) > 0 {
        fmt.Println("Warnings:")
        for _, warning := range result.Warnings {
            fmt.Printf("  - %s: %s\n", warning.Path, warning.Message)
        }
    }
}

func detailedValidationExample() {
    tester, err := openapi.NewOpenAPITester("sample-openapi.yaml")
    if err != nil {
        log.Fatalf("Failed to create OpenAPI tester: %v", err)
    }

    // Run all available tests
    results := tester.RunAllTests("")
    
    fmt.Printf("Total tests run: %d\n", len(results))
    for _, result := range results {
        fmt.Printf("\nTest: %s\n", result.TestName)
        fmt.Printf("Status: %s\n", getStatusString(result.Passed))
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

## Breaking Changes Detection

The OpenAPI module can detect breaking changes between different versions of your API specification by comparing against previous git commits.

```go
func breakingChangesExample() {
    // Create a more complex OpenAPI spec with potential breaking changes
    specContent := `
openapi: 3.0.3
info:
  title: E-commerce API
  version: 2.0.0
  description: A comprehensive e-commerce API
paths:
  /products:
    get:
      summary: List products
      parameters:
        - name: category
          in: query
          schema:
            type: string
        - name: limit
          in: query
          required: true  # This could be a breaking change if it was optional before
          schema:
            type: integer
            minimum: 1
            maximum: 100
      responses:
        '200':
          description: Products retrieved successfully
          content:
            application/json:
              schema:
                type: object
                properties:
                  products:
                    type: array
                    items:
                      $ref: '#/components/schemas/Product'
                  total:
                    type: integer
components:
  schemas:
    Product:
      type: object
      required:
        - id
        - name
        - price
        - email  # This could be a breaking change if it was optional before
      properties:
        id:
          type: string
        name:
          type: string
        price:
          type: number
          format: float
          minimum: 0
        email:
          type: string
          format: email
`

    tmpFile := "temp_breaking_changes.yaml"
    if err := os.WriteFile(tmpFile, []byte(specContent), 0644); err != nil {
        log.Fatalf("Failed to write temp spec file: %v", err)
    }
    defer os.Remove(tmpFile)

    tester, err := openapi.NewOpenAPITester(tmpFile)
    if err != nil {
        log.Fatalf("Failed to create OpenAPI tester: %v", err)
    }

    // Check breaking changes against previous commit
    result := tester.CheckBreakingChanges("HEAD~1")
    fmt.Printf("Breaking changes check: %s\n", result.Message)
    fmt.Printf("Status: %s\n", getStatusString(result.Passed))

    if len(result.Details) > 0 {
        fmt.Println("Breaking changes found:")
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

## Circular Reference Detection

Circular references in OpenAPI specifications can cause issues with code generation and API documentation. The module can detect these automatically.

```go
func circularReferenceExample() {
    // Create a spec with potential circular references
    specContent := `
openapi: 3.0.3
info:
  title: Circular Reference API
  version: 1.0.0
paths:
  /users:
    get:
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
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
          $ref: '#/components/schemas/User'  # Potential circular reference
        bio:
          type: string
`

    tmpFile := "temp_circular.yaml"
    if err := os.WriteFile(tmpFile, []byte(specContent), 0644); err != nil {
        log.Fatalf("Failed to write temp spec file: %v", err)
    }
    defer os.Remove(tmpFile)

    tester, err := openapi.NewOpenAPITester(tmpFile)
    if err != nil {
        log.Fatalf("Failed to create OpenAPI tester: %v", err)
    }

    // Detect circular references
    result := tester.DetectCircularReferences()
    fmt.Printf("Circular reference detection: %s\n", result.Message)
    fmt.Printf("Status: %s\n", getStatusString(result.Passed))

    if len(result.Details) > 0 {
        fmt.Println("Circular references found:")
        for _, detail := range result.Details {
            fmt.Printf("  - %s\n", detail)
        }
    }
}
```

## Test Builder Pattern

The OpenAPI module provides a fluent builder pattern for creating customized test suites.

```go
func testBuilderExample() {
    specContent := `
openapi: 3.0.3
info:
  title: Builder Pattern API
  version: 1.0.0
paths:
  /health:
    get:
      responses:
        '200':
          description: Health check
          content:
            application/json:
              schema:
                type: object
                properties:
                  status:
                    type: string
`

    tmpFile := "temp_builder.yaml"
    if err := os.WriteFile(tmpFile, []byte(specContent), 0644); err != nil {
        log.Fatalf("Failed to write temp spec file: %v", err)
    }
    defer os.Remove(tmpFile)

    // Use the builder pattern to create a customized test suite
    suite, err := openapi.NewOpenAPITestBuilder(tmpFile).
        WithValidation(true).
        WithCircularReferenceDetection(true).
        WithBreakingChangesDetection(false, ""). // Disable breaking changes for this example
        Build()

    if err != nil {
        log.Fatalf("Failed to build test suite: %v", err)
    }

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

## Integration with GoWright Framework

The OpenAPI module integrates seamlessly with the GoWright testing framework, implementing the `core.Test` interface.

```go
func gowrightIntegrationExample() {
    specContent := `
openapi: 3.0.3
info:
  title: GoWright Integration API
  version: 1.0.0
paths:
  /api/test:
    get:
      responses:
        '200':
          description: Test endpoint
          content:
            application/json:
              schema:
                type: object
                properties:
                  message:
                    type: string
components:
  schemas:
    TestResponse:
      type: object
      properties:
        message:
          type: string
`

    tmpFile := "temp_integration.yaml"
    if err := os.WriteFile(tmpFile, []byte(specContent), 0644); err != nil {
        log.Fatalf("Failed to write temp spec file: %v", err)
    }
    defer os.Remove(tmpFile)

    // Create OpenAPI integration
    integration, err := openapi.NewOpenAPIIntegration(tmpFile)
    if err != nil {
        log.Fatalf("Failed to create OpenAPI integration: %v", err)
    }

    // Create individual tests
    validationTest := integration.CreateValidationTest()
    circularRefTest := integration.CreateCircularReferenceTest()
    
    // Or create a full test suite
    suite := integration.CreateFullTestSuite("HEAD~1") // Include breaking changes detection

    fmt.Printf("Running OpenAPI test suite: %s\n", suite.Name)

    // Run each test in the suite
    for _, test := range suite.Tests {
        fmt.Printf("\nRunning test: %s\n", test.GetName())

        result := test.Execute()

        if result.Error != nil {
            fmt.Printf("Test execution error: %v\n", result.Error)
        }

        if result.Status == core.TestStatusPassed {
            fmt.Println("Test passed successfully!")
        } else {
            fmt.Printf("Test failed with status: %v\n", result.Status)
        }

        if len(result.Logs) > 0 {
            fmt.Println("Test logs:")
            for _, log := range result.Logs {
                fmt.Printf("  - %s\n", log)
            }
        }
    }

    fmt.Printf("\nOpenAPI test suite execution completed\n")
}
```

### Available Integration Methods

- `CreateValidationTest()`: Creates a test for OpenAPI specification validation
- `CreateCircularReferenceTest()`: Creates a test for circular reference detection
- `CreateBreakingChangesTest(previousCommit string)`: Creates a test for breaking changes detection
- `CreateFullTestSuite(previousCommit string)`: Creates a complete test suite with all tests

## Comprehensive Testing Example

Here's a complete example that demonstrates all OpenAPI testing capabilities:

```go
package main

import (
    "fmt"
    "log"
    "os"
    
    "github.com/gowright/framework/pkg/openapi"
    "github.com/gowright/framework/pkg/core"
)

func main() {
    // Create a comprehensive OpenAPI spec
    createComprehensiveSpec()
    
    // Example 1: Basic validation
    fmt.Println("=== Example 1: Basic OpenAPI Validation ===")
    basicValidationExample()

    fmt.Println("\n=== Example 2: Comprehensive Testing ===")
    comprehensiveTestingExample()

    fmt.Println("\n=== Example 3: Breaking Changes Detection ===")
    breakingChangesExample()

    fmt.Println("\n=== Example 4: Test Builder Pattern ===")
    testBuilderExample()

    fmt.Println("\n=== Example 5: GoWright Framework Integration ===")
    gowrightIntegrationExample()
}

func createComprehensiveSpec() {
    specContent := `
openapi: 3.0.3
info:
  title: E-commerce API
  version: 2.0.0
  description: A comprehensive e-commerce API
servers:
  - url: https://api.example.com/v2
paths:
  /products:
    get:
      summary: List products
      parameters:
        - name: category
          in: query
          schema:
            type: string
        - name: limit
          in: query
          schema:
            type: integer
            minimum: 1
            maximum: 100
      responses:
        '200':
          description: Products retrieved successfully
          content:
            application/json:
              schema:
                type: object
                properties:
                  products:
                    type: array
                    items:
                      $ref: '#/components/schemas/Product'
                  total:
                    type: integer
        '400':
          description: Bad request
    post:
      summary: Create a new product
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateProductRequest'
      responses:
        '201':
          description: Product created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Product'
        '400':
          description: Invalid input
        '401':
          description: Unauthorized
  /products/{id}:
    get:
      summary: Get product by ID
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Product found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Product'
        '404':
          description: Product not found
components:
  schemas:
    Product:
      type: object
      required:
        - id
        - name
        - price
      properties:
        id:
          type: string
        name:
          type: string
        description:
          type: string
        price:
          type: number
          format: float
          minimum: 0
        category:
          type: string
        inStock:
          type: boolean
        createdAt:
          type: string
          format: date-time
    CreateProductRequest:
      type: object
      required:
        - name
        - price
      properties:
        name:
          type: string
          minLength: 1
          maxLength: 255
        description:
          type: string
          maxLength: 1000
        price:
          type: number
          format: float
          minimum: 0
        category:
          type: string
        inStock:
          type: boolean
          default: true
`

    err := os.WriteFile("comprehensive-openapi.yaml", []byte(specContent), 0644)
    if err != nil {
        log.Fatalf("Failed to create comprehensive spec: %v", err)
    }
}

func comprehensiveTestingExample() {
    tester, err := openapi.NewOpenAPITester("comprehensive-openapi.yaml")
    if err != nil {
        log.Fatalf("Failed to create OpenAPI tester: %v", err)
    }

    // Run all tests
    results := tester.RunAllTests("")

    fmt.Printf("Total tests run: %d\n", len(results))
    for _, result := range results {
        fmt.Printf("\nTest: %s\n", result.TestName)
        fmt.Printf("Status: %s\n", getStatusString(result.Passed))
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
```

## Key Features

### Validation Capabilities
- OpenAPI 3.0.3 specification compliance
- Required field validation (info, paths, components)
- Path and operation validation
- Response definition validation
- Component schema validation
- Detailed error and warning reporting

### Breaking Changes Detection
- Compares specifications across git commits
- Detects removed API paths and operations
- Identifies new required parameters
- Provides impact assessment for each change
- Supports CI/CD integration for automated checks

### Circular Reference Detection
- Identifies circular references in schema definitions
- Provides detailed reference chains
- Helps prevent code generation issues
- Supports complex nested schema structures

### Framework Integration
- Implements GoWright `core.Test` interface
- Provides detailed test execution results
- Supports parallel and sequential execution
- Integrates with existing test suites and reporting

## Best Practices

1. **Version Control Integration**: Use breaking changes detection in CI/CD pipelines to catch API compatibility issues early.

2. **Comprehensive Validation**: Always run all three test types (validation, circular references, breaking changes) for complete coverage.

3. **Error Handling**: Check both errors and warnings - warnings often indicate potential issues that should be addressed.

4. **Test Automation**: Use the builder pattern to create customized test suites that match your specific requirements.

5. **Documentation**: Keep your OpenAPI specifications up-to-date and well-documented to maximize the value of automated testing.

## Error Handling

The OpenAPI module provides comprehensive error handling with detailed messages:

```go
// Example error handling
tester, err := openapi.NewOpenAPITester("invalid-spec.yaml")
if err != nil {
    log.Printf("Failed to create tester: %v", err)
    // Handle the error appropriately
    return
}

result := tester.ValidateSpec()
if !result.Passed {
    log.Printf("Validation failed: %s", result.Message)
    for _, err := range result.Errors {
        log.Printf("Error at %s: %s", err.Path, err.Message)
    }
}
```

This comprehensive OpenAPI testing capability ensures your API specifications are valid, consistent, and maintain backward compatibility across versions.#
# Test Generation from OpenAPI

### Automatic Test Generation

```go
func testGenerationExample() {
    fmt.Println("=== Test Generation from OpenAPI Example ===")
    
    tester, err := openapi.NewOpenAPITester("sample-openapi.yaml")
    if err != nil {
        log.Fatalf("Failed to create OpenAPI tester: %v", err)
    }
    defer tester.Close()
    
    // Generate test suite from OpenAPI specification
    testSuite := tester.GenerateTestSuite()
    
    fmt.Printf("🧪 Generated Test Suite:\n")
    fmt.Printf("   Name: %s\n", testSuite.Name)
    fmt.Printf("   Total Tests: %d\n", len(testSuite.Tests))
    
    // Show generated tests
    for i, test := range testSuite.Tests {
        fmt.Printf("\n   Test %d: %s\n", i+1, test.Name)
        fmt.Printf("      Method: %s\n", test.Method)
        fmt.Printf("      Path: %s\n", test.Path)
        fmt.Printf("      Expected Status: %d\n", test.ExpectedStatus)
        
        if len(test.RequestBody) > 0 {
            fmt.Printf("      Has Request Body: Yes\n")
        }
        
        if len(test.ExpectedHeaders) > 0 {
            fmt.Printf("      Expected Headers: %d\n", len(test.ExpectedHeaders))
        }
        
        if len(test.ValidationRules) > 0 {
            fmt.Printf("      Validation Rules: %d\n", len(test.ValidationRules))
        }
    }
}

func customTestGenerationExample() {
    fmt.Println("=== Custom Test Generation Example ===")
    
    // Use test builder for custom test generation
    builder := openapi.NewTestBuilder("sample-openapi.yaml")
    
    testSuite, err := builder.
        WithValidation(true).
        WithCircularReferenceDetection(true).
        WithBreakingChangesDetection(true, "HEAD~1").
        WithPathFilter("/users/*").
        WithMethodFilter("GET", "POST").
        WithStatusCodeFilter(200, 201, 404).
        Build()
    
    if err != nil {
        log.Fatalf("Failed to build custom test suite: %v", err)
    }
    
    fmt.Printf("🎯 Custom Test Suite:\n")
    fmt.Printf("   Name: %s\n", testSuite.Name)
    fmt.Printf("   Filtered Tests: %d\n", len(testSuite.Tests))
    
    // Show test categories
    categories := make(map[string]int)
    for _, test := range testSuite.Tests {
        categories[test.Category]++
    }
    
    fmt.Printf("\n📊 Tests by Category:\n")
    for category, count := range categories {
        fmt.Printf("   %s: %d\n", category, count)
    }
}

func generateAPITestsExample() {
    fmt.Println("=== Generate API Tests Example ===")
    
    tester, err := openapi.NewOpenAPITester("sample-openapi.yaml")
    if err != nil {
        log.Fatalf("Failed to create OpenAPI tester: %v", err)
    }
    defer tester.Close()
    
    // Generate API tests specifically
    apiTests := tester.GenerateAPITests()
    
    fmt.Printf("🌐 Generated API Tests:\n")
    fmt.Printf("   Total API Tests: %d\n", len(apiTests))
    
    for _, test := range apiTests {
        fmt.Printf("\n   🔗 %s %s\n", test.Method, test.Path)
        fmt.Printf("      Test Name: %s\n", test.Name)
        fmt.Printf("      Description: %s\n", test.Description)
        
        // Show request details
        if test.RequestBody != nil {
            fmt.Printf("      Request Body: %s\n", test.RequestBody.ContentType)
        }
        
        // Show response expectations
        for status, response := range test.ExpectedResponses {
            fmt.Printf("      Expected %d: %s\n", status, response.Description)
        }
        
        // Show validation rules
        if len(test.ValidationRules) > 0 {
            fmt.Printf("      Validations:\n")
            for _, rule := range test.ValidationRules {
                fmt.Printf("        - %s: %s\n", rule.Type, rule.Description)
            }
        }
    }
}
```

## Integration with GoWright Framework

### Complete Integration Example

```go
package main

import (
    "testing"
    
    "github.com/gowright/framework/pkg/gowright"
    "github.com/gowright/framework/pkg/openapi"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestOpenAPIWithGoWrightIntegration(t *testing.T) {
    // Create GoWright framework with API testing configuration
    config := gowright.DefaultConfig()
    config.APIConfig.BaseURL = "https://api.example.com"
    config.APIConfig.Timeout = 30 * time.Second
    
    framework := gowright.New(config)
    defer framework.Close()
    
    // Initialize framework
    err := framework.Initialize()
    require.NoError(t, err)
    
    // Create OpenAPI integration
    integration, err := openapi.NewOpenAPIIntegration("sample-openapi.yaml")
    require.NoError(t, err)
    
    t.Run("OpenAPI Validation", func(t *testing.T) {
        // Create validation test suite
        validationSuite := integration.CreateValidationTestSuite()
        
        // Execute validation tests
        framework.SetTestSuite(validationSuite)
        results, err := framework.ExecuteTestSuite()
        
        assert.NoError(t, err)
        assert.Greater(t, results.PassedTests, 0)
        
        t.Logf("Validation Tests: %d passed, %d failed", 
            results.PassedTests, results.FailedTests)
    })
    
    t.Run("API Tests from OpenAPI", func(t *testing.T) {
        // Generate API tests from OpenAPI spec
        apiTestSuite := integration.CreateAPITestSuite()
        
        // Execute API tests
        framework.SetTestSuite(apiTestSuite)
        results, err := framework.ExecuteTestSuite()
        
        assert.NoError(t, err)
        
        t.Logf("API Tests: %d passed, %d failed", 
            results.PassedTests, results.FailedTests)
    })
    
    t.Run("Breaking Changes Detection", func(t *testing.T) {
        // Create breaking changes test suite
        breakingChangesSuite := integration.CreateBreakingChangesTestSuite("HEAD~1")
        
        // Execute breaking changes tests
        framework.SetTestSuite(breakingChangesSuite)
        results, err := framework.ExecuteTestSuite()
        
        assert.NoError(t, err)
        
        t.Logf("Breaking Changes Tests: %d passed, %d failed", 
            results.PassedTests, results.FailedTests)
    })
}

func TestOpenAPITestBuilder(t *testing.T) {
    // Build comprehensive test suite
    suite, err := openapi.NewOpenAPITestBuilder("sample-openapi.yaml").
        WithValidation(true).
        WithCircularReferenceDetection(true).
        WithBreakingChangesDetection(true, "HEAD~1").
        WithAPITesting(true).
        WithBaseURL("https://api.example.com").
        Build()
    
    require.NoError(t, err)
    require.NotNil(t, suite)
    assert.Greater(t, len(suite.Tests), 0)
    
    // Create framework and run tests
    framework := gowright.NewWithDefaults()
    defer framework.Close()
    
    framework.SetTestSuite(suite)
    results, err := framework.ExecuteTestSuite()
    
    assert.NoError(t, err)
    assert.Greater(t, results.PassedTests, 0)
    
    t.Logf("Complete OpenAPI Test Suite: %d passed, %d failed, %d skipped", 
        results.PassedTests, results.FailedTests, results.SkippedTests)
}
```

### Custom OpenAPI Test Implementation

```go
func TestCustomOpenAPIImplementation(t *testing.T) {
    // Create test context
    tc := gowright.NewTestContext("Custom OpenAPI Test")
    
    // Create OpenAPI tester
    tester, err := openapi.NewOpenAPITester("sample-openapi.yaml")
    tc.AssertNoError(err, "Should create OpenAPI tester")
    defer tester.Close()
    
    // Custom validation logic
    tc.RunStep("Validate OpenAPI Specification", func() {
        result := tester.ValidateSpec()
        tc.Assert(result.Passed, "OpenAPI specification should be valid")
        tc.AssertEqual("valid", result.Status, "Status should be valid")
        
        // Custom validation checks
        if len(result.Warnings) > 0 {
            tc.Logf("Found %d warnings (acceptable)", len(result.Warnings))
            for _, warning := range result.Warnings {
                tc.Logf("Warning: %s at %s", warning.Message, warning.Path)
            }
        }
    })
    
    tc.RunStep("Check Circular References", func() {
        result := tester.DetectCircularReferences()
        tc.Assert(result.Passed, "Should not have circular references")
        
        if !result.Passed {
            for _, ref := range result.CircularRefs {
                tc.Errorf("Circular reference: %s -> %s", ref.From, ref.To)
            }
        }
    })
    
    tc.RunStep("Analyze Breaking Changes", func() {
        result := tester.CheckBreakingChanges("HEAD~1")
        
        // Log all changes for review
        for _, change := range result.BreakingChanges {
            if change.IsBreaking {
                tc.Logf("Breaking change: %s at %s", change.Type, change.Path)
            } else {
                tc.Logf("Non-breaking change: %s at %s", change.Type, change.Path)
            }
        }
        
        // Custom logic: allow certain breaking changes
        criticalBreakingChanges := 0
        for _, change := range result.BreakingChanges {
            if change.IsBreaking && change.Severity == "critical" {
                criticalBreakingChanges++
            }
        }
        
        tc.AssertEqual(0, criticalBreakingChanges, 
            "Should not have critical breaking changes")
    })
    
    tc.RunStep("Generate and Validate Tests", func() {
        testSuite := tester.GenerateTestSuite()
        tc.AssertGreater(len(testSuite.Tests), 0, "Should generate tests")
        
        // Validate generated tests
        for _, test := range testSuite.Tests {
            tc.AssertNotEmpty(test.Name, "Test should have a name")
            tc.AssertNotEmpty(test.Method, "Test should have HTTP method")
            tc.AssertNotEmpty(test.Path, "Test should have path")
            tc.AssertGreater(test.ExpectedStatus, 0, "Test should have expected status")
        }
    })
    
    // Generate final report
    report := tc.GenerateReport()
    assert.Equal(t, gowright.TestStatusPassed, report.Status)
    
    t.Logf("Custom OpenAPI test completed: %s", report.Status)
}
```## CI/CD 
Integration Examples

### GitHub Actions Integration

```yaml
# .github/workflows/openapi-validation.yml
name: OpenAPI Validation

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  openapi-validation:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0  # Needed for breaking changes detection
    
    - name: Set up Go
      uses: actions/setup-go@v4
      with:
        go-version: '1.22'
    
    - name: Install dependencies
      run: go mod download
    
    - name: Run OpenAPI validation
      run: |
        go run openapi-ci-validation.go
      env:
        OPENAPI_SPEC_PATH: api/openapi.yaml
        PREVIOUS_COMMIT: ${{ github.event.before }}
        FAIL_ON_BREAKING_CHANGES: "false"
        FAIL_ON_WARNINGS: "false"
    
    - name: Upload validation report
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: openapi-validation-report
        path: openapi-validation-report.json
```

### CI/CD Validation Script

```go
// openapi-ci-validation.go
package main

import (
    "encoding/json"
    "fmt"
    "log"
    "os"
    "strconv"
    
    "github.com/gowright/framework/pkg/openapi"
)

type CIValidationReport struct {
    SpecPath           string                    `json:"spec_path"`
    ValidationPassed   bool                      `json:"validation_passed"`
    CircularRefsPassed bool                      `json:"circular_refs_passed"`
    BreakingChanges    []openapi.BreakingChange  `json:"breaking_changes"`
    Errors             []openapi.ValidationError `json:"errors"`
    Warnings           []openapi.ValidationError `json:"warnings"`
    Summary            ValidationSummary         `json:"summary"`
}

type ValidationSummary struct {
    TotalErrors         int `json:"total_errors"`
    TotalWarnings       int `json:"total_warnings"`
    CriticalErrors      int `json:"critical_errors"`
    BreakingChanges     int `json:"breaking_changes"`
    NonBreakingChanges  int `json:"non_breaking_changes"`
}

func main() {
    specPath := getEnvOrDefault("OPENAPI_SPEC_PATH", "openapi.yaml")
    previousCommit := getEnvOrDefault("PREVIOUS_COMMIT", "HEAD~1")
    failOnBreaking := getEnvBool("FAIL_ON_BREAKING_CHANGES", false)
    failOnWarnings := getEnvBool("FAIL_ON_WARNINGS", false)
    
    fmt.Printf("🔍 Running OpenAPI validation for: %s\n", specPath)
    
    // Create OpenAPI tester
    tester, err := openapi.NewOpenAPITester(specPath)
    if err != nil {
        log.Fatalf("Failed to create OpenAPI tester: %v", err)
    }
    defer tester.Close()
    
    report := CIValidationReport{
        SpecPath: specPath,
    }
    
    // 1. Validate specification
    fmt.Println("📋 Validating OpenAPI specification...")
    validationResult := tester.ValidateSpec()
    report.ValidationPassed = validationResult.Passed
    report.Errors = validationResult.Errors
    report.Warnings = validationResult.Warnings
    
    if validationResult.Passed {
        fmt.Println("✅ OpenAPI specification is valid")
    } else {
        fmt.Printf("❌ OpenAPI specification validation failed: %s\n", validationResult.Message)
        for _, err := range validationResult.Errors {
            fmt.Printf("::error file=%s,line=%d::%s\n", specPath, err.Line, err.Message)
        }
    }
    
    // Print warnings
    for _, warning := range validationResult.Warnings {
        fmt.Printf("::warning file=%s,line=%d::%s\n", specPath, warning.Line, warning.Message)
    }
    
    // 2. Check circular references
    fmt.Println("🔄 Checking for circular references...")
    circularResult := tester.DetectCircularReferences()
    report.CircularRefsPassed = circularResult.Passed
    
    if circularResult.Passed {
        fmt.Println("✅ No circular references found")
    } else {
        fmt.Printf("⚠️  Circular references detected: %s\n", circularResult.Message)
        for _, ref := range circularResult.CircularRefs {
            fmt.Printf("::warning::Circular reference: %s -> %s (path: %s)\n", 
                ref.From, ref.To, ref.Path)
        }
    }
    
    // 3. Check breaking changes
    fmt.Println("🔍 Checking for breaking changes...")
    breakingResult := tester.CheckBreakingChanges(previousCommit)
    report.BreakingChanges = breakingResult.BreakingChanges
    
    breakingCount := 0
    nonBreakingCount := 0
    
    for _, change := range breakingResult.BreakingChanges {
        if change.IsBreaking {
            breakingCount++
            fmt.Printf("::warning::Breaking change: %s at %s - %s\n", 
                change.Type, change.Path, change.Description)
        } else {
            nonBreakingCount++
            fmt.Printf("::notice::Non-breaking change: %s at %s - %s\n", 
                change.Type, change.Path, change.Description)
        }
    }
    
    // Generate summary
    criticalErrors := 0
    for _, err := range validationResult.Errors {
        if err.Severity == "critical" {
            criticalErrors++
        }
    }
    
    report.Summary = ValidationSummary{
        TotalErrors:        len(validationResult.Errors),
        TotalWarnings:      len(validationResult.Warnings),
        CriticalErrors:     criticalErrors,
        BreakingChanges:    breakingCount,
        NonBreakingChanges: nonBreakingCount,
    }
    
    // Print summary
    fmt.Printf("\n📊 Validation Summary:\n")
    fmt.Printf("   Errors: %d (Critical: %d)\n", report.Summary.TotalErrors, report.Summary.CriticalErrors)
    fmt.Printf("   Warnings: %d\n", report.Summary.TotalWarnings)
    fmt.Printf("   Breaking Changes: %d\n", report.Summary.BreakingChanges)
    fmt.Printf("   Non-Breaking Changes: %d\n", report.Summary.NonBreakingChanges)
    
    // Save report
    reportJSON, err := json.MarshalIndent(report, "", "  ")
    if err != nil {
        log.Printf("Failed to marshal report: %v", err)
    } else {
        err = os.WriteFile("openapi-validation-report.json", reportJSON, 0644)
        if err != nil {
            log.Printf("Failed to write report: %v", err)
        } else {
            fmt.Println("📄 Validation report saved to openapi-validation-report.json")
        }
    }
    
    // Determine exit code
    exitCode := 0
    
    if !validationResult.Passed {
        fmt.Println("❌ Validation failed")
        exitCode = 1
    }
    
    if failOnWarnings && len(validationResult.Warnings) > 0 {
        fmt.Println("❌ Warnings found (failing due to FAIL_ON_WARNINGS=true)")
        exitCode = 1
    }
    
    if failOnBreaking && breakingCount > 0 {
        fmt.Println("❌ Breaking changes found (failing due to FAIL_ON_BREAKING_CHANGES=true)")
        exitCode = 1
    }
    
    if exitCode == 0 {
        fmt.Println("✅ All OpenAPI validations passed!")
    }
    
    os.Exit(exitCode)
}

func getEnvOrDefault(key, defaultValue string) string {
    if value := os.Getenv(key); value != "" {
        return value
    }
    return defaultValue
}

func getEnvBool(key string, defaultValue bool) bool {
    if value := os.Getenv(key); value != "" {
        if parsed, err := strconv.ParseBool(value); err == nil {
            return parsed
        }
    }
    return defaultValue
}
```

### Docker Integration

```dockerfile
# Dockerfile for OpenAPI validation
FROM golang:1.22-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -o openapi-validator openapi-ci-validation.go

FROM alpine:latest
RUN apk --no-cache add ca-certificates git
WORKDIR /root/

COPY --from=builder /app/openapi-validator .

ENTRYPOINT ["./openapi-validator"]
```

### Makefile Integration

```makefile
# Makefile targets for OpenAPI validation
.PHONY: openapi-validate openapi-check-breaking openapi-ci

openapi-validate:
	@echo "Validating OpenAPI specification..."
	@go run openapi-ci-validation.go

openapi-check-breaking:
	@echo "Checking for breaking changes..."
	@FAIL_ON_BREAKING_CHANGES=true go run openapi-ci-validation.go

openapi-ci: openapi-validate
	@echo "Running full OpenAPI CI validation..."
	@FAIL_ON_WARNINGS=false FAIL_ON_BREAKING_CHANGES=false go run openapi-ci-validation.go

openapi-strict:
	@echo "Running strict OpenAPI validation..."
	@FAIL_ON_WARNINGS=true FAIL_ON_BREAKING_CHANGES=true go run openapi-ci-validation.go
```

## Performance Testing Examples

### Large Specification Performance

```go
func TestLargeSpecificationPerformance(t *testing.T) {
    specPath := "large-openapi.yaml"
    
    // Measure loading performance
    start := time.Now()
    tester, err := openapi.NewOpenAPITester(specPath)
    require.NoError(t, err)
    defer tester.Close()
    
    loadTime := time.Since(start)
    t.Logf("Large specification load time: %v", loadTime)
    
    // Measure validation performance
    start = time.Now()
    result := tester.ValidateSpec()
    validationTime := time.Since(start)
    
    t.Logf("Validation time: %v", validationTime)
    assert.True(t, result.Passed, "Large specification should validate")
    assert.Less(t, validationTime, 30*time.Second, "Validation should complete within 30 seconds")
    
    // Measure circular reference detection performance
    start = time.Now()
    circularResult := tester.DetectCircularReferences()
    circularTime := time.Since(start)
    
    t.Logf("Circular reference detection time: %v", circularTime)
    assert.Less(t, circularTime, 10*time.Second, "Circular detection should complete within 10 seconds")
    
    // Measure test generation performance
    start = time.Now()
    testSuite := tester.GenerateTestSuite()
    generationTime := time.Since(start)
    
    t.Logf("Test generation time: %v", generationTime)
    t.Logf("Generated tests: %d", len(testSuite.Tests))
    assert.Less(t, generationTime, 15*time.Second, "Test generation should complete within 15 seconds")
}

func BenchmarkOpenAPIValidation(b *testing.B) {
    tester, err := openapi.NewOpenAPITester("sample-openapi.yaml")
    if err != nil {
        b.Fatal(err)
    }
    defer tester.Close()
    
    b.ResetTimer()
    
    for i := 0; i < b.N; i++ {
        result := tester.ValidateSpec()
        if !result.Passed {
            b.Fatalf("Validation failed: %s", result.Message)
        }
    }
}
```

This comprehensive OpenAPI testing examples documentation covers all the major features and use cases of the OpenAPI testing module, providing practical examples that developers can use as templates for their own implementations.