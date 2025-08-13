# Reporting Examples (3/3 - 100% Complete) ✅

This section contains comprehensive reporting examples for the Gowright testing framework. These examples demonstrate various reporting capabilities, from basic HTML reports to advanced dashboard integrations.

## 📁 Reporting Examples

### 📊 Basic Reporting (`reporting/reporting_basic.go`) ✅
Fundamental reporting capabilities with HTML and JSON output formats.

**Key Concepts Covered:**
- Basic JSON and HTML reporting
- HTML report generation
- JSON report structure
- Test result visualization
- Report configuration
- Success metrics
- Screenshot integration
- Execution timeline visualization

**Example Usage:**
```bash
go run examples/reporting/reporting_basic.go
```

**Generated Reports:**
- `test-reports/report.html` - Interactive HTML report
- `test-reports/report.json` - Structured JSON data
- `test-reports/screenshots/` - Test screenshots

### 🎨 Custom Reporting (`reporting/reporting_custom.go`) ✅ **NEW**
Advanced custom reporting with multiple formats and specialized report types.

**Key Concepts Covered:**
- Custom report formats (XML, CSV)
- Dashboard generation
- Team-specific reports (developer vs manager views)
- Trend analysis reporting
- Multi-format report generation
- Custom XML/JUnit format generation
- CSV reports for data analysis
- Custom HTML dashboards with interactive elements
- Historical reporting

**Example Usage:**
```bash
go run examples/reporting/reporting_custom.go
```

**Generated Report Types:**
- **Standard Reports**: JSON and HTML formats
- **XML/JUnit Reports**: CI/CD integration compatible
- **CSV Reports**: Test summary and metrics data
- **Custom Dashboard**: Interactive HTML with charts
- **Team Reports**: Developer-focused and manager summary
- **Trend Analysis**: Historical performance tracking

**Customization Features:**
- Custom XML schema definitions
- Configurable CSV data exports
- Interactive HTML dashboards
- Role-based report content
- Historical trend visualization
- Multi-audience report generation

### 📊 Assertion-Focused Reporting (`reporting/reporting_assertions.go`) ✅
Detailed assertion tracking and step-by-step test execution reporting.

**Key Concepts Covered:**
- Assertion-focused reporting
- Step-by-step tracking
- Detailed failure analysis
- Comprehensive test documentation
- Granular assertion tracking
- Step-by-step execution logging
- Assertion success/failure metrics
- Enhanced debugging information
- Professional test documentation

**Example Usage:**
```bash
go run examples/reporting/reporting_assertions.go
```

**Assertion Features:**
- Individual assertion tracking
- Detailed failure descriptions
- Assertion-level metrics
- Enhanced debugging information
- Professional test documentation

## 📊 Report Types and Formats

### Custom XML/JUnit Reports
Generate CI/CD compatible XML reports with custom schemas:

```go
// Custom XML test suite structure
type CustomTestSuite struct {
    XMLName    xml.Name           `xml:"testsuite"`
    Name       string             `xml:"name,attr"`
    Tests      int                `xml:"tests,attr"`
    Failures   int                `xml:"failures,attr"`
    Errors     int                `xml:"errors,attr"`
    Time       string             `xml:"time,attr"`
    Timestamp  string             `xml:"timestamp,attr"`
    TestCases  []CustomTestCase   `xml:"testcase"`
    Properties []CustomProperty   `xml:"properties>property"`
}

// Generate JUnit-compatible XML
customSuite := CustomTestSuite{
    Name:      testResults.SuiteName,
    Tests:     testResults.TotalTests,
    Failures:  testResults.FailedTests,
    Time:      fmt.Sprintf("%.3f", testResults.EndTime.Sub(testResults.StartTime).Seconds()),
    Timestamp: testResults.StartTime.Format(time.RFC3339),
}
```

### CSV Reports
Data analysis friendly CSV exports:

```csv
Test Name,Status,Duration (seconds),Start Time,End Time,Error Message,Screenshot Count,Log Count
User Authentication Test,passed,12.000,2024-01-15 14:30:22,2024-01-15 14:30:34,,1,3
Database Connection Test,failed,30.000,2024-01-15 14:30:35,2024-01-15 14:31:05,connection timeout after 30 seconds,1,5
```

### Interactive HTML Dashboards
Custom HTML dashboards with embedded styling and metrics:

```html
<div class="metrics">
    <div class="metric-card">
        <div class="metric-value">8</div>
        <div class="metric-label">Total Tests</div>
    </div>
    <div class="metric-card">
        <div class="metric-value" style="color: #28a745;">5</div>
        <div class="metric-label">Passed</div>
    </div>
    <div class="metric-card">
        <div class="metric-value" style="color: #dc3545;">2</div>
        <div class="metric-label">Failed</div>
    </div>
</div>
```

### Team-Specific Reports
Role-based reporting for different audiences:

**Developer Report (Markdown):**
```markdown
# Developer Test Report

## Failed Tests (Requires Attention)

### Database Connection Test
- **Duration**: 30.000s
- **Error**: connection timeout after 30 seconds
- **Screenshots**: 1
- **Logs**: 5 entries
```

**Manager Summary (Markdown):**
```markdown
# Management Test Summary

## Executive Summary
Test suite "Custom Reporting Example Suite" completed with **62.5% success rate**.

## Status
🟡 Minor issues detected - development team investigating

## Next Actions
- Development team to investigate failures
- Hold deployment until issues resolved
```

### Trend Analysis Reports
Historical performance tracking and comparison:

```markdown
# Test Trend Analysis

## Historical Comparison
| Date | Success Rate | Duration | Total Tests | Status |
|------|-------------|----------|-------------|---------|
| 2024-01-15 | 62.5% | 25.0s | 8 | Current |
| 2024-01-14 | 100.0% | 132.8s | 8 | Baseline |
| 2024-01-13 | 75.0% | 167.3s | 8 | Issue Day |

## Trends
- **Success Rate Trend**: 📊 Stable (75-90%)
- **Performance Trend**: ⚡ Fast execution (under 140s)
- **Stability**: 🟡 Moderately stable
```

### HTML Reports
Interactive web-based reports with rich visualizations:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Gowright Test Report</title>
    <style>
        /* Custom styling */
        .test-summary { background: #f8f9fa; }
        .test-passed { color: #28a745; }
        .test-failed { color: #dc3545; }
    </style>
</head>
<body>
    <div class="test-summary">
        <h1>Test Execution Summary</h1>
        <div class="metrics">
            <span class="test-passed">Passed: 45</span>
            <span class="test-failed">Failed: 3</span>
            <span>Duration: 2m 34s</span>
        </div>
    </div>
    <!-- Detailed test results -->
</body>
</html>
```

### JSON Reports
Structured data format for programmatic processing:

```json
{
  "testRun": {
    "id": "run-2024-01-15-143022",
    "startTime": "2024-01-15T14:30:22Z",
    "endTime": "2024-01-15T14:32:56Z",
    "duration": "2m34s",
    "summary": {
      "total": 48,
      "passed": 45,
      "failed": 3,
      "skipped": 0
    },
    "tests": [
      {
        "name": "TestUserLogin",
        "status": "passed",
        "duration": "1.2s",
        "screenshots": ["login-success.png"]
      }
    ]
  }
}
```

### PDF Reports
Professional PDF reports for stakeholders:

- Executive summary
- Detailed test results
- Charts and graphs
- Screenshots and evidence
- Recommendations

### Excel Reports
Spreadsheet format for data analysis:

- Test results data
- Pivot tables
- Charts and graphs
- Historical trend analysis
- Filterable data views

## 🎯 Reporting Configuration

### Basic Configuration
```json
{
  "reportConfig": {
    "localReports": {
      "json": true,
      "html": true,
      "outputDir": "./test-reports"
    },
    "includeScreenshots": true,
    "includeTimeline": true,
    "includeMetrics": true
  }
}
```

### Advanced Configuration
```json
{
  "reportConfig": {
    "localReports": {
      "json": true,
      "html": true,
      "pdf": true,
      "excel": true,
      "outputDir": "./test-reports"
    },
    "customization": {
      "template": "./templates/custom-report.html",
      "branding": {
        "logo": "./assets/company-logo.png",
        "colors": {
          "primary": "#007bff",
          "success": "#28a745",
          "danger": "#dc3545"
        }
      }
    },
    "integrations": {
      "jiraXray": {
        "enabled": true,
        "projectKey": "TEST",
        "testPlanKey": "TEST-123"
      },
      "slack": {
        "enabled": true,
        "webhook": "https://hooks.slack.com/...",
        "channel": "#test-results"
      }
    }
  }
}
```

## 📈 Metrics and Analytics

### Standard Metrics
- **Test Execution Summary**: Pass/fail counts, duration
- **Performance Metrics**: Response times, resource usage
- **Coverage Metrics**: Code coverage, test coverage
- **Trend Analysis**: Historical performance trends

### Custom Metrics
```go
// Add custom metrics to reports
reporter := framework.GetReporter()
reporter.AddCustomMetric("api_response_time", 250.5, "ms")
reporter.AddCustomMetric("memory_usage", 512, "MB")
reporter.AddCustomMetric("test_complexity", 8.5, "score")
```

### KPI Dashboard
```go
// Configure KPI tracking
kpiConfig := &gowright.KPIConfig{
    Metrics: []gowright.KPIMetric{
        {
            Name: "Test Success Rate",
            Target: 95.0,
            Unit: "%",
            Threshold: gowright.KPIThreshold{
                Warning: 90.0,
                Critical: 85.0,
            },
        },
        {
            Name: "Average Response Time",
            Target: 200.0,
            Unit: "ms",
            Threshold: gowright.KPIThreshold{
                Warning: 500.0,
                Critical: 1000.0,
            },
        },
    },
}
```

## 🔗 Integration Examples

### Jira Xray Integration
```go
// Configure Jira Xray integration
xrayConfig := &gowright.JiraXrayConfig{
    BaseURL: "https://your-jira.atlassian.net",
    Username: "test-automation@company.com",
    APIToken: "your-api-token",
    ProjectKey: "TEST",
    TestPlanKey: "TEST-123",
}

reporter := gowright.NewJiraXrayReporter(xrayConfig)
framework.AddReporter(reporter)
```

### Slack Integration
```go
// Configure Slack notifications
slackConfig := &gowright.SlackConfig{
    WebhookURL: "https://hooks.slack.com/services/...",
    Channel: "#test-results",
    Username: "Gowright Bot",
    IconEmoji: ":robot_face:",
}

reporter := gowright.NewSlackReporter(slackConfig)
framework.AddReporter(reporter)
```

### Grafana Dashboard
```go
// Configure Grafana metrics
grafanaConfig := &gowright.GrafanaConfig{
    URL: "http://grafana.company.com",
    APIKey: "your-api-key",
    Dashboard: "test-automation",
}

reporter := gowright.NewGrafanaReporter(grafanaConfig)
framework.AddReporter(reporter)
```

## 📊 Report Templates

### Custom HTML Template
```html
<!DOCTYPE html>
<html>
<head>
    <title>{{.Title}} - Test Report</title>
    <link rel="stylesheet" href="{{.StylesheetURL}}">
</head>
<body>
    <header class="report-header">
        <img src="{{.BrandingLogo}}" alt="Company Logo">
        <h1>{{.Title}}</h1>
        <div class="report-meta">
            <span>Generated: {{.GeneratedAt}}</span>
            <span>Duration: {{.Duration}}</span>
        </div>
    </header>
    
    <section class="summary">
        <div class="metric-card passed">
            <h3>{{.Summary.Passed}}</h3>
            <p>Passed</p>
        </div>
        <div class="metric-card failed">
            <h3>{{.Summary.Failed}}</h3>
            <p>Failed</p>
        </div>
        <div class="metric-card total">
            <h3>{{.Summary.Total}}</h3>
            <p>Total</p>
        </div>
    </section>
    
    <section class="test-results">
        {{range .Tests}}
        <div class="test-result {{.Status}}">
            <h4>{{.Name}}</h4>
            <p>Duration: {{.Duration}}</p>
            {{if .Screenshots}}
            <div class="screenshots">
                {{range .Screenshots}}
                <img src="{{.}}" alt="Screenshot">
                {{end}}
            </div>
            {{end}}
        </div>
        {{end}}
    </section>
</body>
</html>
```

### Email Report Template
```html
<div style="font-family: Arial, sans-serif; max-width: 600px;">
    <h2 style="color: #333;">Test Execution Report</h2>
    
    <div style="background: #f8f9fa; padding: 20px; border-radius: 5px;">
        <h3>Summary</h3>
        <ul style="list-style: none; padding: 0;">
            <li style="color: #28a745;">✓ Passed: {{.Summary.Passed}}</li>
            <li style="color: #dc3545;">✗ Failed: {{.Summary.Failed}}</li>
            <li>⏱ Duration: {{.Duration}}</li>
        </ul>
    </div>
    
    {{if .FailedTests}}
    <div style="margin-top: 20px;">
        <h3 style="color: #dc3545;">Failed Tests</h3>
        <ul>
            {{range .FailedTests}}
            <li>{{.Name}} - {{.Error}}</li>
            {{end}}
        </ul>
    </div>
    {{end}}
    
    <p style="margin-top: 20px;">
        <a href="{{.ReportURL}}" style="background: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">
            View Full Report
        </a>
    </p>
</div>
```

## 🚀 Performance Optimization

### Report Generation Performance
- **Lazy loading**: Generate report sections on demand
- **Caching**: Cache report templates and assets
- **Compression**: Compress large reports
- **Streaming**: Stream large datasets

### Storage Optimization
- **Cleanup policies**: Automatically clean old reports
- **Compression**: Compress archived reports
- **Cloud storage**: Store reports in cloud storage
- **Retention policies**: Configure report retention

## 🧪 Testing Report Generation

### Report Validation Tests
```go
func TestReportGeneration(t *testing.T) {
    framework := gowright.NewWithDefaults()
    defer framework.Close()
    
    // Configure reporting
    config := &gowright.ReportConfig{
        LocalReports: gowright.LocalReportConfig{
            JSON: true,
            HTML: true,
            OutputDir: "./test-reports",
        },
    }
    framework.SetReportConfig(config)
    
    // Run test and generate report
    err := framework.Initialize()
    assert.NoError(t, err)
    
    // Verify report files exist
    assert.FileExists(t, "./test-reports/report.html")
    assert.FileExists(t, "./test-reports/report.json")
    
    // Validate report content
    reportData, err := os.ReadFile("./test-reports/report.json")
    assert.NoError(t, err)
    
    var report gowright.TestReport
    err = json.Unmarshal(reportData, &report)
    assert.NoError(t, err)
    assert.NotEmpty(t, report.TestRun.ID)
}
```

## 📚 Best Practices

### Report Design
- **Clear hierarchy**: Organize information logically
- **Visual clarity**: Use colors and icons effectively
- **Responsive design**: Ensure reports work on all devices
- **Accessibility**: Follow accessibility guidelines

### Data Presentation
- **Meaningful metrics**: Include relevant KPIs
- **Trend analysis**: Show historical trends
- **Actionable insights**: Provide clear recommendations
- **Context**: Include relevant context information

### Performance
- **Efficient generation**: Optimize report generation time
- **Reasonable file sizes**: Keep reports manageable
- **Fast loading**: Optimize for quick loading
- **Scalability**: Handle large test suites efficiently

## 📞 Troubleshooting

### Common Issues
- **Report generation fails**: Check output directory permissions
- **Missing screenshots**: Verify screenshot capture is enabled
- **Integration failures**: Check API credentials and connectivity
- **Large file sizes**: Enable compression and optimize images

### Debug Mode
```go
config := &gowright.Config{
    LogLevel: "debug",
    ReportConfig: &gowright.ReportConfig{
        Debug: true,
        VerboseLogging: true,
    },
}
```

## 📚 Related Documentation

- [Advanced Features - Reporting](../advanced/reporting.md) - Detailed reporting architecture
- [Configuration Reference](../reference/configuration.md) - Complete configuration options
- [Integration Testing Examples](integration-testing.md) - End-to-end reporting scenarios

---

These reporting examples provide comprehensive coverage of Gowright's reporting capabilities, from basic HTML reports to advanced dashboard integrations. Choose the reporting approach that best fits your team's needs and stakeholder requirements.