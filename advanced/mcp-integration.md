# MCP Integration - AI-Assisted Development

The Gowright platform includes comprehensive Model Context Protocol (MCP) integration, enabling AI-assisted test development, configuration generation, and project setup. This integration provides intelligent code generation and validation capabilities through a dedicated MCP server.

## Table of Contents

1. [Overview](#overview)
2. [Installation and Setup](#installation-and-setup)
3. [Available Tools](#available-tools)
4. [Configuration](#configuration)
5. [Usage Examples](#usage-examples)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)

## Overview

The Gowright MCP server provides AI assistants with the ability to:

- **Generate test code** for all supported testing types (API, UI, Mobile, Database, Integration, OpenAPI)
- **Execute tests** with various configurations and options
- **Generate configuration files** for different scenarios and environments
- **Validate OpenAPI specifications** and detect breaking changes
- **Initialize new projects** with Gowright framework setup

### Architecture

```mermaid
graph TB
    AI[AI Assistant] --> MCP[MCP Server]
    MCP --> Tools[MCP Tools]
    
    subgraph "MCP Tools"
        GT[generate_test]
        RT[run_test]
        GC[generate_config]
        VO[validate_openapi]
        SP[setup_project]
    end
    
    Tools --> Framework[Gowright Framework]
    Framework --> TestTypes[Test Types]
    
    subgraph "Test Types"
        API[API Testing]
        UI[UI Testing]
        Mobile[Mobile Testing]
        DB[Database Testing]
        Integration[Integration Testing]
        OpenAPI[OpenAPI Testing]
    end
```

## Installation and Setup

### Prerequisites

- **Node.js 18+** for the MCP server
- **Python with uv/uvx** (recommended installation method)
- **Go 1.23+** for the Gowright framework

### Installation Methods

#### Method 1: Using uvx (Recommended)

```bash
# Install uv/uvx if not already installed
curl -LsSf https://astral.sh/uv/install.sh | sh

# Run the MCP server
uvx gowright-mcp-server@latest
```

#### Method 2: Using npm

```bash
# Install globally
npm install -g gowright-mcp-server

# Run the server
gowright-mcp-server
```

#### Method 3: From Source

```bash
# Clone the repository
git clone https://github.com/gowright/mcpserver.git
cd mcpserver

# Install dependencies
npm install

# Build the server
npm run build

# Run the server
npm start
```

### MCP Configuration

Configure the MCP server in your AI assistant's MCP configuration file:

#### Workspace Configuration (`.kiro/settings/mcp.json`)

```json
{
  "mcpServers": {
    "gowright": {
      "command": "uvx",
      "args": ["gowright-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR"
      },
      "disabled": false,
      "autoApprove": [
        "generate_test",
        "generate_config",
        "validate_openapi"
      ]
    }
  }
}
```

#### User-Level Configuration (`~/.kiro/settings/mcp.json`)

```json
{
  "mcpServers": {
    "gowright-global": {
      "command": "uvx",
      "args": ["gowright-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "INFO",
        "GOWRIGHT_DEFAULT_CONFIG": "~/.gowright/config.json"
      },
      "disabled": false,
      "autoApprove": []
    }
  }
}
```

## Available Tools

### 1. generate_test

Generates test code for various testing scenarios.

**Parameters:**
- `test_type` (required): Type of test to generate (api, ui, mobile, database, integration, openapi)
- `test_name` (required): Name for the generated test
- `description` (optional): Description of what the test should do
- `config` (optional): Specific configuration for the test

**Example Usage:**

```typescript
// Generate API test
const apiTest = await mcp.call('generate_test', {
  test_type: 'api',
  test_name: 'TestUserAPI',
  description: 'Test user CRUD operations',
  config: {
    base_url: 'https://api.example.com',
    endpoints: ['/users', '/users/{id}']
  }
});

// Generate mobile test
const mobileTest = await mcp.call('generate_test', {
  test_type: 'mobile',
  test_name: 'TestLoginFlow',
  description: 'Test mobile app login functionality',
  config: {
    platform: 'android',
    app_package: 'com.example.app'
  }
});
```

### 2. run_test

Executes tests with specified configurations.

**Parameters:**
- `test_file` (required): Path to the test file to execute
- `test_function` (optional): Specific test function to run
- `config_file` (optional): Configuration file to use
- `parallel` (optional): Whether to run tests in parallel
- `verbose` (optional): Enable verbose output

**Example Usage:**

```typescript
// Run specific test
const result = await mcp.call('run_test', {
  test_file: './tests/api_test.go',
  test_function: 'TestUserAPI',
  config_file: './gowright-config.json',
  verbose: true
});

// Run all tests in parallel
const parallelResult = await mcp.call('run_test', {
  test_file: './tests/',
  parallel: true,
  config_file: './config/test-config.json'
});
```

### 3. generate_config

Generates configuration files for different scenarios.

**Parameters:**
- `config_type` (required): Type of configuration (basic, advanced, ci, mobile, openapi)
- `output_file` (optional): Output file path
- `environment` (optional): Target environment (development, staging, production)
- `features` (optional): List of features to enable

**Example Usage:**

```typescript
// Generate basic configuration
const basicConfig = await mcp.call('generate_config', {
  config_type: 'basic',
  output_file: './gowright-config.json',
  environment: 'development'
});

// Generate CI configuration
const ciConfig = await mcp.call('generate_config', {
  config_type: 'ci',
  output_file: './ci-config.json',
  features: ['parallel', 'reporting', 'screenshots']
});

// Generate mobile testing configuration
const mobileConfig = await mcp.call('generate_config', {
  config_type: 'mobile',
  environment: 'testing',
  features: ['android', 'ios', 'gestures']
});
```

### 4. validate_openapi

Validates OpenAPI specifications and detects issues.

**Parameters:**
- `spec_path` (required): Path to the OpenAPI specification file
- `check_breaking_changes` (optional): Whether to check for breaking changes
- `previous_commit` (optional): Git commit to compare against for breaking changes
- `fail_on_warnings` (optional): Whether to fail on warnings

**Example Usage:**

```typescript
// Basic validation
const validation = await mcp.call('validate_openapi', {
  spec_path: './api/openapi.yaml'
});

// Validation with breaking change detection
const breakingChanges = await mcp.call('validate_openapi', {
  spec_path: './api/openapi.yaml',
  check_breaking_changes: true,
  previous_commit: 'HEAD~1',
  fail_on_warnings: false
});
```

### 5. setup_project

Initializes a new Go project with Gowright framework.

**Parameters:**
- `project_name` (required): Name of the project
- `project_path` (optional): Path where to create the project
- `features` (optional): List of features to include
- `template` (optional): Project template to use

**Example Usage:**

```typescript
// Basic project setup
const project = await mcp.call('setup_project', {
  project_name: 'my-test-project',
  project_path: './projects/my-test-project'
});

// Advanced project setup
const advancedProject = await mcp.call('setup_project', {
  project_name: 'comprehensive-testing',
  features: ['api', 'ui', 'mobile', 'database', 'openapi'],
  template: 'enterprise'
});
```

## Configuration

### Environment Variables

The MCP server supports several environment variables for configuration:

```bash
# Logging level
export FASTMCP_LOG_LEVEL=INFO

# Default configuration file
export GOWRIGHT_DEFAULT_CONFIG=/path/to/config.json

# Default project template
export GOWRIGHT_DEFAULT_TEMPLATE=basic

# Appium server URL for mobile testing
export APPIUM_SERVER_URL=http://localhost:4723

# Database connection for testing
export TEST_DATABASE_URL=postgres://user:pass@localhost/testdb
```

### Server Configuration

The MCP server can be configured through a configuration file:

```json
{
  "server": {
    "name": "gowright-mcp-server",
    "version": "1.0.0",
    "port": 3000
  },
  "tools": {
    "generate_test": {
      "enabled": true,
      "templates_path": "./templates",
      "output_path": "./generated"
    },
    "run_test": {
      "enabled": true,
      "default_timeout": "30s",
      "max_parallel": 4
    },
    "generate_config": {
      "enabled": true,
      "templates_path": "./config-templates"
    },
    "validate_openapi": {
      "enabled": true,
      "strict_mode": false
    },
    "setup_project": {
      "enabled": true,
      "templates_path": "./project-templates"
    }
  },
  "defaults": {
    "go_version": "1.23",
    "framework_version": "latest",
    "test_timeout": "30s"
  }
}
```

## Usage Examples

### AI-Assisted Test Generation

```markdown
**User**: Generate a comprehensive API test for a user management system with CRUD operations

**AI with MCP**: I'll generate a comprehensive API test for user management with CRUD operations.
```

The AI assistant will use the MCP server to generate:

```go
package main

import (
    "net/http"
    "testing"
    "time"
    
    "github.com/gowright/framework/pkg/gowright"
    "github.com/stretchr/testify/assert"
)

func TestUserManagementAPI(t *testing.T) {
    // Initialize API tester
    config := &gowright.APIConfig{
        BaseURL: "https://api.example.com",
        Timeout: 30 * time.Second,
        Headers: map[string]string{
            "Content-Type": "application/json",
            "Accept":       "application/json",
        },
    }
    
    apiTester := gowright.NewAPITester(config)
    err := apiTester.Initialize(config)
    assert.NoError(t, err)
    defer apiTester.Cleanup()
    
    // Test user creation
    t.Run("CreateUser", func(t *testing.T) {
        userData := map[string]interface{}{
            "name":  "John Doe",
            "email": "john.doe@example.com",
            "role":  "user",
        }
        
        response, err := apiTester.Post("/users", userData)
        assert.NoError(t, err)
        assert.Equal(t, http.StatusCreated, response.StatusCode)
        
        // Validate response structure
        assert.Contains(t, response.Body, "id")
        assert.Contains(t, response.Body, "name")
        assert.Contains(t, response.Body, "email")
    })
    
    // Test user retrieval
    t.Run("GetUser", func(t *testing.T) {
        response, err := apiTester.Get("/users/1", nil)
        assert.NoError(t, err)
        assert.Equal(t, http.StatusOK, response.StatusCode)
        
        // Validate user data
        user := response.JSON()
        assert.Equal(t, "John Doe", user["name"])
        assert.Equal(t, "john.doe@example.com", user["email"])
    })
    
    // Test user update
    t.Run("UpdateUser", func(t *testing.T) {
        updateData := map[string]interface{}{
            "name": "John Smith",
            "role": "admin",
        }
        
        response, err := apiTester.Put("/users/1", updateData)
        assert.NoError(t, err)
        assert.Equal(t, http.StatusOK, response.StatusCode)
        
        // Verify update
        updatedUser := response.JSON()
        assert.Equal(t, "John Smith", updatedUser["name"])
        assert.Equal(t, "admin", updatedUser["role"])
    })
    
    // Test user deletion
    t.Run("DeleteUser", func(t *testing.T) {
        response, err := apiTester.Delete("/users/1", nil)
        assert.NoError(t, err)
        assert.Equal(t, http.StatusNoContent, response.StatusCode)
        
        // Verify deletion
        getResponse, err := apiTester.Get("/users/1", nil)
        assert.NoError(t, err)
        assert.Equal(t, http.StatusNotFound, getResponse.StatusCode)
    })
}
```

### Configuration Generation

```markdown
**User**: Generate a configuration for mobile testing with both Android and iOS support

**AI with MCP**: I'll generate a comprehensive mobile testing configuration for both Android and iOS.
```

Generated configuration:

```json
{
  "log_level": "info",
  "parallel": true,
  "max_retries": 3,
  "appium_config": {
    "server_url": "http://localhost:4723",
    "timeout": "30s",
    "default_capabilities": {
      "newCommandTimeout": 60,
      "noReset": true,
      "fullReset": false,
      "autoAcceptAlerts": true,
      "autoDismissAlerts": true
    },
    "android_capabilities": {
      "platformName": "Android",
      "automationName": "UiAutomator2",
      "deviceName": "Android Emulator",
      "platformVersion": "11.0",
      "appPackage": "com.example.app",
      "appActivity": ".MainActivity",
      "autoGrantPermissions": true,
      "ignoreHiddenApiPolicyError": true
    },
    "ios_capabilities": {
      "platformName": "iOS",
      "automationName": "XCUITest",
      "deviceName": "iPhone 13 Simulator",
      "platformVersion": "15.0",
      "bundleId": "com.example.app",
      "autoAcceptAlerts": true,
      "autoDismissAlerts": true,
      "shouldUseSingletonTestManager": false
    }
  },
  "report_config": {
    "local_reports": {
      "json": true,
      "html": true,
      "output_dir": "./mobile-test-reports"
    },
    "screenshots": {
      "enabled": true,
      "on_failure": true,
      "output_dir": "./screenshots"
    }
  },
  "parallel_runner_config": {
    "max_concurrency": 2,
    "resource_limits": {
      "max_memory_mb": 2048,
      "max_cpu_percent": 80
    }
  }
}
```

### OpenAPI Validation

```markdown
**User**: Validate my OpenAPI specification and check for breaking changes since the last commit

**AI with MCP**: I'll validate your OpenAPI specification and check for breaking changes.
```

The AI will use the MCP server to:

1. **Validate the specification** against OpenAPI 3.0.3 standards
2. **Check for circular references** in schema definitions
3. **Detect breaking changes** compared to the previous commit
4. **Generate a comprehensive report** with findings and recommendations

## Best Practices

### 1. Use Auto-Approval for Safe Operations

Configure auto-approval for operations that don't modify your codebase:

```json
{
  "autoApprove": [
    "generate_config",
    "validate_openapi"
  ]
}
```

### 2. Environment-Specific Configurations

Use different MCP configurations for different environments:

```json
{
  "mcpServers": {
    "gowright-dev": {
      "command": "uvx",
      "args": ["gowright-mcp-server@latest"],
      "env": {
        "GOWRIGHT_ENV": "development"
      }
    },
    "gowright-prod": {
      "command": "uvx",
      "args": ["gowright-mcp-server@stable"],
      "env": {
        "GOWRIGHT_ENV": "production"
      },
      "disabled": false
    }
  }
}
```

### 3. Version Pinning

Pin specific versions for production environments:

```json
{
  "command": "uvx",
  "args": ["gowright-mcp-server@1.2.3"]
}
```

### 4. Resource Management

Configure appropriate resource limits:

```json
{
  "env": {
    "FASTMCP_LOG_LEVEL": "ERROR",
    "NODE_OPTIONS": "--max-old-space-size=1024"
  }
}
```

### 5. Logging Configuration

Use appropriate logging levels:

- **ERROR**: Production environments
- **WARN**: Staging environments  
- **INFO**: Development environments
- **DEBUG**: Troubleshooting only

## Troubleshooting

### Common Issues

#### 1. MCP Server Not Starting

**Problem**: Server fails to start or connect

**Solutions**:
```bash
# Check if uvx is installed
uvx --version

# Install uv if missing
curl -LsSf https://astral.sh/uv/install.sh | sh

# Try running directly
uvx gowright-mcp-server@latest --version

# Check logs
export FASTMCP_LOG_LEVEL=DEBUG
uvx gowright-mcp-server@latest
```

#### 2. Tool Execution Failures

**Problem**: MCP tools fail to execute

**Solutions**:
```bash
# Check Go installation
go version

# Verify framework installation
go list -m github.com/gowright/framework

# Check permissions
ls -la ./test-files/

# Verify configuration
cat gowright-config.json | jq .
```

#### 3. Configuration Issues

**Problem**: MCP server not recognized by AI assistant

**Solutions**:
```bash
# Verify MCP configuration file location
ls -la .kiro/settings/mcp.json

# Check configuration syntax
cat .kiro/settings/mcp.json | jq .

# Restart AI assistant after configuration changes
```

#### 4. Performance Issues

**Problem**: Slow response times or high resource usage

**Solutions**:
```json
{
  "env": {
    "NODE_OPTIONS": "--max-old-space-size=512",
    "FASTMCP_LOG_LEVEL": "ERROR"
  }
}
```

### Debug Mode

Enable debug mode for troubleshooting:

```bash
export FASTMCP_LOG_LEVEL=DEBUG
export GOWRIGHT_DEBUG=true
uvx gowright-mcp-server@latest
```

### Health Checks

Verify MCP server health:

```bash
# Check if server is responding
curl -X POST http://localhost:3000/health

# Test tool availability
curl -X POST http://localhost:3000/tools

# Verify configuration
curl -X POST http://localhost:3000/config
```

## Advanced Configuration

### Custom Templates

Create custom templates for code generation:

```typescript
// templates/custom-api-test.ts
export const customAPITestTemplate = `
package {{packageName}}

import (
    "testing"
    "github.com/gowright/framework/pkg/gowright"
    "github.com/stretchr/testify/assert"
)

func {{testName}}(t *testing.T) {
    // Custom template implementation
    {{#each endpoints}}
    t.Run("{{method}} {{path}}", func(t *testing.T) {
        // Test implementation for {{method}} {{path}}
    })
    {{/each}}
}
`;
```

### Plugin System

Extend the MCP server with custom plugins:

```typescript
// plugins/custom-validator.ts
export class CustomValidator implements MCPPlugin {
    name = 'custom-validator';
    
    async execute(params: any): Promise<any> {
        // Custom validation logic
        return {
            valid: true,
            message: 'Custom validation passed'
        };
    }
}
```

### Integration with CI/CD

The MCP server includes automated GitHub Actions workflows for continuous integration and publishing.

#### GitHub Actions Workflows

The MCP server repository includes two main workflows:

**1. Continuous Integration (`ci.yml`)**
- Runs on every push and pull request to main/develop branches
- Tests build process across Node.js versions 18 and 20
- Validates TypeScript compilation and package integrity
- Runs automated tests when available

**2. Publishing (`publish.yml`)**
- Automatically publishes to npm when git tags starting with `v` are pushed
- Can be manually triggered via GitHub Actions UI with version bump selection
- Creates GitHub releases with installation instructions and MCP configuration examples

#### Setting Up GitHub Actions

To enable automated publishing for your MCP server fork:

1. **Add NPM Token Secret**:
   - Go to [npm.com](https://www.npmjs.com) → Account → Access Tokens
   - Create a new "Automation" token
   - Add it as `NPM_TOKEN` repository secret in GitHub

2. **Publishing Process**:
   ```bash
   # Automatic publishing (recommended)
   git tag v1.0.1
   git push origin v1.0.1
   
   # Manual publishing via GitHub Actions UI
   # Go to Actions → Publish MCP Server → Run workflow
   # Select version bump type (patch/minor/major)
   ```

#### Using MCP Server in CI/CD

Configure MCP server for CI/CD environments:

```yaml
# .github/workflows/test-with-mcp.yml
name: Test with MCP
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Go
        uses: actions/setup-go@v3
        with:
          go-version: '1.23'
          
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install MCP Server
        run: |
          curl -LsSf https://astral.sh/uv/install.sh | sh
          uvx gowright-mcp-server@latest --version
          
      - name: Generate Tests
        run: |
          uvx gowright-mcp-server@latest generate_test \
            --test_type=api \
            --test_name=TestCI \
            --config='{"base_url": "${{ secrets.API_BASE_URL }}"}'
            
      - name: Run Tests
        run: |
          uvx gowright-mcp-server@latest run_test \
            --test_file=./generated_test.go \
            --parallel=true
```

#### Local Testing Before Publishing

Before pushing tags, use the comprehensive local testing script:

```bash
cd mcpserver
./test-local.sh
```

This script replicates the entire CI/CD pipeline locally, including:
- Node.js version validation (18+ required)
- Build compilation and executable creation
- Build validation (verifies executable file exists and has proper permissions)
- TypeScript type checking and code formatting validation
- Test execution and coverage
- Package integrity verification
- MCP server functionality testing
- Code quality analysis and bundle size checks

For manual testing, you can run individual commands:

```bash
cd mcpserver
npm ci
npm run build
chmod +x dist/index.js

# Validate build output
if [ -f "dist/index.js" ] && [ -x "dist/index.js" ]; then
    echo "Build validation passed - executable created"
else
    echo "Build validation failed - executable not found or not executable"
    exit 1
fi

npm pack --dry-run
```

---

The MCP integration provides powerful AI-assisted development capabilities, making it easier to create, configure, and maintain comprehensive test suites. The combination of intelligent code generation and automated validation helps ensure high-quality testing implementations while reducing development time.