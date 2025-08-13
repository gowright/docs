# Running Examples

The Gowright testing framework provides powerful scripts for running examples individually or in organized batches. This guide covers the enhanced example execution system with comprehensive reporting and error handling.

## 🚀 Quick Start

### Run All Examples
```bash
# Execute all examples with enhanced reporting
./examples/run_all_examples.sh
```

### Run by Category
```bash
# Run specific categories
./examples/run_category.sh getting-started
./examples/run_category.sh ui-testing
./examples/run_category.sh api-testing
```

### Run Individual Examples
```bash
# Run a specific example
go run examples/getting-started/basic_usage.go
go run examples/ui-testing/ui_basic.go
```

### Validate Examples
```bash
# Validate all examples for structure and compilation
./examples/validate_examples.sh
```

## 📊 Enhanced Runner Features

### `run_all_examples.sh` Enhancements

The enhanced runner script provides:

#### **Organized Execution**
- Executes examples by category in logical order
- Maintains backward compatibility with legacy examples
- Provides clear category separation in output

#### **Progress Tracking**
- Real-time progress indicators with example counts
- Individual example status (✅ passed / ❌ failed)
- Comprehensive final summary with statistics

#### **Error Resilience**
- Continues execution even if individual examples fail
- Tracks and reports failed examples
- Provides detailed error information

#### **Enhanced Reporting**
- Organized report directory structure
- Legacy report compatibility
- Clear guidance on report locations

### `validate_examples.sh` Features

The validation script provides comprehensive example quality assurance:

#### **Structure Validation**
- Verifies required build tags (`//go:build ignore`)
- Checks for proper package declarations (`package main`)
- Ensures main function presence (`func main()`)
- Validates Gowright framework imports

#### **Compilation Testing**
- Syntax validation through Go compilation
- Dependency resolution verification
- Error reporting with detailed output
- Cross-platform compatibility checks

#### **Organization Support**
- Validates both organized category structure and legacy examples
- Checks documentation files (README.md, EXAMPLES_INDEX.md)
- Verifies script permissions and executability
- Comprehensive statistics and reporting

### Example Output

```bash
=== Gowright Testing Framework - All Examples Runner ===
Running all examples in organized structure...

🗂️  Running organized examples by category...

📁 Category: getting-started
[1] Running getting-started/basic_usage.go...
----------------------------------------
✅ getting-started/basic_usage.go completed successfully

[2] Running getting-started/configuration_examples.go...
----------------------------------------
✅ getting-started/configuration_examples.go completed successfully

[3] Running getting-started/first_test.go...
----------------------------------------
✅ getting-started/first_test.go completed successfully

📁 Category: ui-testing
[4] Running ui-testing/ui_basic.go...
----------------------------------------
✅ ui-testing/ui_basic.go completed successfully

[5] Running ui-testing/ui_forms.go...
----------------------------------------
✅ ui-testing/ui_forms.go completed successfully

[6] Running ui-testing/ui_navigation.go...
----------------------------------------
✅ ui-testing/ui_navigation.go completed successfully

[7] Running ui-testing/ui_dynamic_content.go...
----------------------------------------
✅ ui-testing/ui_dynamic_content.go completed successfully

[8] Running ui-testing/ui_file_uploads.go...
----------------------------------------
✅ ui-testing/ui_file_uploads.go completed successfully

[9] Running ui-testing/ui_responsive.go...
----------------------------------------
✅ ui-testing/ui_responsive.go completed successfully

📁 Category: api-testing
[10] Running api-testing/api_basic.go...
----------------------------------------
✅ api-testing/api_basic.go completed successfully

[11] Running api-testing/api_authentication.go...
----------------------------------------
✅ api-testing/api_authentication.go completed successfully

[12] Running api-testing/api_crud_operations.go...
----------------------------------------
✅ api-testing/api_crud_operations.go completed successfully

[13] Running api-testing/api_error_handling.go...
----------------------------------------
✅ api-testing/api_error_handling.go completed successfully

[14] Running api-testing/api_performance.go...
----------------------------------------
✅ api-testing/api_performance.go completed successfully

📁 Category: database-testing
[15] Running database-testing/database_basic.go...
----------------------------------------
✅ database-testing/database_basic.go completed successfully

[16] Running database-testing/database_transactions.go...
----------------------------------------
✅ database-testing/database_transactions.go completed successfully

[17] Running database-testing/database_migrations.go...
----------------------------------------
✅ database-testing/database_migrations.go completed successfully

📁 Category: openapi-testing
[18] Running openapi-testing/openapi_validation.go...
----------------------------------------
✅ openapi-testing/openapi_validation.go completed successfully

📁 Category: advanced-patterns
[19] Running advanced-patterns/patterns_page_object.go...
----------------------------------------
✅ advanced-patterns/patterns_page_object.go completed successfully

[20] Running advanced-patterns/patterns_test_suites.go...
----------------------------------------
✅ advanced-patterns/patterns_test_suites.go completed successfully

[21] Running advanced-patterns/patterns_modular.go...
----------------------------------------
✅ advanced-patterns/patterns_modular.go completed successfully

[22] Running advanced-patterns/patterns_data_driven.go...
----------------------------------------
✅ advanced-patterns/patterns_data_driven.go completed successfully

[23] Running advanced-patterns/patterns_fixtures.go...
----------------------------------------
✅ advanced-patterns/patterns_fixtures.go completed successfully

📜 Running legacy examples in root directory...
[4] Running legacy/basic_usage.go...
----------------------------------------
✅ legacy/basic_usage.go completed successfully

=== All Examples Complete ===

📊 Final Summary:
   Total examples run: 28
   Passed: 28
   Failed: 0

🎉 All examples completed successfully!
```

### Validation Output Example

```bash
=== Gowright Examples Validation ===
Validating example structure and compilation...

🗂️  Validating organized examples...

📁 Category: getting-started
[1] Validating getting-started/basic_usage.go...
✅ getting-started/basic_usage.go - Valid structure and compiles

[2] Validating getting-started/configuration_examples.go...
✅ getting-started/configuration_examples.go - Valid structure and compiles

📜 Validating legacy examples...
[3] Validating legacy/basic_usage.go...
✅ legacy/basic_usage.go - Valid structure and compiles

📚 Validating documentation files...
✅ Documentation found: README.md
✅ Documentation found: EXAMPLES_INDEX.md

🔧 Validating scripts...
✅ Script found and executable: run_all_examples.sh
✅ Script found and executable: validate_examples.sh

=== Validation Summary ===
📊 Statistics:
   Total examples validated: 28
   Valid examples: 28
   Invalid examples: 0
   Compilation errors: 0

🎉 All examples are valid and compile successfully!
```

## 📁 Report Organization

### New Organized Structure
```
examples/
├── reports/
│   ├── getting-started/     # Getting started examples
│   │   ├── basic_usage_report.html
│   │   ├── configuration_examples_report.html
│   │   └── first_test_report.html
│   ├── ui-testing/          # UI testing examples
│   │   ├── ui_basic_report.html
│   │   ├── ui_forms_report.html
│   │   └── ui_navigation_report.html
│   ├── api-testing/         # API testing examples
│   │   ├── api_basic_report.html
│   │   ├── api_authentication_report.html
│   │   ├── api_crud_operations_report.html
│   │   ├── api_error_handling_report.html
│   │   └── api_performance_report.html
│   ├── database-testing/    # Database testing examples
│   │   ├── database_basic_report.html
│   │   ├── database_transactions_report.html
│   │   └── database_migrations_report.html
│   ├── openapi-testing/     # OpenAPI testing examples
│   │   └── openapi_validation_report.html
│   ├── advanced-patterns/   # Advanced pattern examples
│   │   ├── patterns_page_object_report.html
│   │   ├── patterns_test_suites_report.html
│   │   ├── patterns_modular_report.html
│   │   ├── patterns_data_driven_report.html
│   │   └── patterns_fixtures_report.html
│   └── [other categories]/
```

### Legacy Compatibility
```
examples/
├── ui-test-reports/         # Backward compatible
├── api-test-reports/        # Backward compatible
├── database-test-reports/   # Backward compatible
└── [other legacy directories]/
```

## 🔧 Script Configuration

### Environment Variables
```bash
# Control script behavior
export GOWRIGHT_EXAMPLES_VERBOSE=true    # Detailed output
export GOWRIGHT_EXAMPLES_PARALLEL=false  # Sequential execution
export GOWRIGHT_EXAMPLES_TIMEOUT=300     # Timeout per example (seconds)
```

### Custom Categories
The script automatically detects categories based on directory structure:
- `getting-started/` → getting-started category
- `ui-testing/` → ui-testing category
- `api-testing/` → api-testing category
- And so on...

## 🎯 Usage Patterns

### Development Workflow
```bash
# 1. Validate examples structure and compilation
./examples/validate_examples.sh

# 2. Run getting started examples first
./examples/run_category.sh getting-started

# 3. Focus on specific testing area
./examples/run_category.sh ui-testing

# 4. Run comprehensive test before commit
./examples/run_all_examples.sh
```

### CI/CD Integration
```bash
# In your CI pipeline
# First validate example structure
./examples/validate_examples.sh
if [ $? -ne 0 ]; then
    echo "Example validation failed"
    exit 1
fi

# Then run all examples
./examples/run_all_examples.sh
if [ $? -ne 0 ]; then
    echo "Examples failed - check reports"
    exit 1
fi
```

### Debugging Failed Examples
```bash
# First validate example structure
./examples/validate_examples.sh

# Run specific category to isolate issues
./examples/run_category.sh api-testing

# Run individual example with verbose output
GOWRIGHT_LOG_LEVEL=DEBUG go run examples/api-testing/api_basic.go
```

## 🛠️ Troubleshooting

### Common Issues

**Script Permission Denied:**
```bash
chmod +x examples/run_all_examples.sh
chmod +x examples/run_category.sh
```

**Examples Fail to Run:**
- Run validation first: `./examples/validate_examples.sh`
- Check Go version (1.23.0+ required)
- Ensure dependencies are installed: `go mod tidy`
- Verify Chrome/Chromium is available for UI tests

**Validation Issues:**
- Missing build tags: Add `//go:build ignore` at the top of example files
- Missing package main: Ensure `package main` is declared
- Missing main function: Add `func main() { ... }`
- Import errors: Check Gowright import path
- Compilation errors: Fix syntax and dependency issues

**Report Generation Issues:**
- Check disk space for report output
- Verify write permissions in examples directory
- Ensure no conflicting processes are using report files

### Performance Optimization

**Large Example Sets:**
```bash
# Run categories in parallel (if supported)
./examples/run_category.sh getting-started &
./examples/run_category.sh api-testing &
wait
```

**Resource Management:**
- Monitor memory usage during execution
- Close browsers between UI test examples
- Clean up temporary files regularly

## 📚 Advanced Usage

### Custom Example Categories
To add new categories:

1. Create directory: `examples/my-category/`
2. Add Go examples: `examples/my-category/my_example.go`
3. The runner will automatically detect and execute them

### Integration with Testing Frameworks
```go
// In your test files
func TestExampleExecution(t *testing.T) {
    cmd := exec.Command("./examples/run_category.sh", "getting-started")
    output, err := cmd.CombinedOutput()
    assert.NoError(t, err)
    assert.Contains(t, string(output), "completed successfully")
}
```

### Report Analysis
```bash
# Generate summary report
./examples/run_all_examples.sh > execution_summary.log 2>&1

# Extract statistics
grep "Final Summary" execution_summary.log
grep "Failed:" execution_summary.log
```

## 🤝 Contributing

When adding new examples or modifying runners:

1. **Test thoroughly** with both organized and legacy structures
2. **Maintain backward compatibility** with existing scripts
3. **Update documentation** to reflect new features
4. **Follow naming conventions** for consistency
5. **Include error handling** for robust execution

---

The enhanced example runner system provides a professional, reliable way to execute and validate Gowright testing framework examples across all categories and complexity levels.