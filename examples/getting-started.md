# Getting Started Examples

This section contains the foundational examples for getting started with the Gowright testing framework. These examples are designed to help new users understand the basic concepts and get their first tests running quickly.

## 📁 Getting Started Examples (3/3 - 100% Complete)

### 🚀 Basic Usage (`getting-started/basic_usage.go`) ✅
Framework initialization and configuration fundamentals.

**Key Concepts Covered:**
- Framework initialization with default configuration
- Custom configuration setup
- Resource management basics
- Error handling patterns
- Environment variable handling
- Configuration file management

**Example Usage:**
```bash
go run examples/getting-started/basic_usage.go
```

### ⚙️ Configuration Examples (`getting-started/configuration_examples.go`) ✅
Advanced configuration patterns and environment-specific setups.

**Key Concepts Covered:**
- Environment-based configuration
- Configuration file loading
- Environment variable overrides
- Multi-environment setup patterns
- Configuration validation
- Runtime configuration updates

**Example Usage:**
```bash
go run examples/getting-started/configuration_examples.go
```

### 🧪 First Test (`getting-started/first_test.go`) ✅
Your first complete Gowright test with assertions and reporting.

**Key Concepts Covered:**
- Complete beginner tutorial
- Test structure and organization
- Basic assertions with testify integration
- First API and UI tests
- Test reporting setup and generation
- Step-by-step guidance
- Best practices for test naming and organization

**Example Usage:**
```bash
go run examples/getting-started/first_test.go
```

## 🎯 Learning Objectives

After completing these getting started examples, you will understand:

1. **Framework Initialization**: How to properly initialize and configure the Gowright framework
2. **Configuration Management**: Different approaches to managing configuration across environments
3. **Test Structure**: How to structure your first test with proper setup and teardown
4. **Error Handling**: Basic error handling patterns and recovery mechanisms
5. **Resource Management**: Understanding framework resource usage and cleanup

## 🚀 Quick Start Guide

### Prerequisites
- Go 1.23.0+ installed
- Basic understanding of Go testing patterns
- Chrome/Chromium browser for UI testing examples

### Running Your First Example

1. **Clone the repository:**
   ```bash
   git clone https://github.com/gowright/framework
   cd framework
   ```

2. **Run all getting started examples:**
   ```bash
   # Run all examples with enhanced reporting
   ./examples/run_all_examples.sh
   
   # Or run just the getting-started category
   ./examples/run_category.sh getting-started
   ```

3. **Run individual examples:**
   ```bash
   # Basic usage example
   go run examples/getting-started/basic_usage.go
   
   # Configuration example
   go run examples/getting-started/configuration_examples.go
   
   # Your first test
   go run examples/getting-started/first_test.go
   ```

## 📋 Common Configuration Patterns

### Default Configuration
```go
framework := gowright.NewWithDefaults()
defer framework.Close()
```

### Custom Configuration
```go
config := &gowright.Config{
    LogLevel: "info",
    Parallel: true,
    MaxRetries: 3,
}
framework := gowright.New(config)
defer framework.Close()
```

### Environment-Based Configuration
```go
config, err := gowright.LoadConfigFromFile("config-" + os.Getenv("ENV") + ".json")
if err != nil {
    config = gowright.DefaultConfig()
}
framework := gowright.New(config)
defer framework.Close()
```

## 🔧 Troubleshooting

### Common Issues

**Framework initialization fails:**
- Ensure Go 1.23.0+ is installed
- Check that required dependencies are available
- Verify Chrome/Chromium is installed for UI testing

**Configuration file not found:**
- Check file path is relative to working directory
- Ensure JSON syntax is valid
- Verify file permissions

**Resource cleanup warnings:**
- Always use `defer framework.Close()`
- Check for goroutine leaks in custom code
- Monitor resource usage during development

## 📚 Next Steps

After mastering the getting started examples, progress to:

1. **[Basic Usage Examples](basic-usage.md)** - Comprehensive framework usage patterns
2. **[UI Testing Examples](ui-testing.md)** - Browser automation basics
3. **[API Testing Examples](api-testing.md)** - REST API testing fundamentals
4. **[Database Testing Examples](database-testing.md)** - Database operation basics

## 🤝 Contributing

Found an issue with the getting started examples? Want to improve them?

1. Check existing issues in the repository
2. Create a new issue describing the problem or enhancement
3. Submit a pull request with your improvements
4. Follow the contribution guidelines in the repository

---

These getting started examples provide the foundation for all other Gowright testing scenarios. Take time to understand these concepts before moving to more advanced examples.