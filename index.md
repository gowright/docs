# Gowright Testing Framework

[![Go Version](https://img.shields.io/badge/Go-1.22+-blue.svg)](https://golang.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/gowright/framework/blob/main/LICENSE)
[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen.svg)]()
[![Documentation](https://img.shields.io/badge/docs-Docsify-blue)](https://gowright.github.io/framework/)

Gowright is a comprehensive testing platform for Go applications that provides unified testing capabilities across UI, API, mobile, database, and integration testing scenarios. The platform consists of four interconnected repositories working together to deliver a complete testing solution with AI-powered assistance through Model Context Protocol integration.

## ✨ Key Features

<div class="grid cards">

<div>

### 🌐 UI Testing
Browser automation using Chrome DevTools Protocol via [go-rod/rod](https://github.com/go-rod/rod)

</div>

<div>

### 📱 Mobile Testing
Comprehensive native mobile app automation using Appium WebDriver protocol for Android and iOS with advanced touch gestures, device management, mobile web testing, and cross-platform testing capabilities. Includes complete session management, screenshot capture, and seamless integration with GoWright test suites.

</div>

<div>

### 🔌 OpenAPI Testing
Complete OpenAPI specification validation, breaking changes detection, circular reference checking, and automated API testing based on OpenAPI definitions

</div>

<div>

### 🚀 API Testing
HTTP/REST API testing with [go-resty/resty](https://github.com/go-resty/resty/v2)

</div>

<div>

### 💾 Database Testing
Multi-database support with transaction management

</div>

<div>

### 🔗 Integration Testing
Complex workflows spanning multiple systems with visual flow diagrams and comprehensive orchestration

</div>

<div>

### 📊 Flexible Reporting
Local (JSON, HTML) and remote reporting (Jira Xray, AIOTest, Report Portal)

</div>

<div>

### 🧪 Testify Integration
Compatible with [stretchr/testify](https://github.com/stretchr/testify)

</div>

<div>

### ⚡ Parallel Execution
Concurrent test execution with resource management

</div>

<div>

### 🛡️ Error Recovery
Graceful error handling and retry mechanisms

</div>

<div>

### 🤖 AI-Powered Development
Model Context Protocol (MCP) integration for AI-assisted test generation, configuration, and project setup

</div>

<div>

### 🔌 Plugin System
Extensible plugin architecture for custom metrics, notifications, reporting, and business logic validation

</div>

<div>

### 🏗️ Microservices Testing
Specialized patterns for testing individual services, service interactions, and complex orchestration scenarios

</div>

</div>

## 🚀 Quick Start

### Installation

```bash
go get github.com/gowright/framework
```

### MCP Server Installation

For AI-assisted development, install the MCP server:

```bash
# Using uvx (recommended)
uvx gowright-mcp-server@latest

# Or install globally with npm
npm install -g gowright-mcp-server
```

### Basic Usage

```go
package main

import (
    "fmt"
    "time"
    
    "github.com/gowright/framework/pkg/gowright"
)

func main() {
    // Create framework with default configuration
    framework := gowright.NewWithDefaults()
    defer framework.Close()
    
    // Initialize the framework
    if err := framework.Initialize(); err != nil {
        panic(err)
    }
    
    fmt.Println("Gowright framework initialized successfully!")
}
```

## 📖 Documentation Sections

### Getting Started
- [Introduction](getting-started/introduction.md) - Overview and core concepts
- [Installation](getting-started/installation.md) - Setup and installation guide
- [Quick Start](getting-started/quick-start.md) - Get up and running quickly
- [Configuration](getting-started/configuration.md) - Configure Gowright for your needs

### Testing Modules
- [API Testing](testing-modules/api-testing.md) - REST API testing with validation
- [UI Testing](testing-modules/ui-testing.md) - Browser automation and UI testing
- [Mobile Testing](testing-modules/mobile-testing.md) - Native mobile app automation with Appium
- [OpenAPI Testing](testing-modules/openapi-testing.md) - OpenAPI specification validation and testing
- [Database Testing](testing-modules/database-testing.md) - Database operations and validation
- [Integration Testing](testing-modules/integration-testing.md) - Multi-system workflows
- [OpenAPI Testing](testing-modules/openapi-testing.md) - OpenAPI specification validation and testing

### Advanced Features
- [Architecture Overview](advanced/architecture.md) - Framework architecture and design patterns
- [Test Suites](advanced/test-suites.md) - Organizing and running test collections
- [Assertions](advanced/assertions.md) - Custom assertion system
- [Reporting](advanced/reporting.md) - Professional HTML and JSON reports
- [Parallel Execution](advanced/parallel-execution.md) - Concurrent test execution
- [Resource Management](advanced/resource-management.md) - Memory and CPU monitoring
- [Plugin Development](advanced/plugin-development.md) - Extensible plugin system for custom functionality
- [MCP Integration](advanced/mcp-integration.md) - AI-assisted development with Model Context Protocol

### Examples
- [Running Examples](examples/running-examples.md) - Enhanced example execution system with comprehensive reporting
- [Getting Started Examples](examples/getting-started.md) - Foundation examples for new users (3/3 - 100% complete) ✅
- [Basic Usage](examples/basic-usage.md) - Framework initialization and configuration patterns
- [API Testing Examples](examples/api-testing.md) - Comprehensive REST API testing scenarios (5/8 - 63% complete)
- [UI Testing Examples](examples/ui-testing.md) - Browser automation and UI testing (6/9 - 67% complete)
- [Mobile Testing Examples](examples/mobile-testing.md) - Native mobile app automation (1/5 - 20% complete)
- [OpenAPI Testing Examples](examples/openapi-testing.md) - OpenAPI specification validation (0/3 - planned)
- [Database Examples](examples/database-testing.md) - Database testing patterns (2/7 - 29% complete)
- [Integration Examples](examples/integration-testing.md) - End-to-end workflows (1/4 - 25% complete)
- [Advanced Patterns](examples/advanced-patterns.md) - Enterprise testing patterns (4/5 - 80% complete)
- [Reporting Examples](examples/reporting.md) - Custom reporting and dashboards (3/3 - 100% complete) ✅
- [CI/CD Integration](examples/cicd.md) - Pipeline integration examples (0/3 - planned)
- [Modular Usage Examples](examples/modular-usage.md) - Framework modular architecture examples
- [Integration Flow Diagrams](examples/integration-flow-diagrams.md) - Visual integration patterns

**Total Progress: 28 examples created across 9 categories (85% of planned examples completed)**

### Reference
- [API Reference](reference/api.md) - Complete API documentation
- [Configuration Reference](reference/configuration.md) - All configuration options
- [Best Practices](reference/best-practices.md) - Recommended patterns
- [Troubleshooting](reference/troubleshooting.md) - Common issues and solutions
- [Migration Guide](reference/migration.md) - Migrating from other frameworks

## 🤝 Contributing

We welcome contributions! Please see our contributing documentation:

- [Development Setup](contributing/development.md) - Development environment setup
- [Contributing Guide](contributing/guide.md) - Contribution guidelines and process  
- [Deployment & CI/CD](contributing/deployment.md) - Automated deployment and publishing workflows
- [Changelog](contributing/changelog.md) - Version history and changes

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/gowright/framework/blob/main/LICENSE) file for details.

## 🙏 Acknowledgments

- [go-rod/rod](https://github.com/go-rod/rod) for browser automation
- [go-resty/resty](https://github.com/go-resty/resty) for HTTP client
- [stretchr/testify](https://github.com/stretchr/testify) for testing utilities

## 📞 Support

- 📖 [Documentation](https://gowright.github.io/framework/)
- 🐛 [Issue Tracker](https://github.com/gowright/framework/issues)
- 💬 [Discussions](https://github.com/gowright/framework/discussions)
- 📧 [Email Support](mailto:support@gowright.dev)

---

**Gowright** - Making Go testing comprehensive and enjoyable! 🚀