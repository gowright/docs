# Plugin Development

The Gowright framework supports a flexible plugin system that allows you to extend functionality with custom plugins for metrics collection, notifications, reporting, and business logic validation.

## Plugin Architecture

```mermaid
graph TB
    subgraph "Gowright Framework"
        A[Framework Core] --> B[Plugin Manager]
        B --> C[Plugin Registry]
        B --> D[Plugin Lifecycle]
    end
    
    subgraph "Plugin Types"
        E[Metrics Plugin]
        F[Notification Plugin]
        G[Reporting Plugin]
        H[Business Logic Plugin]
        I[Custom Plugin]
    end
    
    subgraph "Plugin Interface"
        J[Plugin Interface]
        J --> J1[GetName()]
        J --> J2[Initialize()]
        J --> J3[Cleanup()]
    end
    
    B --> E
    B --> F
    B --> G
    B --> H
    B --> I
    
    E --> J
    F --> J
    G --> J
    H --> J
    I --> J
```

## Basic Plugin Interface

All plugins must implement the basic Plugin interface:

```go
type Plugin interface {
    GetName() string
    Initialize(config interface{}) error
    Cleanup() error
}
```

## Plugin Types

### Metrics Plugin

Collect custom performance and execution metrics:

```go
type MetricsPlugin struct {
    collecting bool
    metrics    map[string]interface{}
    startTime  time.Time
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
    p.startTime = time.Now()
    return nil
}

func (p *MetricsPlugin) Cleanup() error {
    fmt.Println("Metrics plugin cleaned up")
    return nil
}

func (p *MetricsPlugin) StartCollection() {
    p.collecting = true
    p.metrics["collection_started"] = time.Now()
    fmt.Println("Started metrics collection")
}

func (p *MetricsPlugin) StopCollection() {
    p.collecting = false
    p.metrics["collection_stopped"] = time.Now()
    p.metrics["collection_duration"] = time.Since(p.startTime)
    fmt.Println("Stopped metrics collection")
}

func (p *MetricsPlugin) RecordMetric(name string, value interface{}) {
    if p.collecting {
        p.metrics[name] = value
    }
}

func (p *MetricsPlugin) GetMetrics() map[string]interface{} {
    return p.metrics
}

// Usage example
func useMetricsPlugin() {
    framework := gowright.NewFramework()
    
    // Add metrics plugin
    metricsPlugin := NewMetricsPlugin()
    framework.AddPlugin("metrics", metricsPlugin)
    
    // Initialize framework
    config := gowright.DefaultConfig()
    err := framework.Initialize(config)
    if err != nil {
        log.Fatalf("Failed to initialize framework: %v", err)
    }
    defer framework.Close()
    
    // Use the plugin
    plugin := framework.GetPlugin("metrics").(*MetricsPlugin)
    plugin.StartCollection()
    
    // Record custom metrics during test execution
    plugin.RecordMetric("test_count", 10)
    plugin.RecordMetric("success_rate", 0.95)
    
    plugin.StopCollection()
    metrics := plugin.GetMetrics()
    fmt.Printf("Collected metrics: %+v\n", metrics)
}
```

### Notification Plugin

Send alerts and notifications to external systems:

```go
type NotificationPlugin struct {
    webhookURL string
    slackToken string
    enabled    bool
    client     *http.Client
}

func NewNotificationPlugin(webhookURL, slackToken string) *NotificationPlugin {
    return &NotificationPlugin{
        webhookURL: webhookURL,
        slackToken: slackToken,
        enabled:    true,
        client:     &http.Client{Timeout: 10 * time.Second},
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

func (p *NotificationPlugin) SendSlackNotification(message string) error {
    if !p.enabled || p.webhookURL == "" {
        return nil
    }
    
    payload := map[string]interface{}{
        "text": message,
        "username": "Gowright Bot",
        "icon_emoji": ":robot_face:",
    }
    
    jsonPayload, err := json.Marshal(payload)
    if err != nil {
        return fmt.Errorf("failed to marshal payload: %w", err)
    }
    
    resp, err := p.client.Post(p.webhookURL, "application/json", bytes.NewBuffer(jsonPayload))
    if err != nil {
        return fmt.Errorf("failed to send notification: %w", err)
    }
    defer resp.Body.Close()
    
    if resp.StatusCode != http.StatusOK {
        return fmt.Errorf("notification failed with status: %d", resp.StatusCode)
    }
    
    fmt.Printf("Sent Slack notification: %s\n", message)
    return nil
}

func (p *NotificationPlugin) SendTestResults(results TestResults) error {
    message := fmt.Sprintf("Test Results: %d passed, %d failed, %d total", 
        results.PassedTests, results.FailedTests, results.TotalTests)
    
    if results.FailedTests > 0 {
        message += " :warning:"
    } else {
        message += " :white_check_mark:"
    }
    
    return p.SendSlackNotification(message)
}

// Usage example
func useNotificationPlugin() {
    framework := gowright.NewFramework()
    
    // Add notification plugin
    notificationPlugin := NewNotificationPlugin(
        "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK",
        "xoxb-your-slack-token",
    )
    framework.AddPlugin("notifications", notificationPlugin)
    
    // Initialize and use
    config := gowright.DefaultConfig()
    framework.Initialize(config)
    defer framework.Close()
    
    // Send notifications during test execution
    plugin := framework.GetPlugin("notifications").(*NotificationPlugin)
    plugin.SendSlackNotification("Starting test execution...")
    
    // After tests complete
    results := TestResults{PassedTests: 8, FailedTests: 2, TotalTests: 10}
    plugin.SendTestResults(results)
}
```

### Reporting Plugin

Generate custom report formats and destinations:

```go
type CustomReportingPlugin struct {
    outputDir    string
    format       string
    templatePath string
}

func NewCustomReportingPlugin(outputDir, format string) *CustomReportingPlugin {
    return &CustomReportingPlugin{
        outputDir: outputDir,
        format:    format,
    }
}

func (p *CustomReportingPlugin) GetName() string {
    return "CustomReportingPlugin"
}

func (p *CustomReportingPlugin) Initialize(config interface{}) error {
    // Create output directory if it doesn't exist
    if err := os.MkdirAll(p.outputDir, 0755); err != nil {
        return fmt.Errorf("failed to create output directory: %w", err)
    }
    
    fmt.Printf("Custom reporting plugin initialized - Output: %s, Format: %s\n", 
        p.outputDir, p.format)
    return nil
}

func (p *CustomReportingPlugin) Cleanup() error {
    fmt.Println("Custom reporting plugin cleaned up")
    return nil
}

func (p *CustomReportingPlugin) GenerateJSONReport(results interface{}) error {
    filename := filepath.Join(p.outputDir, fmt.Sprintf("test-report-%d.json", time.Now().Unix()))
    
    jsonData, err := json.MarshalIndent(results, "", "  ")
    if err != nil {
        return fmt.Errorf("failed to marshal results: %w", err)
    }
    
    if err := ioutil.WriteFile(filename, jsonData, 0644); err != nil {
        return fmt.Errorf("failed to write report: %w", err)
    }
    
    fmt.Printf("Generated JSON report: %s\n", filename)
    return nil
}

func (p *CustomReportingPlugin) GenerateHTMLReport(results interface{}) error {
    filename := filepath.Join(p.outputDir, fmt.Sprintf("test-report-%d.html", time.Now().Unix()))
    
    htmlTemplate := `
<!DOCTYPE html>
<html>
<head>
    <title>Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f0f0f0; padding: 10px; border-radius: 5px; }
        .passed { color: green; }
        .failed { color: red; }
        .summary { margin: 20px 0; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Gowright Test Report</h1>
        <p>Generated: {{.Timestamp}}</p>
    </div>
    <div class="summary">
        <h2>Summary</h2>
        <p>Total Tests: {{.TotalTests}}</p>
        <p class="passed">Passed: {{.PassedTests}}</p>
        <p class="failed">Failed: {{.FailedTests}}</p>
    </div>
</body>
</html>
`
    
    tmpl, err := template.New("report").Parse(htmlTemplate)
    if err != nil {
        return fmt.Errorf("failed to parse template: %w", err)
    }
    
    file, err := os.Create(filename)
    if err != nil {
        return fmt.Errorf("failed to create file: %w", err)
    }
    defer file.Close()
    
    data := map[string]interface{}{
        "Timestamp": time.Now().Format("2006-01-02 15:04:05"),
        "Results":   results,
    }
    
    if err := tmpl.Execute(file, data); err != nil {
        return fmt.Errorf("failed to execute template: %w", err)
    }
    
    fmt.Printf("Generated HTML report: %s\n", filename)
    return nil
}

func (p *CustomReportingPlugin) GenerateReport(results interface{}) error {
    switch p.format {
    case "json":
        return p.GenerateJSONReport(results)
    case "html":
        return p.GenerateHTMLReport(results)
    default:
        return fmt.Errorf("unsupported format: %s", p.format)
    }
}
```

### Business Logic Plugin

Implement domain-specific validation rules:

```go
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
    
    // Add default business rules
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
    
    plugin.AddRule("valid_email", BusinessRule{
        Name:        "Valid Email Format",
        Description: "Email must be in valid format",
        Validator: func(data map[string]interface{}) error {
            if email, ok := data["email"].(string); ok {
                emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
                if !emailRegex.MatchString(email) {
                    return fmt.Errorf("invalid email format: %s", email)
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
    fmt.Printf("Business logic plugin initialized with %d rules\n", len(p.rules))
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
    var errors []string
    
    for name, rule := range p.rules {
        if err := rule.Validator(data); err != nil {
            errors = append(errors, fmt.Sprintf("Rule '%s': %s", name, err.Error()))
        }
    }
    
    if len(errors) > 0 {
        return fmt.Errorf("business validation failed: %s", strings.Join(errors, "; "))
    }
    
    return nil
}

func (p *BusinessLogicPlugin) GetRules() map[string]BusinessRule {
    return p.rules
}

// Usage example
func useBusinessLogicPlugin() {
    framework := gowright.NewFramework()
    
    // Add business logic plugin
    businessPlugin := NewBusinessLogicPlugin()
    framework.AddPlugin("business", businessPlugin)
    
    config := gowright.DefaultConfig()
    framework.Initialize(config)
    defer framework.Close()
    
    // Use the business plugin
    plugin := framework.GetPlugin("business").(*BusinessLogicPlugin)
    
    // Validate business rules
    testData := map[string]interface{}{
        "user_id":       123,
        "email":         "user@example.com",
        "order_total":   99.99,
        "discount_code": "SAVE10",
    }
    
    err := plugin.ValidateBusinessRules(testData)
    if err != nil {
        fmt.Printf("Business validation failed: %v\n", err)
    } else {
        fmt.Println("Business validation passed")
    }
}
```

## Plugin Registration and Usage

### Adding Plugins to Framework

```go
func createFrameworkWithPlugins() *gowright.Framework {
    framework := gowright.NewFramework()
    
    // Add built-in testers
    framework.AddTester("api", api.NewTester())
    framework.AddTester("database", database.NewTester())
    
    // Add custom plugins
    framework.AddPlugin("metrics", NewMetricsPlugin())
    framework.AddPlugin("notifications", NewNotificationPlugin(
        "https://hooks.slack.com/services/...",
        "xoxb-token",
    ))
    framework.AddPlugin("reporting", NewCustomReportingPlugin("./reports", "html"))
    framework.AddPlugin("business", NewBusinessLogicPlugin())
    
    return framework
}
```

### Plugin Lifecycle Management

```go
func managePluginLifecycle() {
    framework := createFrameworkWithPlugins()
    
    // Initialize framework (initializes all plugins)
    config := gowright.DefaultConfig()
    err := framework.Initialize(config)
    if err != nil {
        log.Fatalf("Failed to initialize framework: %v", err)
    }
    
    // Use plugins during test execution
    metricsPlugin := framework.GetPlugin("metrics").(*MetricsPlugin)
    notificationPlugin := framework.GetPlugin("notifications").(*NotificationPlugin)
    reportingPlugin := framework.GetPlugin("reporting").(*CustomReportingPlugin)
    businessPlugin := framework.GetPlugin("business").(*BusinessLogicPlugin)
    
    // Start metrics collection
    metricsPlugin.StartCollection()
    
    // Send start notification
    notificationPlugin.SendSlackNotification("Test execution started")
    
    // Execute tests with business validation
    testData := map[string]interface{}{
        "order_total": 25.99,
        "email":       "test@example.com",
    }
    
    err = businessPlugin.ValidateBusinessRules(testData)
    if err != nil {
        log.Printf("Business validation failed: %v", err)
    }
    
    // Record metrics
    metricsPlugin.RecordMetric("validation_passed", err == nil)
    
    // Stop metrics and generate reports
    metricsPlugin.StopCollection()
    metrics := metricsPlugin.GetMetrics()
    
    reportingPlugin.GenerateReport(metrics)
    
    // Send completion notification
    notificationPlugin.SendSlackNotification("Test execution completed")
    
    // Cleanup (automatically called on framework.Close())
    framework.Close()
}
```

## Advanced Plugin Patterns

### Plugin Configuration

```go
type PluginConfig struct {
    Enabled    bool                   `json:"enabled"`
    Settings   map[string]interface{} `json:"settings"`
    OutputPath string                 `json:"output_path,omitempty"`
}

type ConfigurablePlugin struct {
    name   string
    config *PluginConfig
}

func (p *ConfigurablePlugin) Initialize(config interface{}) error {
    if pluginConfig, ok := config.(*PluginConfig); ok {
        p.config = pluginConfig
        if !p.config.Enabled {
            return fmt.Errorf("plugin %s is disabled", p.name)
        }
    }
    return nil
}
```

### Plugin Dependencies

```go
type DependentPlugin struct {
    name         string
    dependencies []string
    framework    *gowright.Framework
}

func (p *DependentPlugin) Initialize(config interface{}) error {
    // Check if dependencies are available
    for _, dep := range p.dependencies {
        if p.framework.GetPlugin(dep) == nil {
            return fmt.Errorf("required dependency %s not found", dep)
        }
    }
    return nil
}
```

### Plugin Communication

```go
type EventPlugin struct {
    name      string
    listeners map[string][]func(interface{})
}

func (p *EventPlugin) Subscribe(event string, handler func(interface{})) {
    if p.listeners == nil {
        p.listeners = make(map[string][]func(interface{}))
    }
    p.listeners[event] = append(p.listeners[event], handler)
}

func (p *EventPlugin) Emit(event string, data interface{}) {
    if handlers, exists := p.listeners[event]; exists {
        for _, handler := range handlers {
            go handler(data) // Async execution
        }
    }
}
```

## Best Practices

### Plugin Development Guidelines

1. **Single Responsibility**: Each plugin should have a single, well-defined purpose
2. **Error Handling**: Implement comprehensive error handling and logging
3. **Configuration**: Support configuration through the Initialize method
4. **Resource Management**: Properly clean up resources in the Cleanup method
5. **Thread Safety**: Ensure plugins are thread-safe if used in parallel execution
6. **Documentation**: Document plugin functionality, configuration, and usage

### Performance Considerations

1. **Lazy Initialization**: Initialize expensive resources only when needed
2. **Resource Pooling**: Use connection pools for external services
3. **Async Operations**: Use goroutines for non-blocking operations
4. **Memory Management**: Avoid memory leaks in long-running plugins
5. **Caching**: Cache frequently accessed data appropriately

### Testing Plugins

```go
func TestMetricsPlugin(t *testing.T) {
    plugin := NewMetricsPlugin()
    
    // Test initialization
    err := plugin.Initialize(nil)
    assert.NoError(t, err)
    
    // Test functionality
    plugin.StartCollection()
    plugin.RecordMetric("test_metric", 42)
    plugin.StopCollection()
    
    metrics := plugin.GetMetrics()
    assert.Contains(t, metrics, "test_metric")
    assert.Equal(t, 42, metrics["test_metric"])
    
    // Test cleanup
    err = plugin.Cleanup()
    assert.NoError(t, err)
}
```

This plugin system provides a powerful way to extend Gowright's functionality while maintaining clean separation of concerns and easy maintainability.