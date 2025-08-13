# Reporting

Gowright provides comprehensive reporting capabilities that generate detailed, professional reports in multiple formats. Reports include test results, performance metrics, screenshots, logs, and interactive visualizations.

## Overview

The reporting system in Gowright provides:

- **Multiple Formats**: HTML, JSON, XML, PDF reports
- **Interactive Dashboards**: Rich HTML reports with charts and filtering
- **Performance Metrics**: Detailed timing and resource usage data
- **Visual Evidence**: Screenshots, videos, and visual comparisons
- **Remote Integration**: Send reports to external systems
- **Custom Reports**: Extensible reporting framework

## Local Reporting

### HTML Reports

```go
package main

import (
    "testing"
    "time"
    
    "github.com/gowright/framework/pkg/gowright"
    "github.com/stretchr/testify/assert"
)

func TestHTMLReporting(t *testing.T) {
    // Configure HTML reporting
    config := &gowright.Config{
        ReportConfig: &gowright.ReportConfig{
            LocalReports: gowright.LocalReportConfig{
                HTML:      true,
                OutputDir: "./test-reports",
                HTMLConfig: &gowright.HTMLReportConfig{
                    Theme:           "modern",
                    IncludeCharts:   true,
                    IncludeLogs:     true,
                    IncludeMetrics:  true,
                    EmbedAssets:     true,
                    GenerateIndex:   true,
                },
            },
        },
    }
    
    framework := gowright.New(config)
    defer framework.Close()
    
    err := framework.Initialize()
    assert.NoError(t, err)
    
    // Create test suite with various test types
    testSuite := &gowright.TestSuite{
        Name: "Comprehensive Test Suite",
        Description: "Tests for HTML reporting demonstration",
        
        Tests: []gowright.Test{
            // API test
            gowright.NewAPITestBuilder("User API Test", "GET", "/api/users/1").
                WithTester(framework.GetAPITester()).
                ExpectStatus(200).
                ExpectJSONPath("$.id", 1).
                WithPerformanceMetrics(true).
                Build(),
            
            // UI test with screenshot
            &gowright.UITest{
                Name: "Login UI Test",
                Steps: []gowright.UIStep{
                    {Action: "navigate", Target: "https://example.com/login"},
                    {Action: "type", Target: "input[name='username']", Value: "testuser"},
                    {Action: "type", Target: "input[name='password']", Value: "password"},
                    {Action: "click", Target: "button[type='submit']"},
                    {Action: "screenshot", Target: "login-success.png"},
                },
                CaptureScreenshots: true,
            },
            
            // Database test
            &gowright.DatabaseTest{
                Name:       "User Database Test",
                Connection: "test",
                Query:      "SELECT COUNT(*) as count FROM users",
                Expected: &gowright.DatabaseExpectation{
                    RowCount: 1,
                },
            },
        },
    }
    
    framework.SetTestSuite(testSuite)
    results, err := framework.ExecuteTestSuite()
    assert.NoError(t, err)
    
    // Generate HTML report
    reporter := gowright.NewHTMLReporter(config.ReportConfig.LocalReports.HTMLConfig)
    err = reporter.GenerateReport(results, "./test-reports/report.html")
    assert.NoError(t, err)
    
    // Verify report files were created
    assert.FileExists(t, "./test-reports/report.html")
    assert.FileExists(t, "./test-reports/assets/style.css")
    assert.FileExists(t, "./test-reports/assets/script.js")
}
```

### JSON Reports

```go
func TestJSONReporting(t *testing.T) {
    config := &gowright.Config{
        ReportConfig: &gowright.ReportConfig{
            LocalReports: gowright.LocalReportConfig{
                JSON:      true,
                OutputDir: "./test-reports",
                JSONConfig: &gowright.JSONReportConfig{
                    Pretty:          true,
                    IncludeMetrics:  true,
                    IncludeLogs:     true,
                    IncludePayloads: true,
                },
            },
        },
    }
    
    framework := gowright.New(config)
    defer framework.Close()
    
    // Execute tests...
    testSuite := createSampleTestSuite(framework)
    framework.SetTestSuite(testSuite)
    results, err := framework.ExecuteTestSuite()
    assert.NoError(t, err)
    
    // Generate JSON report
    reporter := gowright.NewJSONReporter(config.ReportConfig.LocalReports.JSONConfig)
    err = reporter.GenerateReport(results, "./test-reports/report.json")
    assert.NoError(t, err)
    
    // Verify JSON structure
    reportData, err := ioutil.ReadFile("./test-reports/report.json")
    assert.NoError(t, err)
    
    var report map[string]interface{}
    err = json.Unmarshal(reportData, &report)
    assert.NoError(t, err)
    
    // Validate report structure
    assert.Contains(t, report, "test_suite")
    assert.Contains(t, report, "summary")
    assert.Contains(t, report, "tests")
    assert.Contains(t, report, "metrics")
    assert.Contains(t, report, "environment")
    
    summary := report["summary"].(map[string]interface{})
    assert.Contains(t, summary, "total_tests")
    assert.Contains(t, summary, "passed_tests")
    assert.Contains(t, summary, "failed_tests")
    assert.Contains(t, summary, "duration")
}
```

### XML/JUnit Reports

```go
func TestJUnitReporting(t *testing.T) {
    config := &gowright.Config{
        ReportConfig: &gowright.ReportConfig{
            LocalReports: gowright.LocalReportConfig{
                XML:       true,
                OutputDir: "./test-reports",
                XMLConfig: &gowright.XMLReportConfig{
                    Format:         "junit",
                    IncludeStdout:  true,
                    IncludeStderr:  true,
                    IncludeSystem:  true,
                },
            },
        },
    }
    
    framework := gowright.New(config)
    defer framework.Close()
    
    // Execute tests...
    testSuite := createSampleTestSuite(framework)
    framework.SetTestSuite(testSuite)
    results, err := framework.ExecuteTestSuite()
    assert.NoError(t, err)
    
    // Generate JUnit XML report
    reporter := gowright.NewJUnitReporter(config.ReportConfig.LocalReports.XMLConfig)
    err = reporter.GenerateReport(results, "./test-reports/junit.xml")
    assert.NoError(t, err)
    
    // Verify XML structure
    xmlData, err := ioutil.ReadFile("./test-reports/junit.xml")
    assert.NoError(t, err)
    
    // Parse and validate XML
    var testSuites struct {
        XMLName    xml.Name `xml:"testsuites"`
        TestSuites []struct {
            Name     string `xml:"name,attr"`
            Tests    int    `xml:"tests,attr"`
            Failures int    `xml:"failures,attr"`
            Time     string `xml:"time,attr"`
            TestCase []struct {
                Name      string `xml:"name,attr"`
                ClassName string `xml:"classname,attr"`
                Time      string `xml:"time,attr"`
                Failure   *struct {
                    Message string `xml:"message,attr"`
                    Content string `xml:",chardata"`
                } `xml:"failure,omitempty"`
            } `xml:"testcase"`
        } `xml:"testsuite"`
    }
    
    err = xml.Unmarshal(xmlData, &testSuites)
    assert.NoError(t, err)
    assert.Greater(t, len(testSuites.TestSuites), 0)
}
```

## Advanced Reporting Features

### Performance Dashboards

```go
func TestPerformanceDashboard(t *testing.T) {
    config := &gowright.Config{
        ReportConfig: &gowright.ReportConfig{
            LocalReports: gowright.LocalReportConfig{
                HTML:      true,
                OutputDir: "./test-reports",
                HTMLConfig: &gowright.HTMLReportConfig{
                    Theme:             "performance",
                    IncludeCharts:     true,
                    IncludeMetrics:    true,
                    PerformanceDashboard: true,
                    ChartConfig: &gowright.ChartConfig{
                        ResponseTimeChart:    true,
                        ThroughputChart:     true,
                        ErrorRateChart:      true,
                        ResourceUsageChart:  true,
                        TimelineChart:       true,
                    },
                },
            },
        },
    }
    
    framework := gowright.New(config)
    defer framework.Close()
    
    // Create performance test suite
    performanceTests := &gowright.TestSuite{
        Name: "Performance Test Suite",
        Tests: []gowright.Test{
            &gowright.PerformanceTest{
                Name: "API Load Test",
                TestFunc: func() gowright.Test {
                    return gowright.NewAPITestBuilder("Load Test", "GET", "/api/users").
                        WithTester(framework.GetAPITester()).
                        ExpectStatus(200).
                        ExpectResponseTime(500 * time.Millisecond).
                        Build()
                },
                LoadConfig: &gowright.LoadConfig{
                    ConcurrentUsers: 50,
                    Duration:        2 * time.Minute,
                    RampUpTime:      30 * time.Second,
                },
                PerformanceThresholds: &gowright.PerformanceThresholds{
                    MaxResponseTime: 1 * time.Second,
                    MinThroughput:   100,
                    MaxErrorRate:    0.01,
                },
            },
        },
    }
    
    framework.SetTestSuite(performanceTests)
    results, err := framework.ExecuteTestSuite()
    assert.NoError(t, err)
    
    // Generate performance dashboard
    reporter := gowright.NewPerformanceDashboardReporter(config.ReportConfig.LocalReports.HTMLConfig)
    err = reporter.GenerateReport(results, "./test-reports/performance-dashboard.html")
    assert.NoError(t, err)
    
    // Verify dashboard components
    assert.FileExists(t, "./test-reports/performance-dashboard.html")
    assert.FileExists(t, "./test-reports/assets/charts.js")
    assert.FileExists(t, "./test-reports/data/metrics.json")
}
```

### Visual Testing Reports

```go
func TestVisualTestingReports(t *testing.T) {
    config := &gowright.Config{
        ReportConfig: &gowright.ReportConfig{
            LocalReports: gowright.LocalReportConfig{
                HTML:      true,
                OutputDir: "./test-reports",
                HTMLConfig: &gowright.HTMLReportConfig{
                    VisualTesting: &gowright.VisualTestingConfig{
                        IncludeScreenshots:    true,
                        IncludeComparisons:    true,
                        IncludeDifferences:    true,
                        GenerateThumbnails:    true,
                        ComparisonThreshold:   0.1,
                    },
                },
            },
        },
    }
    
    framework := gowright.New(config)
    defer framework.Close()
    
    // Create visual testing suite
    visualTests := &gowright.TestSuite{
        Name: "Visual Regression Tests",
        Tests: []gowright.Test{
            &gowright.VisualTest{
                Name: "Homepage Visual Test",
                URL:  "https://example.com",
                Screenshots: []gowright.ScreenshotConfig{
                    {Name: "desktop", Width: 1920, Height: 1080},
                    {Name: "tablet", Width: 768, Height: 1024},
                    {Name: "mobile", Width: 375, Height: 667},
                },
                BaselineDir: "./baselines",
                Threshold:   0.1,
            },
            &gowright.VisualTest{
                Name: "Login Page Visual Test",
                URL:  "https://example.com/login",
                Screenshots: []gowright.ScreenshotConfig{
                    {Name: "login-form", Selector: "form.login"},
                    {Name: "full-page", FullPage: true},
                },
                BaselineDir: "./baselines",
                Threshold:   0.05,
            },
        },
    }
    
    framework.SetTestSuite(visualTests)
    results, err := framework.ExecuteTestSuite()
    assert.NoError(t, err)
    
    // Generate visual testing report
    reporter := gowright.NewVisualTestingReporter(config.ReportConfig.LocalReports.HTMLConfig.VisualTesting)
    err = reporter.GenerateReport(results, "./test-reports/visual-report.html")
    assert.NoError(t, err)
    
    // Verify visual report components
    assert.FileExists(t, "./test-reports/visual-report.html")
    assert.DirExists(t, "./test-reports/screenshots")
    assert.DirExists(t, "./test-reports/comparisons")
    assert.DirExists(t, "./test-reports/differences")
}
```

### Test Trend Analysis

```go
func TestTrendAnalysis(t *testing.T) {
    config := &gowright.Config{
        ReportConfig: &gowright.ReportConfig{
            LocalReports: gowright.LocalReportConfig{
                HTML:      true,
                OutputDir: "./test-reports",
                HTMLConfig: &gowright.HTMLReportConfig{
                    TrendAnalysis: &gowright.TrendAnalysisConfig{
                        Enabled:           true,
                        HistoryDays:       30,
                        IncludeCharts:     true,
                        CompareBaseline:   true,
                        HistoryDir:        "./test-history",
                    },
                },
            },
        },
    }
    
    framework := gowright.New(config)
    defer framework.Close()
    
    // Execute tests multiple times to build history
    for i := 0; i < 5; i++ {
        testSuite := createSampleTestSuite(framework)
        framework.SetTestSuite(testSuite)
        results, err := framework.ExecuteTestSuite()
        assert.NoError(t, err)
        
        // Store historical data
        historyManager := gowright.NewTestHistoryManager("./test-history")
        err = historyManager.StoreResults(results)
        assert.NoError(t, err)
        
        // Simulate different execution times
        time.Sleep(100 * time.Millisecond)
    }
    
    // Generate trend analysis report
    historyManager := gowright.NewTestHistoryManager("./test-history")
    trendData, err := historyManager.GetTrendData(30) // Last 30 days
    assert.NoError(t, err)
    
    reporter := gowright.NewTrendAnalysisReporter(config.ReportConfig.LocalReports.HTMLConfig.TrendAnalysis)
    err = reporter.GenerateReport(trendData, "./test-reports/trend-analysis.html")
    assert.NoError(t, err)
    
    // Verify trend analysis components
    assert.FileExists(t, "./test-reports/trend-analysis.html")
    assert.FileExists(t, "./test-reports/data/trend-data.json")
}
```

## Remote Reporting

### Jira Xray Integration

```go
func TestJiraXrayReporting(t *testing.T) {
    config := &gowright.Config{
        ReportConfig: &gowright.ReportConfig{
            RemoteReports: gowright.RemoteReportConfig{
                JiraXray: &gowright.JiraXrayConfig{
                    URL:        "https://your-jira.atlassian.net",
                    Username:   os.Getenv("JIRA_USERNAME"),
                    Password:   os.Getenv("JIRA_API_TOKEN"),
                    ProjectKey: "TEST",
                    TestPlan:   "TEST-123",
                    Version:    "1.0.0",
                    Environment: "staging",
                },
            },
        },
    }
    
    framework := gowright.New(config)
    defer framework.Close()
    
    // Create test suite with Jira test case mappings
    testSuite := &gowright.TestSuite{
        Name: "Jira Xray Integration Tests",
        Tests: []gowright.Test{
            &gowright.JiraLinkedTest{
                Test: gowright.NewAPITestBuilder("User Login", "POST", "/api/login").
                    WithBody(map[string]interface{}{
                        "username": "testuser",
                        "password": "password",
                    }).
                    ExpectStatus(200).
                    Build(),
                JiraTestKey: "TEST-456", // Link to Jira test case
            },
            &gowright.JiraLinkedTest{
                Test: gowright.NewAPITestBuilder("User Profile", "GET", "/api/profile").
                    ExpectStatus(200).
                    Build(),
                JiraTestKey: "TEST-789",
            },
        },
    }
    
    framework.SetTestSuite(testSuite)
    results, err := framework.ExecuteTestSuite()
    assert.NoError(t, err)
    
    // Send results to Jira Xray
    jiraReporter := gowright.NewJiraXrayReporter(config.ReportConfig.RemoteReports.JiraXray)
    err = jiraReporter.SendResults(results)
    assert.NoError(t, err)
    
    // Verify test execution was created in Jira
    executionKey, err := jiraReporter.GetLastExecutionKey()
    assert.NoError(t, err)
    assert.NotEmpty(t, executionKey)
}
```

### Slack Integration

```go
func TestSlackReporting(t *testing.T) {
    config := &gowright.Config{
        ReportConfig: &gowright.ReportConfig{
            RemoteReports: gowright.RemoteReportConfig{
                Slack: &gowright.SlackConfig{
                    WebhookURL: os.Getenv("SLACK_WEBHOOK_URL"),
                    Channel:    "#test-results",
                    Username:   "Gowright Bot",
                    IconEmoji:  ":robot_face:",
                    NotifyOn: []string{"failure", "completion"},
                    IncludeMetrics: true,
                    IncludeCharts:  true,
                },
            },
        },
    }
    
    framework := gowright.New(config)
    defer framework.Close()
    
    testSuite := createSampleTestSuite(framework)
    framework.SetTestSuite(testSuite)
    results, err := framework.ExecuteTestSuite()
    assert.NoError(t, err)
    
    // Send results to Slack
    slackReporter := gowright.NewSlackReporter(config.ReportConfig.RemoteReports.Slack)
    err = slackReporter.SendResults(results)
    assert.NoError(t, err)
}
```

### Custom Dashboard Integration

```go
func TestCustomDashboardReporting(t *testing.T) {
    config := &gowright.Config{
        ReportConfig: &gowright.ReportConfig{
            RemoteReports: gowright.RemoteReportConfig{
                CustomDashboard: &gowright.CustomDashboardConfig{
                    URL:     "https://dashboard.example.com/api/test-results",
                    APIKey:  os.Getenv("DASHBOARD_API_KEY"),
                    Format:  "json",
                    Headers: map[string]string{
                        "Content-Type": "application/json",
                        "X-Source":     "gowright",
                    },
                },
            },
        },
    }
    
    framework := gowright.New(config)
    defer framework.Close()
    
    testSuite := createSampleTestSuite(framework)
    framework.SetTestSuite(testSuite)
    results, err := framework.ExecuteTestSuite()
    assert.NoError(t, err)
    
    // Send results to custom dashboard
    dashboardReporter := gowright.NewCustomDashboardReporter(config.ReportConfig.RemoteReports.CustomDashboard)
    err = dashboardReporter.SendResults(results)
    assert.NoError(t, err)
}
```

## Custom Reporting

### Custom XML/JUnit Report Generation

```go
func TestCustomXMLReporting(t *testing.T) {
    // Define custom XML structures
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
    
    type CustomTestCase struct {
        XMLName   xml.Name      `xml:"testcase"`
        Name      string        `xml:"name,attr"`
        ClassName string        `xml:"classname,attr"`
        Time      string        `xml:"time,attr"`
        Failure   *CustomFailure `xml:"failure,omitempty"`
        Error     *CustomError   `xml:"error,omitempty"`
        SystemOut string        `xml:"system-out,omitempty"`
    }
    
    // Generate custom XML report
    customSuite := CustomTestSuite{
        Name:      testResults.SuiteName,
        Tests:     testResults.TotalTests,
        Failures:  testResults.FailedTests,
        Time:      fmt.Sprintf("%.3f", testResults.EndTime.Sub(testResults.StartTime).Seconds()),
        Timestamp: testResults.StartTime.Format(time.RFC3339),
        Properties: []CustomProperty{
            {Name: "environment", Value: "test"},
            {Name: "framework", Value: "gowright"},
            {Name: "version", Value: "1.0.0"},
        },
    }
    
    // Convert test cases to XML format
    for _, testCase := range testResults.TestCases {
        customCase := CustomTestCase{
            Name:      testCase.Name,
            ClassName: "gowright.TestSuite",
            Time:      fmt.Sprintf("%.3f", testCase.Duration.Seconds()),
            SystemOut: strings.Join(testCase.Logs, "\n"),
        }
        
        if testCase.Status == gowright.TestStatusFailed && testCase.Error != nil {
            customCase.Failure = &CustomFailure{
                Message: testCase.Error.Error(),
                Type:    "AssertionError",
                Content: testCase.Error.Error(),
            }
        }
        
        customSuite.TestCases = append(customSuite.TestCases, customCase)
    }
    
    // Write XML file
    xmlFile := filepath.Join(outputDir, "junit-report.xml")
    file, err := os.Create(xmlFile)
    assert.NoError(t, err)
    defer file.Close()
    
    file.WriteString(`<?xml version="1.0" encoding="UTF-8"?>` + "\n")
    encoder := xml.NewEncoder(file)
    encoder.Indent("", "  ")
    err = encoder.Encode(customSuite)
    assert.NoError(t, err)
}
```

### CSV Report Generation

```go
func TestCSVReporting(t *testing.T) {
    outputDir := "./test-reports/csv"
    os.MkdirAll(outputDir, 0755)
    
    // Generate test summary CSV
    summaryFile := filepath.Join(outputDir, "test-summary.csv")
    file, err := os.Create(summaryFile)
    assert.NoError(t, err)
    defer file.Close()
    
    // Write CSV header
    file.WriteString("Test Name,Status,Duration (seconds),Start Time,End Time,Error Message,Screenshot Count,Log Count\n")
    
    // Write test case data
    for _, testCase := range testResults.TestCases {
        errorMsg := ""
        if testCase.Error != nil {
            errorMsg = strings.ReplaceAll(testCase.Error.Error(), ",", ";") // Escape commas
        }
        
        line := fmt.Sprintf("%s,%s,%.3f,%s,%s,%s,%d,%d\n",
            testCase.Name,
            testCase.Status.String(),
            testCase.Duration.Seconds(),
            testCase.StartTime.Format("2006-01-02 15:04:05"),
            testCase.EndTime.Format("2006-01-02 15:04:05"),
            errorMsg,
            len(testCase.Screenshots),
            len(testCase.Logs),
        )
        file.WriteString(line)
    }
    
    // Generate metrics CSV
    metricsFile := filepath.Join(outputDir, "test-metrics.csv")
    metricsFileHandle, err := os.Create(metricsFile)
    assert.NoError(t, err)
    defer metricsFileHandle.Close()
    
    metricsFileHandle.WriteString("Metric,Value\n")
    metricsFileHandle.WriteString(fmt.Sprintf("Total Tests,%d\n", testResults.TotalTests))
    metricsFileHandle.WriteString(fmt.Sprintf("Passed Tests,%d\n", testResults.PassedTests))
    metricsFileHandle.WriteString(fmt.Sprintf("Failed Tests,%d\n", testResults.FailedTests))
    metricsFileHandle.WriteString(fmt.Sprintf("Success Rate,%.2f%%\n", 
        float64(testResults.PassedTests)/float64(testResults.TotalTests)*100))
}
```

### Interactive HTML Dashboard Generation

```go
func TestCustomDashboardGeneration(t *testing.T) {
    dashboardHTML := `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gowright Custom Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .metrics { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 20px; }
        .metric-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); text-align: center; }
        .metric-value { font-size: 2em; font-weight: bold; color: #333; }
        .metric-label { color: #666; margin-top: 5px; }
        .test-results { background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); overflow: hidden; }
        .test-row { padding: 15px; border-bottom: 1px solid #dee2e6; display: flex; justify-content: space-between; align-items: center; }
        .status-passed { color: #28a745; font-weight: bold; }
        .status-failed { color: #dc3545; font-weight: bold; }
        .status-skipped { color: #ffc107; font-weight: bold; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 Gowright Test Dashboard</h1>
        <p>Suite: {{.SuiteName}}</p>
        <p>Executed: {{.StartTime}}</p>
    </div>
    
    <div class="metrics">
        <div class="metric-card">
            <div class="metric-value">{{.TotalTests}}</div>
            <div class="metric-label">Total Tests</div>
        </div>
        <div class="metric-card">
            <div class="metric-value" style="color: #28a745;">{{.PassedTests}}</div>
            <div class="metric-label">Passed</div>
        </div>
        <div class="metric-card">
            <div class="metric-value" style="color: #dc3545;">{{.FailedTests}}</div>
            <div class="metric-label">Failed</div>
        </div>
        <div class="metric-card">
            <div class="metric-value">{{.SuccessRate}}%</div>
            <div class="metric-label">Success Rate</div>
        </div>
    </div>
    
    <div class="test-results">
        <div class="test-header">Test Results</div>
        {{range .TestCases}}
        <div class="test-row">
            <div>
                <strong>{{.Name}}</strong>
                <div class="duration">Duration: {{.Duration}}</div>
            </div>
            <div class="status-{{.Status}}">{{.Status}}</div>
        </div>
        {{end}}
    </div>
</body>
</html>`
    
    dashboardFile := filepath.Join(outputDir, "dashboard.html")
    err := os.WriteFile(dashboardFile, []byte(dashboardHTML), 0644)
    assert.NoError(t, err)
}
```

### Team-Specific Report Generation

```go
func TestTeamSpecificReports(t *testing.T) {
    // Generate developer-focused report
    devReport := fmt.Sprintf(`# Developer Test Report

## Summary
- **Suite**: %s
- **Total Tests**: %d
- **Passed**: %d ✅
- **Failed**: %d ❌
- **Success Rate**: %.1f%%

## Failed Tests (Requires Attention)
`, testResults.SuiteName, testResults.TotalTests, testResults.PassedTests, 
    testResults.FailedTests, float64(testResults.PassedTests)/float64(testResults.TotalTests)*100)
    
    for _, testCase := range testResults.TestCases {
        if testCase.Status == gowright.TestStatusFailed {
            devReport += fmt.Sprintf(`
### %s
- **Duration**: %.3fs
- **Error**: %s
- **Screenshots**: %d
- **Logs**: %d entries
`, testCase.Name, testCase.Duration.Seconds(), 
                func() string { 
                    if testCase.Error != nil { 
                        return testCase.Error.Error() 
                    } 
                    return "No error message" 
                }(),
                len(testCase.Screenshots), len(testCase.Logs))
        }
    }
    
    // Generate manager summary report
    managerReport := fmt.Sprintf(`# Management Test Summary

## Executive Summary
Test suite "%s" completed with **%.1f%% success rate**.

## Key Metrics
- Total test cases executed: **%d**
- Successful tests: **%d**
- Failed tests: **%d**
- Test execution time: **%.1f seconds**

## Status
%s

## Next Actions
%s
`, testResults.SuiteName, 
        float64(testResults.PassedTests)/float64(testResults.TotalTests)*100,
        testResults.TotalTests, testResults.PassedTests, testResults.FailedTests,
        testResults.EndTime.Sub(testResults.StartTime).Seconds(),
        func() string {
            if testResults.FailedTests == 0 {
                return "🟢 All tests passing - system is stable"
            } else if testResults.FailedTests <= 2 {
                return "🟡 Minor issues detected - development team investigating"
            } else {
                return "🔴 Multiple test failures - immediate attention required"
            }
        }(),
        func() string {
            if testResults.FailedTests == 0 {
                return "- Continue with planned deployment\n- Monitor system performance"
            } else {
                return "- Development team to investigate failures\n- Hold deployment until issues resolved"
            }
        }())
    
    // Write team-specific reports
    devReportFile := filepath.Join(outputDir, "developer-report.md")
    os.WriteFile(devReportFile, []byte(devReport), 0644)
    
    managerReportFile := filepath.Join(outputDir, "manager-summary.md")
    os.WriteFile(managerReportFile, []byte(managerReport), 0644)
}
```

### Trend Analysis Reporting

```go
func TestTrendAnalysisReporting(t *testing.T) {
    // Generate trend analysis with historical comparison
    trendData := fmt.Sprintf(`# Test Trend Analysis

## Current Run
- **Date**: %s
- **Success Rate**: %.1f%%
- **Duration**: %.1fs
- **Total Tests**: %d

## Historical Comparison
| Date | Success Rate | Duration | Total Tests | Status |
|------|-------------|----------|-------------|---------|
| %s | %.1f%% | %.1fs | %d | Current |
| 2024-01-15 | 87.5%% | 145.2s | 8 | Previous |
| 2024-01-14 | 100.0%% | 132.8s | 8 | Baseline |
| 2024-01-13 | 75.0%% | 167.3s | 8 | Issue Day |

## Trends
- **Success Rate Trend**: %s
- **Performance Trend**: %s
- **Stability**: %s

## Recommendations
%s
`, testResults.StartTime.Format("2006-01-02"),
        float64(testResults.PassedTests)/float64(testResults.TotalTests)*100,
        testResults.EndTime.Sub(testResults.StartTime).Seconds(),
        testResults.TotalTests,
        testResults.StartTime.Format("2006-01-02"),
        float64(testResults.PassedTests)/float64(testResults.TotalTests)*100,
        testResults.EndTime.Sub(testResults.StartTime).Seconds(),
        testResults.TotalTests,
        // Trend analysis logic...
        func() string {
            rate := float64(testResults.PassedTests)/float64(testResults.TotalTests)*100
            if rate >= 90 {
                return "📈 Improving (above 90%)"
            } else if rate >= 75 {
                return "📊 Stable (75-90%)"
            } else {
                return "📉 Declining (below 75%)"
            }
        }(),
        func() string {
            duration := testResults.EndTime.Sub(testResults.StartTime).Seconds()
            if duration < 140 {
                return "⚡ Fast execution (under 140s)"
            } else if duration < 160 {
                return "⏱️ Normal execution (140-160s)"
            } else {
                return "🐌 Slow execution (over 160s)"
            }
        }(),
        func() string {
            if testResults.FailedTests == 0 {
                return "🟢 Highly stable"
            } else if testResults.FailedTests <= 2 {
                return "🟡 Moderately stable"
            } else {
                return "🔴 Unstable"
            }
        }(),
        func() string {
            if testResults.FailedTests == 0 {
                return "- Maintain current quality practices\n- Consider expanding test coverage"
            } else {
                return "- Investigate root cause of failures\n- Implement additional monitoring\n- Review test maintenance practices"
            }
        }())
    
    trendFile := filepath.Join(outputDir, "trend-analysis.md")
    os.WriteFile(trendFile, []byte(trendData), 0644)
}
```

### Custom Report Templates

```go
func TestCustomReportTemplate(t *testing.T) {
    // Define custom report template
    customTemplate := `
<!DOCTYPE html>
<html>
<head>
    <title>{{.TestSuite.Name}} - Custom Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #f0f0f0; padding: 20px; border-radius: 5px; }
        .summary { margin: 20px 0; }
        .test { margin: 10px 0; padding: 10px; border-left: 4px solid #ccc; }
        .passed { border-left-color: #28a745; }
        .failed { border-left-color: #dc3545; }
        .metrics { background: #f8f9fa; padding: 15px; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>{{.TestSuite.Name}}</h1>
        <p>{{.TestSuite.Description}}</p>
        <p>Executed: {{.Summary.StartTime.Format "2006-01-02 15:04:05"}}</p>
    </div>
    
    <div class="summary">
        <h2>Summary</h2>
        <p>Total Tests: {{.Summary.TotalTests}}</p>
        <p>Passed: {{.Summary.PassedTests}}</p>
        <p>Failed: {{.Summary.FailedTests}}</p>
        <p>Duration: {{.Summary.Duration}}</p>
    </div>
    
    <div class="tests">
        <h2>Test Results</h2>
        {{range .Tests}}
        <div class="test {{if eq .Status "passed"}}passed{{else}}failed{{end}}">
            <h3>{{.Name}}</h3>
            <p>Status: {{.Status}}</p>
            <p>Duration: {{.Duration}}</p>
            {{if .Error}}
            <p>Error: {{.Error}}</p>
            {{end}}
        </div>
        {{end}}
    </div>
    
    {{if .Metrics}}
    <div class="metrics">
        <h2>Performance Metrics</h2>
        <p>Average Response Time: {{.Metrics.AverageResponseTime}}</p>
        <p>Total Requests: {{.Metrics.TotalRequests}}</p>
        <p>Error Rate: {{.Metrics.ErrorRate}}%</p>
    </div>
    {{end}}
</body>
</html>
`
    
    // Create custom reporter
    customReporter := &CustomTemplateReporter{
        Template: customTemplate,
    }
    
    framework := gowright.NewWithDefaults()
    defer framework.Close()
    
    testSuite := createSampleTestSuite(framework)
    framework.SetTestSuite(testSuite)
    results, err := framework.ExecuteTestSuite()
    assert.NoError(t, err)
    
    // Generate custom report
    err = customReporter.GenerateReport(results, "./test-reports/custom-report.html")
    assert.NoError(t, err)
    
    assert.FileExists(t, "./test-reports/custom-report.html")
}

type CustomTemplateReporter struct {
    Template string
}

func (r *CustomTemplateReporter) GenerateReport(results *gowright.TestSuiteResults, outputPath string) error {
    tmpl, err := template.New("custom").Parse(r.Template)
    if err != nil {
        return err
    }
    
    file, err := os.Create(outputPath)
    if err != nil {
        return err
    }
    defer file.Close()
    
    return tmpl.Execute(file, results)
}
```

### Multi-Format Reporter

```go
func TestMultiFormatReporter(t *testing.T) {
    multiReporter := &MultiFormatReporter{
        Formats: []gowright.ReportFormat{
            {Type: "html", OutputPath: "./test-reports/report.html"},
            {Type: "json", OutputPath: "./test-reports/report.json"},
            {Type: "junit", OutputPath: "./test-reports/junit.xml"},
            {Type: "pdf", OutputPath: "./test-reports/report.pdf"},
        },
    }
    
    framework := gowright.NewWithDefaults()
    defer framework.Close()
    
    testSuite := createSampleTestSuite(framework)
    framework.SetTestSuite(testSuite)
    results, err := framework.ExecuteTestSuite()
    assert.NoError(t, err)
    
    // Generate all report formats
    err = multiReporter.GenerateReports(results)
    assert.NoError(t, err)
    
    // Verify all formats were generated
    assert.FileExists(t, "./test-reports/report.html")
    assert.FileExists(t, "./test-reports/report.json")
    assert.FileExists(t, "./test-reports/junit.xml")
    assert.FileExists(t, "./test-reports/report.pdf")
}

type MultiFormatReporter struct {
    Formats []gowright.ReportFormat
}

func (r *MultiFormatReporter) GenerateReports(results *gowright.TestSuiteResults) error {
    for _, format := range r.Formats {
        var reporter gowright.TestReporter
        
        switch format.Type {
        case "html":
            reporter = gowright.NewHTMLReporter(nil)
        case "json":
            reporter = gowright.NewJSONReporter(nil)
        case "junit":
            reporter = gowright.NewJUnitReporter(nil)
        case "pdf":
            reporter = gowright.NewPDFReporter(nil)
        default:
            continue
        }
        
        if err := reporter.GenerateReport(results, format.OutputPath); err != nil {
            return fmt.Errorf("failed to generate %s report: %w", format.Type, err)
        }
    }
    
    return nil
}
```

## Report Configuration

### Comprehensive Report Configuration

```json
{
  "report_config": {
    "local_reports": {
      "html": true,
      "json": true,
      "xml": true,
      "pdf": false,
      "output_dir": "./test-reports",
      "html_config": {
        "theme": "modern",
        "include_charts": true,
        "include_logs": true,
        "include_metrics": true,
        "embed_assets": true,
        "generate_index": true,
        "performance_dashboard": true,
        "visual_testing": {
          "include_screenshots": true,
          "include_comparisons": true,
          "include_differences": true,
          "generate_thumbnails": true,
          "comparison_threshold": 0.1
        },
        "trend_analysis": {
          "enabled": true,
          "history_days": 30,
          "include_charts": true,
          "compare_baseline": true,
          "history_dir": "./test-history"
        },
        "chart_config": {
          "response_time_chart": true,
          "throughput_chart": true,
          "error_rate_chart": true,
          "resource_usage_chart": true,
          "timeline_chart": true
        }
      },
      "json_config": {
        "pretty": true,
        "include_metrics": true,
        "include_logs": true,
        "include_payloads": true
      },
      "xml_config": {
        "format": "junit",
        "include_stdout": true,
        "include_stderr": true,
        "include_system": true
      }
    },
    "remote_reports": {
      "jira_xray": {
        "url": "https://your-jira.atlassian.net",
        "username": "${JIRA_USERNAME}",
        "password": "${JIRA_API_TOKEN}",
        "project_key": "TEST",
        "test_plan": "TEST-123",
        "version": "1.0.0",
        "environment": "staging"
      },
      "slack": {
        "webhook_url": "${SLACK_WEBHOOK_URL}",
        "channel": "#test-results",
        "username": "Gowright Bot",
        "icon_emoji": ":robot_face:",
        "notify_on": ["failure", "completion"],
        "include_metrics": true,
        "include_charts": true
      },
      "custom_dashboard": {
        "url": "https://dashboard.example.com/api/test-results",
        "api_key": "${DASHBOARD_API_KEY}",
        "format": "json",
        "headers": {
          "Content-Type": "application/json",
          "X-Source": "gowright"
        }
      }
    }
  }
}
```

### Assertion-Focused Reporting

```go
func TestAssertionFocusedReporting(t *testing.T) {
    // Create test with detailed assertion tracking
    ta := gowright.NewTestAssertion("Comprehensive API Test")
    
    // Perform assertions with detailed logging
    apiResponse := map[string]interface{}{
        "status": "success",
        "data": map[string]interface{}{
            "user_id": 12345,
            "name":    "John Doe",
            "email":   "john.doe@example.com",
            "active":  true,
        },
        "items": []string{"item1", "item2", "item3"},
    }
    
    // API response validation
    ta.Equal("success", apiResponse["status"], "API should return success status")
    ta.NotNil(apiResponse["data"], "API response should contain data")
    ta.Contains(apiResponse["message"].(string), "completed", "Message should indicate completion")
    ta.Len(apiResponse["items"], 3, "Should return exactly 3 items")
    
    // User data validation
    userData := apiResponse["data"].(map[string]interface{})
    ta.NotEmpty(userData["name"], "User name should not be empty")
    ta.True(userData["user_id"].(int) > 0, "User ID should be positive")
    ta.Contains(userData["email"].(string), "@", "Email should contain @ symbol")
    ta.Regexp(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`, 
        userData["email"].(string), "Email should match valid pattern")
    
    // Numeric validations
    userID := userData["user_id"].(int)
    ta.GreaterThan(userID, 0, "User ID should be greater than 0")
    ta.LessThan(userID, 100000, "User ID should be less than 100000")
    ta.InRange(userID, 1, 99999, "User ID should be in valid range")
    
    // String validations
    userName := userData["name"].(string)
    ta.MinLength(userName, 2, "User name should be at least 2 characters")
    ta.MaxLength(userName, 50, "User name should not exceed 50 characters")
    ta.DoesNotContain(userName, "@", "User name should not contain @ symbol")
    
    // Generate test result with assertion details
    status := gowright.TestStatusPassed
    var testError error
    if ta.HasFailures() {
        status = gowright.TestStatusFailed
        passed, failed := ta.GetSummary()
        testError = fmt.Errorf("test failed with %d assertion failures out of %d total assertions", 
            failed, passed+failed)
    }
    
    result := &gowright.TestCaseResult{
        Name:      "Comprehensive API Test",
        Status:    status,
        Duration:  time.Since(startTime),
        Error:     testError,
        StartTime: startTime,
        EndTime:   time.Now(),
        Logs:      ta.GetLogs(),
        Steps:     ta.GetSteps(), // Contains individual assertion results
    }
    
    // Generate assertion-focused report
    config := &gowright.ReportConfig{
        LocalReports: gowright.LocalReportConfig{
            HTML: true,
            JSON: true,
            OutputDir: "./test-reports/assertions",
            HTMLConfig: &gowright.HTMLReportConfig{
                IncludeAssertionDetails: true,
                ShowAssertionTimeline:   true,
                GroupAssertionsByType:   true,
            },
        },
    }
    
    reportManager := gowright.NewReportManager(config)
    testResults := &gowright.TestResults{
        SuiteName: "Assertion-Focused Test Suite",
        TestCases: []gowright.TestCaseResult{*result},
    }
    
    err := reportManager.GenerateReports(testResults)
    assert.NoError(t, err)
}
```

## Best Practices

### 1. Choose Appropriate Report Formats

```go
// Good - Multiple formats for different audiences
config := &gowright.ReportConfig{
    LocalReports: gowright.LocalReportConfig{
        HTML: true, // For developers and manual review
        JSON: true, // For automation and integration
        XML:  true, // For CI/CD systems
    },
}
```

### 2. Include Relevant Context

```go
// Good - Rich context in reports
testSuite := &gowright.TestSuite{
    Name:        "User Management API Tests",
    Description: "Comprehensive tests for user management functionality",
    Environment: map[string]string{
        "API_VERSION": "v2.1",
        "TEST_ENV":    "staging",
        "BUILD_ID":    os.Getenv("BUILD_ID"),
    },
    Tags: []string{"api", "user-management", "regression"},
}
```

### 3. Organize Report Output

```go
// Good - Organized directory structure
config := &gowright.ReportConfig{
    LocalReports: gowright.LocalReportConfig{
        OutputDir: fmt.Sprintf("./test-reports/%s", time.Now().Format("2006-01-02")),
        HTMLConfig: &gowright.HTMLReportConfig{
            GenerateIndex: true, // Create index of all reports
        },
    },
}
```

### 4. Configure for Environment

```go
// Good - Environment-specific reporting
func getReportConfig(env string) *gowright.ReportConfig {
    config := &gowright.ReportConfig{
        LocalReports: gowright.LocalReportConfig{
            HTML: true,
            JSON: true,
        },
    }
    
    switch env {
    case "production":
        // Minimal reporting for production
        config.LocalReports.HTMLConfig = &gowright.HTMLReportConfig{
            IncludeLogs: false,
            EmbedAssets: true,
        }
    case "development":
        // Detailed reporting for development
        config.LocalReports.HTMLConfig = &gowright.HTMLReportConfig{
            IncludeLogs:     true,
            IncludeMetrics:  true,
            IncludeCharts:   true,
        }
    }
    
    return config
}
```

### 5. Secure Sensitive Information

```go
// Good - Sanitize sensitive data in reports
config := &gowright.ReportConfig{
    LocalReports: gowright.LocalReportConfig{
        JSONConfig: &gowright.JSONReportConfig{
            SanitizeHeaders: []string{"Authorization", "X-API-Key"},
            SanitizeFields:  []string{"password", "token", "secret"},
        },
    },
}
```

### 6. Use Multi-Format Reporting for Different Audiences

```go
// Good - Generate multiple report formats for different stakeholders
func generateComprehensiveReports(testResults *gowright.TestResults) error {
    // Standard reports for developers
    standardConfig := &gowright.ReportConfig{
        LocalReports: gowright.LocalReportConfig{
            HTML: true,
            JSON: true,
            OutputDir: "./reports/standard",
        },
    }
    
    // XML/JUnit for CI/CD systems
    xmlConfig := &gowright.ReportConfig{
        LocalReports: gowright.LocalReportConfig{
            XML: true,
            OutputDir: "./reports/ci-cd",
            XMLConfig: &gowright.XMLReportConfig{
                Format: "junit",
                IncludeStdout: true,
            },
        },
    }
    
    // CSV for data analysis
    csvReporter := NewCSVReporter("./reports/analytics")
    csvReporter.GenerateTestSummary(testResults)
    csvReporter.GenerateMetricsReport(testResults)
    
    // Team-specific reports
    teamReporter := NewTeamReporter("./reports/team")
    teamReporter.GenerateDeveloperReport(testResults)
    teamReporter.GenerateManagerSummary(testResults)
    
    return nil
}
```

### 7. Implement Trend Analysis for Continuous Improvement

```go
// Good - Track test trends over time
func generateTrendAnalysis(testResults *gowright.TestResults) error {
    historyManager := gowright.NewTestHistoryManager("./test-history")
    
    // Store current results
    err := historyManager.StoreResults(testResults)
    if err != nil {
        return err
    }
    
    // Generate trend analysis
    trendData, err := historyManager.GetTrendData(30) // Last 30 days
    if err != nil {
        return err
    }
    
    trendReporter := NewTrendAnalysisReporter("./reports/trends")
    return trendReporter.GenerateReport(trendData)
}
```

### 8. Customize Reports for Specific Use Cases

```go
// Good - Create specialized reports for different scenarios
func generateSpecializedReports(testResults *gowright.TestResults) error {
    // Performance-focused report
    if containsPerformanceTests(testResults) {
        perfReporter := NewPerformanceReporter("./reports/performance")
        perfReporter.GenerateDashboard(testResults)
    }
    
    // Security-focused report
    if containsSecurityTests(testResults) {
        secReporter := NewSecurityReporter("./reports/security")
        secReporter.GenerateComplianceReport(testResults)
    }
    
    // Accessibility-focused report
    if containsAccessibilityTests(testResults) {
        a11yReporter := NewAccessibilityReporter("./reports/accessibility")
        a11yReporter.GenerateWCAGReport(testResults)
    }
    
    return nil
}
```

## Troubleshooting

### Common Issues

**Large report files:**
```go
// Reduce report size
config := &gowright.HTMLReportConfig{
    EmbedAssets:     false, // Link to external assets
    IncludeLogs:     false, // Exclude verbose logs
    CompressAssets:  true,  // Compress CSS/JS
}
```

**Missing screenshots:**
```go
// Ensure screenshot directory exists
config := &gowright.HTMLReportConfig{
    VisualTesting: &gowright.VisualTestingConfig{
        ScreenshotDir: "./test-reports/screenshots",
        CreateDirs:    true, // Auto-create directories
    },
}
```

**Remote reporting failures:**
```go
// Add retry logic for remote reporting
config := &gowright.JiraXrayConfig{
    RetryConfig: &gowright.RetryConfig{
        MaxRetries:   3,
        InitialDelay: 1 * time.Second,
    },
}
```

## Next Steps

- [Parallel Execution](parallel-execution.md) - Optimize test performance
- [Resource Management](resource-management.md) - Monitor resource usage
- [Examples](../examples/basic-usage.md) - Reporting examples
- [Best Practices](../reference/best-practices.md) - Reporting best practices