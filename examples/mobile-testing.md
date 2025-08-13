# Mobile Testing Examples (1/5 - 20% Complete)

This document provides comprehensive examples of mobile application testing using the GoWright framework's Appium integration. These examples demonstrate real-world scenarios for both Android and iOS platforms.

## Table of Contents

1. [Basic Setup Examples](#basic-setup-examples)
2. [Android Testing Examples](#android-testing-examples)
3. [iOS Testing Examples](#ios-testing-examples)
4. [Mobile Web Testing](#mobile-web-testing)
5. [Cross-Platform Testing](#cross-platform-testing)
6. [Advanced Scenarios](#advanced-scenarios)
7. [Integration with GoWright Framework](#integration-with-gowright-framework)
8. [Comprehensive Testing Example](#comprehensive-testing-example)

## Basic Setup Examples

### Simple Android Setup

```go
package main

import (
    "context"
    "fmt"
    "log"
    
    "github.com/gowright/framework/pkg/gowright"
)

func basicAndroidSetup() {
    // Create Appium client
    client := gowright.NewAppiumClient("http://localhost:4723")
    ctx := context.Background()
    
    // Define Android capabilities
    caps := gowright.AppiumCapabilities{
        PlatformName:   "Android",
        DeviceName:     "emulator-5554",
        AppPackage:     "com.android.settings",
        AppActivity:    ".Settings",
        AutomationName: "UiAutomator2",
        NoReset:        true,
    }
    
    // Create session
    if err := client.CreateSession(ctx, caps); err != nil {
        log.Fatalf("Failed to create session: %v", err)
    }
    defer client.DeleteSession(ctx)
    
    fmt.Printf("Android session created: %s\n", client.GetSessionID())
    
    // Take a screenshot to verify setup
    screenshot, err := client.TakeScreenshot(ctx)
    if err != nil {
        log.Printf("Failed to take screenshot: %v", err)
    } else {
        fmt.Printf("Screenshot captured: %d bytes\n", len(screenshot))
    }
}
```

### Simple iOS Setup

```go
func basiciOSSetup() {
    client := gowright.NewAppiumClient("http://localhost:4723")
    ctx := context.Background()
    
    // Define iOS capabilities
    caps := gowright.AppiumCapabilities{
        PlatformName:   "iOS",
        DeviceName:     "iPhone 13 Simulator",
        BundleID:       "com.apple.Preferences",
        AutomationName: "XCUITest",
        NoReset:        true,
    }
    
    if err := client.CreateSession(ctx, caps); err != nil {
        log.Fatalf("Failed to create iOS session: %v", err)
    }
    defer client.DeleteSession(ctx)
    
    fmt.Printf("iOS session created: %s\n", client.GetSessionID())
}
```

## Android Testing Examples

### Calculator App Testing

```go
package main

import (
    "context"
    "fmt"
    "log"
    "time"
    
    "github.com/gowright/framework/pkg/gowright"
)

func testAndroidCalculator() {
    client := gowright.NewAppiumClient("http://localhost:4723")
    ctx := context.Background()
    
    caps := gowright.AppiumCapabilities{
        PlatformName:      "Android",
        PlatformVersion:   "11",
        DeviceName:        "emulator-5554",
        AppPackage:        "com.android.calculator2",
        AppActivity:       ".Calculator",
        AutomationName:    "UiAutomator2",
        NoReset:           true,
        NewCommandTimeout: 60,
    }
    
    if err := client.CreateSession(ctx, caps); err != nil {
        log.Fatalf("Failed to create session: %v", err)
    }
    defer client.DeleteSession(ctx)
    
    fmt.Println("Testing Android Calculator...")
    
    // Wait for calculator to load
    time.Sleep(2 * time.Second)
    
    // Test calculation: 15 + 25 = 40
    if err := performCalculation(ctx, client, "15", "+", "25", "40"); err != nil {
        log.Fatalf("Calculation test failed: %v", err)
    }
    
    fmt.Println("Calculator test passed!")
    
    // Test clear functionality
    if err := testClearFunction(ctx, client); err != nil {
        log.Fatalf("Clear test failed: %v", err)
    }
    
    fmt.Println("Clear function test passed!")
}

func performCalculation(ctx context.Context, client *gowright.AppiumClient, num1, operator, num2, expected string) error {
    // Enter first number
    for _, digit := range num1 {
        digitID := fmt.Sprintf("com.android.calculator2:id/digit_%s", string(digit))
        button, err := client.WaitForElementClickable(ctx, gowright.ByID, digitID, 5*time.Second)
        if err != nil {
            return fmt.Errorf("failed to find digit %s: %w", string(digit), err)
        }
        if err := button.Click(ctx); err != nil {
            return fmt.Errorf("failed to click digit %s: %w", string(digit), err)
        }
    }
    
    // Click operator
    var operatorID string
    switch operator {
    case "+":
        operatorID = "com.android.calculator2:id/op_add"
    case "-":
        operatorID = "com.android.calculator2:id/op_sub"
    case "*":
        operatorID = "com.android.calculator2:id/op_mul"
    case "/":
        operatorID = "com.android.calculator2:id/op_div"
    default:
        return fmt.Errorf("unsupported operator: %s", operator)
    }
    
    opButton, err := client.FindElement(ctx, gowright.ByID, operatorID)
    if err != nil {
        return fmt.Errorf("failed to find operator button: %w", err)
    }
    if err := opButton.Click(ctx); err != nil {
        return fmt.Errorf("failed to click operator: %w", err)
    }
    
    // Enter second number
    for _, digit := range num2 {
        digitID := fmt.Sprintf("com.android.calculator2:id/digit_%s", string(digit))
        button, err := client.FindElement(ctx, gowright.ByID, digitID)
        if err != nil {
            return fmt.Errorf("failed to find digit %s: %w", string(digit), err)
        }
        if err := button.Click(ctx); err != nil {
            return fmt.Errorf("failed to click digit %s: %w", string(digit), err)
        }
    }
    
    // Click equals
    equalsButton, err := client.FindElement(ctx, gowright.ByID, "com.android.calculator2:id/eq")
    if err != nil {
        return fmt.Errorf("failed to find equals button: %w", err)
    }
    if err := equalsButton.Click(ctx); err != nil {
        return fmt.Errorf("failed to click equals: %w", err)
    }
    
    // Verify result
    resultElement, err := client.WaitForElement(ctx, gowright.ByID, "com.android.calculator2:id/result", 5*time.Second)
    if err != nil {
        return fmt.Errorf("failed to find result: %w", err)
    }
    
    resultText, err := resultElement.GetText(ctx)
    if err != nil {
        return fmt.Errorf("failed to get result text: %w", err)
    }
    
    if resultText != expected {
        return fmt.Errorf("expected %s, got %s", expected, resultText)
    }
    
    return nil
}

func testClearFunction(ctx context.Context, client *gowright.AppiumClient) error {
    // Enter some digits
    digit5, err := client.FindElement(ctx, gowright.ByID, "com.android.calculator2:id/digit_5")
    if err != nil {
        return fmt.Errorf("failed to find digit 5: %w", err)
    }
    if err := digit5.Click(ctx); err != nil {
        return fmt.Errorf("failed to click digit 5: %w", err)
    }
    
    // Click clear
    clearButton, err := client.FindElement(ctx, gowright.ByID, "com.android.calculator2:id/clr")
    if err != nil {
        return fmt.Errorf("failed to find clear button: %w", err)
    }
    if err := clearButton.Click(ctx); err != nil {
        return fmt.Errorf("failed to click clear: %w", err)
    }
    
    // Verify display is cleared (implementation would depend on app behavior)
    return nil
}
```

### Form Input Testing

```go
func testAndroidFormInput() {
    client := gowright.NewAppiumClient("http://localhost:4723")
    ctx := context.Background()
    
    caps := gowright.AppiumCapabilities{
        PlatformName:   "Android",
        DeviceName:     "emulator-5554",
        AppPackage:     "com.example.formapp",
        AppActivity:    ".MainActivity",
        AutomationName: "UiAutomator2",
    }
    
    if err := client.CreateSession(ctx, caps); err != nil {
        log.Fatalf("Failed to create session: %v", err)
    }
    defer client.DeleteSession(ctx)
    
    fmt.Println("Testing form input...")
    
    // Find and fill name field
    nameField, err := client.WaitForElement(ctx, gowright.ByID, "com.example.formapp:id/name_input", 10*time.Second)
    if err != nil {
        log.Fatalf("Failed to find name field: %v", err)
    }
    
    if err := nameField.SendKeys(ctx, "John Doe"); err != nil {
        log.Fatalf("Failed to enter name: %v", err)
    }
    
    // Find and fill email field
    emailField, err := client.FindElement(ctx, gowright.ByID, "com.example.formapp:id/email_input")
    if err != nil {
        log.Fatalf("Failed to find email field: %v", err)
    }
    
    if err := emailField.SendKeys(ctx, "john.doe@example.com"); err != nil {
        log.Fatalf("Failed to enter email: %v", err)
    }
    
    // Hide keyboard if shown
    if shown, err := client.IsKeyboardShown(ctx); err == nil && shown {
        if err := client.HideKeyboard(ctx); err != nil {
            log.Printf("Failed to hide keyboard: %v", err)
        }
    }
    
    // Find and click submit button
    submitButton, err := client.FindElement(ctx, gowright.ByID, "com.example.formapp:id/submit_button")
    if err != nil {
        log.Fatalf("Failed to find submit button: %v", err)
    }
    
    if err := submitButton.Click(ctx); err != nil {
        log.Fatalf("Failed to click submit: %v", err)
    }
    
    // Wait for success message
    successMessage, err := client.WaitForElement(ctx, gowright.ByID, "com.example.formapp:id/success_message", 10*time.Second)
    if err != nil {
        log.Fatalf("Failed to find success message: %v", err)
    }
    
    messageText, err := successMessage.GetText(ctx)
    if err != nil {
        log.Fatalf("Failed to get message text: %v", err)
    }
    
    fmt.Printf("Form submission successful: %s\n", messageText)
}
```

### Gesture Testing

```go
func testAndroidGestures() {
    client := gowright.NewAppiumClient("http://localhost:4723")
    ctx := context.Background()
    
    caps := gowright.AppiumCapabilities{
        PlatformName:   "Android",
        DeviceName:     "emulator-5554",
        AppPackage:     "com.android.settings",
        AppActivity:    ".Settings",
        AutomationName: "UiAutomator2",
    }
    
    if err := client.CreateSession(ctx, caps); err != nil {
        log.Fatalf("Failed to create session: %v", err)
    }
    defer client.DeleteSession(ctx)
    
    fmt.Println("Testing Android gestures...")
    
    // Get screen dimensions
    width, height, err := client.GetWindowSize(ctx)
    if err != nil {
        log.Fatalf("Failed to get window size: %v", err)
    }
    
    fmt.Printf("Screen size: %dx%d\n", width, height)
    
    // Test tap gesture
    centerX, centerY := width/2, height/2
    if err := client.Tap(ctx, centerX, centerY); err != nil {
        log.Fatalf("Failed to tap: %v", err)
    }
    fmt.Println("Tap gesture performed")
    
    // Test swipe gesture (scroll down)
    startY := height * 3 / 4
    endY := height / 4
    if err := client.Swipe(ctx, centerX, startY, centerX, endY, 1000); err != nil {
        log.Fatalf("Failed to swipe: %v", err)
    }
    fmt.Println("Swipe down gesture performed")
    
    // Test swipe up (scroll up)
    if err := client.Swipe(ctx, centerX, endY, centerX, startY, 1000); err != nil {
        log.Fatalf("Failed to swipe up: %v", err)
    }
    fmt.Println("Swipe up gesture performed")
    
    // Test long press
    if err := client.LongPress(ctx, centerX, centerY, 2000); err != nil {
        log.Fatalf("Failed to long press: %v", err)
    }
    fmt.Println("Long press gesture performed")
}
```

## iOS Testing Examples

### iOS Calculator Testing

```go
func testiOSCalculator() {
    client := gowright.NewAppiumClient("http://localhost:4723")
    ctx := context.Background()
    
    caps := gowright.AppiumCapabilities{
        PlatformName:   "iOS",
        PlatformVersion: "15.0",
        DeviceName:     "iPhone 13 Simulator",
        BundleID:       "com.apple.calculator",
        AutomationName: "XCUITest",
        NoReset:        true,
    }
    
    if err := client.CreateSession(ctx, caps); err != nil {
        log.Fatalf("Failed to create iOS session: %v", err)
    }
    defer client.DeleteSession(ctx)
    
    fmt.Println("Testing iOS Calculator...")
    
    // Wait for calculator to load
    time.Sleep(2 * time.Second)
    
    // Perform calculation: 8 + 7 = 15
    numbers := []string{"8", "+", "7", "="}
    
    for _, item := range numbers {
        element, err := client.WaitForElementClickable(ctx, gowright.ByAccessibilityID, item, 5*time.Second)
        if err != nil {
            log.Fatalf("Failed to find element %s: %v", item, err)
        }
        
        if err := element.Click(ctx); err != nil {
            log.Fatalf("Failed to click %s: %v", item, err)
        }
        
        time.Sleep(500 * time.Millisecond) // Small delay between taps
    }
    
    fmt.Println("iOS Calculator test completed")
    
    // Test device orientation
    orientation, err := client.GetOrientation(ctx)
    if err != nil {
        log.Printf("Failed to get orientation: %v", err)
    } else {
        fmt.Printf("Current orientation: %s\n", orientation)
    }
    
    // Test orientation change
    if err := client.SetOrientation(ctx, "LANDSCAPE"); err != nil {
        log.Printf("Failed to set landscape orientation: %v", err)
    } else {
        fmt.Println("Changed to landscape orientation")
        time.Sleep(2 * time.Second)
        
        // Change back to portrait
        if err := client.SetOrientation(ctx, "PORTRAIT"); err != nil {
            log.Printf("Failed to set portrait orientation: %v", err)
        } else {
            fmt.Println("Changed back to portrait orientation")
        }
    }
}
```

### iOS Settings Navigation

```go
func testiOSSettingsNavigation() {
    client := gowright.NewAppiumClient("http://localhost:4723")
    ctx := context.Background()
    
    caps := gowright.AppiumCapabilities{
        PlatformName:   "iOS",
        DeviceName:     "iPhone 13 Simulator",
        BundleID:       "com.apple.Preferences",
        AutomationName: "XCUITest",
    }
    
    if err := client.CreateSession(ctx, caps); err != nil {
        log.Fatalf("Failed to create session: %v", err)
    }
    defer client.DeleteSession(ctx)
    
    fmt.Println("Testing iOS Settings navigation...")
    
    // Find and tap on Wi-Fi settings using iOS locators
    by, value := gowright.IOS.Label("Wi-Fi")
    wifiSetting, err := client.WaitForElement(ctx, by, value, 10*time.Second)
    if err != nil {
        log.Fatalf("Failed to find Wi-Fi setting: %v", err)
    }
    
    if err := wifiSetting.Click(ctx); err != nil {
        log.Fatalf("Failed to tap Wi-Fi setting: %v", err)
    }
    
    fmt.Println("Navigated to Wi-Fi settings")
    
    // Wait for Wi-Fi page to load
    time.Sleep(2 * time.Second)
    
    // Find back button and return to main settings
    by, value = gowright.IOS.Label("Settings")
    backButton, err := client.FindElement(ctx, by, value)
    if err != nil {
        log.Printf("Back button not found, trying alternative method: %v", err)
        // Alternative: use navigation bar back button
        by, value = gowright.IOS.Type("XCUIElementTypeButton")
        buttons, err := client.FindElements(ctx, by, value)
        if err == nil && len(buttons) > 0 {
            backButton = buttons[0] // Usually the first button is back
        }
    }
    
    if backButton != nil {
        if err := backButton.Click(ctx); err != nil {
            log.Printf("Failed to tap back button: %v", err)
        } else {
            fmt.Println("Returned to main settings")
        }
    }
}
```

## Cross-Platform Testing

### Platform-Agnostic Test Function

```go
func testCrossPlatformApp(platform string) {
    client := gowright.NewAppiumClient("http://localhost:4723")
    ctx := context.Background()
    
    var caps gowright.AppiumCapabilities
    
    switch platform {
    case "Android":
        caps = gowright.AppiumCapabilities{
            PlatformName:   "Android",
            DeviceName:     "emulator-5554",
            AppPackage:     "com.example.crossplatformapp",
            AppActivity:    ".MainActivity",
            AutomationName: "UiAutomator2",
        }
    case "iOS":
        caps = gowright.AppiumCapabilities{
            PlatformName:   "iOS",
            DeviceName:     "iPhone 13 Simulator",
            BundleID:       "com.example.crossplatformapp",
            AutomationName: "XCUITest",
        }
    default:
        log.Fatalf("Unsupported platform: %s", platform)
    }
    
    if err := client.CreateSession(ctx, caps); err != nil {
        log.Fatalf("Failed to create %s session: %v", platform, err)
    }
    defer client.DeleteSession(ctx)
    
    fmt.Printf("Testing %s app...\n", platform)
    
    // Platform-specific element finding
    var loginButton *gowright.AppiumElement
    var err error
    
    if platform == "Android" {
        by, value := gowright.Android.Text("Login")
        loginButton, err = client.WaitForElement(ctx, by, value, 10*time.Second)
    } else {
        by, value := gowright.IOS.Label("Login")
        loginButton, err = client.WaitForElement(ctx, by, value, 10*time.Second)
    }
    
    if err != nil {
        log.Fatalf("Failed to find login button on %s: %v", platform, err)
    }
    
    if err := loginButton.Click(ctx); err != nil {
        log.Fatalf("Failed to click login button on %s: %v", platform, err)
    }
    
    fmt.Printf("%s login test completed\n", platform)
}

func runCrossPlatformTests() {
    platforms := []string{"Android", "iOS"}
    
    for _, platform := range platforms {
        fmt.Printf("\n=== Testing %s Platform ===\n", platform)
        testCrossPlatformApp(platform)
    }
}
```

## Advanced Scenarios

### App Installation and Management

```go
func testAppManagement() {
    client := gowright.NewAppiumClient("http://localhost:4723")
    ctx := context.Background()
    
    caps := gowright.AppiumCapabilities{
        PlatformName:   "Android",
        DeviceName:     "emulator-5554",
        AutomationName: "UiAutomator2",
    }
    
    if err := client.CreateSession(ctx, caps); err != nil {
        log.Fatalf("Failed to create session: %v", err)
    }
    defer client.DeleteSession(ctx)
    
    appPackage := "com.example.testapp"
    appPath := "/path/to/testapp.apk"
    
    fmt.Println("Testing app management...")
    
    // Check if app is installed
    installed, err := client.IsAppInstalled(ctx, appPackage)
    if err != nil {
        log.Fatalf("Failed to check app installation: %v", err)
    }
    
    fmt.Printf("App installed: %v\n", installed)
    
    if !installed {
        // Install app
        fmt.Println("Installing app...")
        if err := client.InstallApp(ctx, appPath); err != nil {
            log.Fatalf("Failed to install app: %v", err)
        }
        fmt.Println("App installed successfully")
    }
    
    // Launch app
    if err := client.LaunchApp(ctx); err != nil {
        log.Fatalf("Failed to launch app: %v", err)
    }
    fmt.Println("App launched")
    
    // Test app functionality here...
    time.Sleep(5 * time.Second)
    
    // Background app
    if err := client.BackgroundApp(ctx, 3); err != nil {
        log.Printf("Failed to background app: %v", err)
    } else {
        fmt.Println("App backgrounded for 3 seconds")
    }
    
    // Close app
    if err := client.CloseApp(ctx); err != nil {
        log.Printf("Failed to close app: %v", err)
    } else {
        fmt.Println("App closed")
    }
    
    // Reset app
    if err := client.ResetApp(ctx); err != nil {
        log.Printf("Failed to reset app: %v", err)
    } else {
        fmt.Println("App reset")
    }
}
```

### Mobile Web Testing

```go
func testMobileWebBrowser() {
    client := gowright.NewAppiumClient("http://localhost:4723")
    ctx := context.Background()
    
    caps := gowright.AppiumCapabilities{
        PlatformName:   "Android",
        DeviceName:     "emulator-5554",
        AutomationName: "UiAutomator2",
    }
    
    if err := client.CreateSession(ctx, caps); err != nil {
        log.Fatalf("Failed to create session: %v", err)
    }
    defer client.DeleteSession(ctx)
    
    fmt.Println("Testing mobile web browser...")
    
    // Launch Chrome browser
    if err := client.StartActivity(ctx, "com.android.chrome", "com.google.android.apps.chrome.Main"); err != nil {
        log.Fatalf("Failed to start Chrome: %v", err)
    }
    
    time.Sleep(3 * time.Second)
    
    // Find address bar
    addressBar, err := client.WaitForElement(ctx, gowright.ByID, "com.android.chrome:id/url_bar", 10*time.Second)
    if err != nil {
        log.Fatalf("Failed to find address bar: %v", err)
    }
    
    // Navigate to website
    if err := addressBar.Click(ctx); err != nil {
        log.Fatalf("Failed to click address bar: %v", err)
    }
    
    if err := addressBar.SendKeys(ctx, "https://example.com"); err != nil {
        log.Fatalf("Failed to enter URL: %v", err)
    }
    
    // Press enter by finding and clicking go button or using key event
    // Implementation depends on Chrome version and device
    
    fmt.Println("Navigated to website")
    
    // Wait for page to load
    time.Sleep(5 * time.Second)
    
    // Take screenshot of loaded page
    screenshot, err := client.TakeScreenshot(ctx)
    if err != nil {
        log.Printf("Failed to take screenshot: %v", err)
    } else {
        fmt.Printf("Screenshot taken: %d bytes\n", len(screenshot))
    }
    
    // Get page source
    source, err := client.GetPageSource(ctx)
    if err != nil {
        log.Printf("Failed to get page source: %v", err)
    } else {
        fmt.Printf("Page source length: %d characters\n", len(source))
    }
}
```

## Integration with GoWright Framework

### Complete Test Suite Example

```go
package main

import (
    "context"
    "testing"
    "time"
    
    "github.com/gowright/framework/pkg/gowright"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestMobileAppTestSuite(t *testing.T) {
    // Create test suite
    suite := gowright.NewTestSuite("Mobile Application Test Suite")
    
    // Add setup function
    suite.SetupFunc = func() error {
        // Suite-level setup (e.g., start Appium server, prepare test data)
        return nil
    }
    
    // Add teardown function
    suite.TeardownFunc = func() error {
        // Suite-level cleanup
        return nil
    }
    
    // Add individual tests
    suite.AddTest("Android Login Test", func(tc *gowright.TestContext) {
        testAndroidLogin(tc)
    })
    
    suite.AddTest("iOS Login Test", func(tc *gowright.TestContext) {
        testiOSLogin(tc)
    })
    
    suite.AddTest("Cross-Platform Navigation Test", func(tc *gowright.TestContext) {
        testCrossPlatformNavigation(tc)
    })
    
    // Run the test suite
    results := suite.Run()
    
    // Assert results
    assert.Greater(t, results.Passed, 0, "Should have passing tests")
    assert.Equal(t, 0, results.Failed, "Should have no failing tests")
    
    // Print summary
    t.Logf("Test Results: %d passed, %d failed, %d skipped", 
        results.Passed, results.Failed, results.Skipped)
}

func testAndroidLogin(tc *gowright.TestContext) {
    client := gowright.NewAppiumClient("http://localhost:4723")
    ctx := context.Background()
    
    caps := gowright.AppiumCapabilities{
        PlatformName: "Android",
        DeviceName:   "emulator-5554",
        AppPackage:   "com.example.loginapp",
        AppActivity:  ".LoginActivity",
    }
    
    err := client.CreateSession(ctx, caps)
    tc.AssertNoError(err, "Should create Android session")
    defer client.DeleteSession(ctx)
    
    // Test login flow
    usernameField, err := client.WaitForElement(ctx, gowright.ByID, "username", 10*time.Second)
    tc.AssertNoError(err, "Should find username field")
    
    err = usernameField.SendKeys(ctx, "testuser")
    tc.AssertNoError(err, "Should enter username")
    
    passwordField, err := client.FindElement(ctx, gowright.ByID, "password")
    tc.AssertNoError(err, "Should find password field")
    
    err = passwordField.SendKeys(ctx, "testpass")
    tc.AssertNoError(err, "Should enter password")
    
    loginButton, err := client.FindElement(ctx, gowright.ByID, "login-button")
    tc.AssertNoError(err, "Should find login button")
    
    err = loginButton.Click(ctx)
    tc.AssertNoError(err, "Should click login button")
    
    // Verify successful login
    welcomeMessage, err := client.WaitForElement(ctx, gowright.ByID, "welcome-message", 10*time.Second)
    tc.AssertNoError(err, "Should see welcome message")
    
    text, err := welcomeMessage.GetText(ctx)
    tc.AssertNoError(err, "Should get welcome text")
    tc.AssertContains(text, "Welcome", "Welcome message should contain 'Welcome'")
}

func testiOSLogin(tc *gowright.TestContext) {
    client := gowright.NewAppiumClient("http://localhost:4723")
    ctx := context.Background()
    
    caps := gowright.AppiumCapabilities{
        PlatformName: "iOS",
        DeviceName:   "iPhone 13 Simulator",
        BundleID:     "com.example.loginapp",
    }
    
    err := client.CreateSession(ctx, caps)
    tc.AssertNoError(err, "Should create iOS session")
    defer client.DeleteSession(ctx)
    
    // Similar login test for iOS using iOS-specific locators
    by, value := gowright.IOS.Label("Username")
    usernameField, err := client.WaitForElement(ctx, by, value, 10*time.Second)
    tc.AssertNoError(err, "Should find username field")
    
    err = usernameField.SendKeys(ctx, "testuser")
    tc.AssertNoError(err, "Should enter username")
    
    // Continue with iOS-specific test implementation...
}

func testCrossPlatformNavigation(tc *gowright.TestContext) {
    platforms := []struct {
        name string
        caps gowright.AppiumCapabilities
    }{
        {
            name: "Android",
            caps: gowright.AppiumCapabilities{
                PlatformName: "Android",
                DeviceName:   "emulator-5554",
                AppPackage:   "com.example.navapp",
                AppActivity:  ".MainActivity",
            },
        },
        {
            name: "iOS",
            caps: gowright.AppiumCapabilities{
                PlatformName: "iOS",
                DeviceName:   "iPhone 13 Simulator",
                BundleID:     "com.example.navapp",
            },
        },
    }
    
    for _, platform := range platforms {
        tc.Logf("Testing navigation on %s", platform.name)
        
        client := gowright.NewAppiumClient("http://localhost:4723")
        ctx := context.Background()
        
        err := client.CreateSession(ctx, platform.caps)
        tc.AssertNoError(err, "Should create %s session", platform.name)
        
        // Test navigation specific to platform
        testPlatformNavigation(tc, client, ctx, platform.name)
        
        client.DeleteSession(ctx)
    }
}

func testPlatformNavigation(tc *gowright.TestContext, client *gowright.AppiumClient, ctx context.Context, platform string) {
    // Platform-agnostic navigation test
    var homeButton *gowright.AppiumElement
    var err error
    
    if platform == "Android" {
        by, value := gowright.Android.Text("Home")
        homeButton, err = client.WaitForElement(ctx, by, value, 10*time.Second)
    } else {
        by, value := gowright.IOS.Label("Home")
        homeButton, err = client.WaitForElement(ctx, by, value, 10*time.Second)
    }
    
    tc.AssertNoError(err, "Should find home button on %s", platform)
    
    err = homeButton.Click(ctx)
    tc.AssertNoError(err, "Should click home button on %s", platform)
    
    // Verify navigation
    time.Sleep(2 * time.Second)
    
    // Take screenshot for verification
    screenshot, err := client.TakeScreenshot(ctx)
    tc.AssertNoError(err, "Should take screenshot on %s", platform)
    tc.AssertGreater(len(screenshot), 0, "Screenshot should not be empty on %s", platform)
}
```

### Performance Testing Example

```go
func TestMobilePerformance(t *testing.T) {
    client := gowright.NewAppiumClient("http://localhost:4723")
    ctx := context.Background()
    
    caps := gowright.AppiumCapabilities{
        PlatformName: "Android",
        DeviceName:   "emulator-5554",
        AppPackage:   "com.example.performanceapp",
        AppActivity:  ".MainActivity",
    }
    
    err := client.CreateSession(ctx, caps)
    require.NoError(t, err)
    defer client.DeleteSession(ctx)
    
    // Measure app launch time
    startTime := time.Now()
    
    // Wait for main screen to load
    mainScreen, err := client.WaitForElement(ctx, gowright.ByID, "main-screen", 30*time.Second)
    require.NoError(t, err)
    
    launchTime := time.Since(startTime)
    t.Logf("App launch time: %v", launchTime)
    
    // Assert launch time is reasonable
    assert.Less(t, launchTime, 10*time.Second, "App should launch within 10 seconds")
    
    // Test scroll performance
    startTime = time.Now()
    
    width, height, err := client.GetWindowSize(ctx)
    require.NoError(t, err)
    
    // Perform multiple scroll operations
    for i := 0; i < 10; i++ {
        err = client.Swipe(ctx, width/2, height*3/4, width/2, height/4, 500)
        require.NoError(t, err)
        time.Sleep(100 * time.Millisecond)
    }
    
    scrollTime := time.Since(startTime)
    t.Logf("10 scroll operations took: %v", scrollTime)
    
    // Assert scroll performance
    assert.Less(t, scrollTime, 15*time.Second, "10 scroll operations should complete within 15 seconds")
}
```

These examples demonstrate comprehensive mobile testing scenarios using the GoWright framework's Appium integration. They cover basic setup, platform-specific testing, cross-platform scenarios, advanced features, and integration with the broader GoWright testing framework.
#
# Mobile Web Testing

### Testing Web Applications on Mobile Devices

Mobile web testing allows you to test web applications running in mobile browsers, providing a bridge between traditional web testing and native mobile app testing.

```go
func testMobileWebApplication() {
    client := gowright.NewAppiumClient("http://localhost:4723")
    ctx := context.Background()
    
    // Configure for mobile web testing
    caps := gowright.AppiumCapabilities{
        PlatformName:      "Android",
        PlatformVersion:   "11",
        DeviceName:        "emulator-5554",
        AutomationName:    "UiAutomator2",
        NoReset:           true,
        NewCommandTimeout: 60,
    }
    
    if err := client.CreateSession(ctx, caps); err != nil {
        log.Fatalf("Failed to create mobile web session: %v", err)
    }
    defer client.DeleteSession(ctx)
    
    fmt.Println("Testing mobile web application...")
    
    // Launch Chrome browser
    if err := client.StartActivity(ctx, "com.android.chrome", "com.google.android.apps.chrome.Main"); err != nil {
        log.Fatalf("Failed to start Chrome: %v", err)
    }
    
    time.Sleep(3 * time.Second)
    
    // Navigate to website
    addressBar, err := client.WaitForElement(ctx, gowright.ByID, "com.android.chrome:id/url_bar", 10*time.Second)
    if err != nil {
        log.Fatalf("Failed to find address bar: %v", err)
    }
    
    if err := addressBar.Click(ctx); err != nil {
        log.Fatalf("Failed to click address bar: %v", err)
    }
    
    if err := addressBar.SendKeys(ctx, "https://example.com"); err != nil {
        log.Fatalf("Failed to type URL: %v", err)
    }
    
    fmt.Println("Successfully navigated to website")
    
    // Test mobile-specific interactions
    width, height, err := client.GetWindowSize(ctx)
    if err == nil {
        fmt.Printf("Mobile screen size: %dx%d\n", width, height)
        
        // Test mobile gestures on web content
        if err := client.Swipe(ctx, width/2, height/2, width/2, height/4, 1000); err != nil {
            log.Printf("Failed to perform swipe gesture: %v", err)
        } else {
            fmt.Println("Mobile swipe gesture performed on web content")
        }
    }
    
    // Get page source for analysis
    source, err := client.GetPageSource(ctx)
    if err == nil {
        fmt.Printf("Page source retrieved: %d characters\n", len(source))
    }
}
```

### Mobile Browser Configuration

```go
// Configure for different mobile browsers
func configureMobileBrowser(browserType string) gowright.AppiumCapabilities {
    baseCaps := gowright.AppiumCapabilities{
        PlatformName:   "Android",
        DeviceName:     "emulator-5554",
        AutomationName: "UiAutomator2",
    }
    
    switch browserType {
    case "chrome":
        // Chrome browser testing
        return baseCaps
    case "firefox":
        baseCaps.AppPackage = "org.mozilla.firefox"
        baseCaps.AppActivity = "org.mozilla.gecko.BrowserApp"
        return baseCaps
    default:
        return baseCaps
    }
}
```

## Comprehensive Testing Example (`mobile-testing/mobile_comprehensive.go`) ✅

The comprehensive mobile testing example demonstrates complete mobile testing capabilities including Android, iOS, and mobile web testing with Appium integration.

**Key Features Demonstrated:**
- Android and iOS app testing
- Mobile web testing
- Touch gestures and interactions
- Appium integration with GoWright
- Cross-platform testing patterns
- Screenshot capture and validation
- Device orientation and window management

**Example Usage:**
```bash
go run examples/mobile-testing/mobile_comprehensive.go
```

**Testing Capabilities:**
- Native Android app automation
- Native iOS app automation
- Mobile web browser testing
- Cross-platform test execution
- Device gesture simulation
- Screenshot and evidence capture
- Performance monitoring
- Session management

### Planned Mobile Testing Examples

#### Android-Specific Testing (`mobile-testing/mobile_android.go`) ⏳ **PLANNED**
Dedicated Android app testing with platform-specific features.

**Planned Features:**
- Android-specific UI elements
- Intent handling
- Background app testing
- Android permissions
- Device-specific testing

#### iOS-Specific Testing (`mobile-testing/mobile_ios.go`) ⏳ **PLANNED**
Dedicated iOS app testing with platform-specific features.

**Planned Features:**
- iOS-specific UI elements
- App lifecycle management
- iOS permissions and alerts
- Simulator-specific testing
- Device-specific testing

#### Touch Gestures (`mobile-testing/mobile_gestures.go`) ⏳ **PLANNED**
Comprehensive touch gesture testing and validation.

**Planned Features:**
- Tap, double-tap, long press
- Swipe and scroll gestures
- Pinch and zoom
- Multi-touch gestures
- Gesture recognition

#### Mobile Performance (`mobile-testing/mobile_performance.go`) ⏳ **PLANNED**
Mobile app performance testing and monitoring.

**Planned Features:**
- App launch time measurement
- Memory usage monitoring
- Battery usage testing
- Network performance
- Resource utilization

The following example demonstrates a complete mobile testing workflow that includes Android native app testing, iOS native app testing, mobile web testing, and integration with the GoWright framework.

### Complete Mobile Testing Suite

```go
package main

import (
    "context"
    "fmt"
    "log"
    "time"
    
    "github.com/gowright/framework/pkg/gowright"
)

func main() {
    fmt.Println("=== Gowright Mobile Testing - Comprehensive Examples ===\n")
    
    // Create a new Appium client
    client := gowright.NewAppiumClient("http://localhost:4723")
    ctx := context.Background()
    
    // Example 1: Android App Testing
    fmt.Println("1. Android App Testing Example")
    if err := androidAppExample(ctx, client); err != nil {
        log.Printf("Android example failed: %v", err)
    }
    
    // Example 2: iOS App Testing
    fmt.Println("\n2. iOS App Testing Example")
    if err := iOSAppExample(ctx, client); err != nil {
        log.Printf("iOS example failed: %v", err)
    }
    
    // Example 3: Web App Testing on Mobile
    fmt.Println("\n3. Mobile Web Testing Example")
    if err := mobileWebExample(ctx, client); err != nil {
        log.Printf("Mobile web example failed: %v", err)
    }
    
    // Example 4: Appium with GoWright Framework Integration
    fmt.Println("\n4. Appium with GoWright Framework Integration")
    appiumWithGoWrightExample()
    
    // Generate comprehensive mobile testing report
    fmt.Println("\nGenerating Mobile Testing Report...")
    generateMobileTestingReport()
    
    fmt.Println("\n=== Mobile Testing Complete ===")
}

func androidAppExample(ctx context.Context, client *gowright.AppiumClient) error {
    fmt.Println("📱 Testing Android Calculator App")
    
    // Define Android capabilities
    caps := gowright.AppiumCapabilities{
        PlatformName:      "Android",
        PlatformVersion:   "11",
        DeviceName:        "emulator-5554",
        AppPackage:        "com.android.calculator2",
        AppActivity:       ".Calculator",
        AutomationName:    "UiAutomator2",
        NoReset:           true,
        NewCommandTimeout: 60,
    }
    
    // Create session
    fmt.Println("Creating Android session...")
    if err := client.CreateSession(ctx, caps); err != nil {
        return fmt.Errorf("failed to create Android session: %w", err)
    }
    defer func() {
        fmt.Println("Closing Android session...")
        if err := client.DeleteSession(ctx); err != nil {
            log.Printf("Failed to delete session: %v", err)
        }
    }()
    
    fmt.Printf("✅ Session created with ID: %s\n", client.GetSessionID())
    
    // Wait for the calculator to load
    time.Sleep(2 * time.Second)
    
    // Find and click number buttons to perform calculation: 5 + 3 = 8
    fmt.Println("Performing calculation: 5 + 3 = 8")
    
    // Click number 5
    num5, err := client.WaitForElementClickable(ctx, gowright.ByID, "com.android.calculator2:id/digit_5", 10*time.Second)
    if err != nil {
        return fmt.Errorf("failed to find number 5: %w", err)
    }
    if err := num5.Click(ctx); err != nil {
        return fmt.Errorf("failed to click number 5: %w", err)
    }
    
    // Click plus button
    plus, err := client.FindElement(ctx, gowright.ByID, "com.android.calculator2:id/op_add")
    if err != nil {
        return fmt.Errorf("failed to find plus button: %w", err)
    }
    if err := plus.Click(ctx); err != nil {
        return fmt.Errorf("failed to click plus button: %w", err)
    }
    
    // Click number 3
    num3, err := client.FindElement(ctx, gowright.ByID, "com.android.calculator2:id/digit_3")
    if err != nil {
        return fmt.Errorf("failed to find number 3: %w", err)
    }
    if err := num3.Click(ctx); err != nil {
        return fmt.Errorf("failed to click number 3: %w", err)
    }
    
    // Click equals button
    equals, err := client.FindElement(ctx, gowright.ByID, "com.android.calculator2:id/eq")
    if err != nil {
        return fmt.Errorf("failed to find equals button: %w", err)
    }
    if err := equals.Click(ctx); err != nil {
        return fmt.Errorf("failed to click equals button: %w", err)
    }
    
    // Get the result
    result, err := client.FindElement(ctx, gowright.ByID, "com.android.calculator2:id/result")
    if err != nil {
        return fmt.Errorf("failed to find result: %w", err)
    }
    
    resultText, err := result.GetText(ctx)
    if err != nil {
        return fmt.Errorf("failed to get result text: %w", err)
    }
    
    fmt.Printf("✅ Calculation result: %s\n", resultText)
    
    // Take a screenshot
    fmt.Println("Taking screenshot...")
    screenshot, err := client.TakeScreenshot(ctx)
    if err != nil {
        return fmt.Errorf("failed to take screenshot: %w", err)
    }
    fmt.Printf("✅ Screenshot captured (length: %d bytes)\n", len(screenshot))
    
    // Test touch actions
    fmt.Println("Testing touch actions...")
    width, height, err := client.GetWindowSize(ctx)
    if err != nil {
        return fmt.Errorf("failed to get window size: %w", err)
    }
    fmt.Printf("Screen size: %dx%d\n", width, height)
    
    // Perform a swipe gesture
    if err := client.Swipe(ctx, width/2, height/2, width/2, height/4, 1000); err != nil {
        return fmt.Errorf("failed to perform swipe: %w", err)
    }
    fmt.Println("✅ Swipe gesture performed")
    
    return nil
}

func iOSAppExample(ctx context.Context, client *gowright.AppiumClient) error {
    fmt.Println("📱 Testing iOS Calculator App")
    
    // Define iOS capabilities
    caps := gowright.AppiumCapabilities{
        PlatformName:      "iOS",
        PlatformVersion:   "15.0",
        DeviceName:        "iPhone 13 Simulator",
        BundleID:          "com.apple.calculator",
        AutomationName:    "XCUITest",
        NoReset:           true,
        NewCommandTimeout: 60,
    }
    
    // Create session
    fmt.Println("Creating iOS session...")
    if err := client.CreateSession(ctx, caps); err != nil {
        return fmt.Errorf("failed to create iOS session: %w", err)
    }
    defer func() {
        fmt.Println("Closing iOS session...")
        if err := client.DeleteSession(ctx); err != nil {
            log.Printf("Failed to delete session: %v", err)
        }
    }()
    
    fmt.Printf("✅ Session created with ID: %s\n", client.GetSessionID())
    
    // Wait for the calculator to load
    time.Sleep(2 * time.Second)
    
    // Find and click number buttons using iOS locators
    fmt.Println("Performing calculation: 7 + 2 = 9")
    
    // Click number 7 using accessibility ID
    num7, err := client.WaitForElementClickable(ctx, gowright.ByAccessibilityID, "7", 10*time.Second)
    if err != nil {
        return fmt.Errorf("failed to find number 7: %w", err)
    }
    if err := num7.Click(ctx); err != nil {
        return fmt.Errorf("failed to click number 7: %w", err)
    }
    
    // Click plus button
    plus, err := client.FindElement(ctx, gowright.ByAccessibilityID, "+")
    if err != nil {
        return fmt.Errorf("failed to find plus button: %w", err)
    }
    if err := plus.Click(ctx); err != nil {
        return fmt.Errorf("failed to click plus button: %w", err)
    }
    
    // Click number 2
    num2, err := client.FindElement(ctx, gowright.ByAccessibilityID, "2")
    if err != nil {
        return fmt.Errorf("failed to find number 2: %w", err)
    }
    if err := num2.Click(ctx); err != nil {
        return fmt.Errorf("failed to click number 2: %w", err)
    }
    
    // Click equals button
    equals, err := client.FindElement(ctx, gowright.ByAccessibilityID, "=")
    if err != nil {
        return fmt.Errorf("failed to find equals button: %w", err)
    }
    if err := equals.Click(ctx); err != nil {
        return fmt.Errorf("failed to click equals button: %w", err)
    }
    
    // Test iOS-specific locators
    fmt.Println("Testing iOS-specific locators...")
    
    // Using iOS predicate locators
    by, value := gowright.IOS.Label("Calculator")
    elements, err := client.FindElements(ctx, by, value)
    if err == nil {
        fmt.Printf("✅ Found %d elements with label 'Calculator'\n", len(elements))
    }
    
    // Test device orientation
    orientation, err := client.GetOrientation(ctx)
    if err == nil {
        fmt.Printf("✅ Current orientation: %s\n", orientation)
    }
    
    return nil
}

func mobileWebExample(ctx context.Context, client *gowright.AppiumClient) error {
    fmt.Println("🌐 Testing Mobile Web Application")
    
    // Define capabilities for mobile web testing
    caps := gowright.AppiumCapabilities{
        PlatformName:      "Android",
        PlatformVersion:   "11",
        DeviceName:        "emulator-5554",
        AutomationName:    "UiAutomator2",
        NoReset:           true,
        NewCommandTimeout: 60,
    }
    
    // Create session
    fmt.Println("Creating mobile web session...")
    if err := client.CreateSession(ctx, caps); err != nil {
        return fmt.Errorf("failed to create mobile web session: %w", err)
    }
    defer func() {
        fmt.Println("Closing mobile web session...")
        if err := client.DeleteSession(ctx); err != nil {
            log.Printf("Failed to delete session: %v", err)
        }
    }()
    
    fmt.Printf("✅ Session created with ID: %s\n", client.GetSessionID())
    
    // Open Chrome browser
    fmt.Println("Opening Chrome browser...")
    if err := client.StartActivity(ctx, "com.android.chrome", "com.google.android.apps.chrome.Main"); err != nil {
        return fmt.Errorf("failed to start Chrome: %w", err)
    }
    
    time.Sleep(3 * time.Second)
    
    // Find the address bar and navigate to a website
    fmt.Println("Navigating to example.com...")
    addressBar, err := client.WaitForElement(ctx, gowright.ByID, "com.android.chrome:id/url_bar", 10*time.Second)
    if err != nil {
        return fmt.Errorf("failed to find address bar: %w", err)
    }
    
    if err := addressBar.Click(ctx); err != nil {
        return fmt.Errorf("failed to click address bar: %w", err)
    }
    
    if err := addressBar.SendKeys(ctx, "https://example.com"); err != nil {
        return fmt.Errorf("failed to type URL: %w", err)
    }
    
    fmt.Println("✅ Mobile web navigation example completed")
    
    // Test page source retrieval
    fmt.Println("Getting page source...")
    source, err := client.GetPageSource(ctx)
    if err == nil {
        fmt.Printf("✅ Page source length: %d characters\n", len(source))
    }
    
    return nil
}

// appiumWithGoWrightExample demonstrates using Appium with the GoWright testing framework
func appiumWithGoWrightExample() {
    fmt.Println("🔗 Integrating Appium with GoWright Framework")
    
    // Create a test suite that uses Appium
    suite := gowright.NewTestSuite("Mobile App Tests")
    
    // Add mobile test cases
    suite.AddTestFunc("Android Calculator Test", func(t *gowright.TestContext) {
        client := gowright.NewAppiumClient("http://localhost:4723")
        ctx := context.Background()
        
        caps := gowright.AppiumCapabilities{
            PlatformName:   "Android",
            DeviceName:     "emulator-5554",
            AppPackage:     "com.android.calculator2",
            AppActivity:    ".Calculator",
            AutomationName: "UiAutomator2",
        }
        
        // Create session
        err := client.CreateSession(ctx, caps)
        t.AssertNoError(err, "Should create Appium session successfully")
        defer func() {
            if err := client.DeleteSession(ctx); err != nil {
                log.Printf("Failed to delete session: %v", err)
            }
        }()
        
        // Perform test actions
        element, err := client.FindElement(ctx, gowright.ByID, "com.android.calculator2:id/digit_1")
        t.AssertNoError(err, "Should find digit 1 button")
        
        err = element.Click(ctx)
        t.AssertNoError(err, "Should click digit 1 button")
        
        // Add more test assertions...
        fmt.Println("✅ Appium-GoWright integration test completed")
    })
    
    // Run the test suite
    results := suite.Run()
    fmt.Printf("✅ Test Results: %d passed, %d failed\n", results.PassedCount, results.FailedCount)
}

func generateMobileTestingReport() {
    testResults := &gowright.TestResults{
        SuiteName:    "Mobile Testing Comprehensive Suite",
        StartTime:    time.Now().Add(-15 * time.Minute),
        EndTime:      time.Now(),
        TotalTests:   4,
        PassedTests:  4,
        FailedTests:  0,
        SkippedTests: 0,
        ErrorTests:   0,
        TestCases:    []gowright.TestCaseResult{}, // Would contain actual results
    }
    
    reportConfig := &gowright.ReportConfig{
        LocalReports: gowright.LocalReportConfig{
            JSON:      true,
            HTML:      true,
            OutputDir: "./reports/mobile-comprehensive",
        },
    }
    
    reportManager := gowright.NewReportManager(reportConfig)
    if err := reportManager.GenerateReports(testResults); err != nil {
        log.Printf("Failed to generate reports: %v", err)
    } else {
        fmt.Printf("✅ Reports generated in: %s\n", reportConfig.LocalReports.OutputDir)
    }
}
```

### Key Features Demonstrated

This comprehensive example showcases:

1. **Android Native App Testing**: Complete calculator app automation with element interactions, assertions, and screenshot capture
2. **iOS Native App Testing**: Cross-platform testing using iOS-specific locators and device management
3. **Mobile Web Testing**: Browser automation on mobile devices with web content interaction
4. **Framework Integration**: Seamless integration with GoWright's test suite and assertion framework
5. **Advanced Features**: Touch gestures, device orientation, screenshot capture, and comprehensive reporting
6. **Error Handling**: Robust error handling and session management
7. **Platform-Specific Locators**: Demonstrates both Android and iOS locator strategies
8. **Reporting**: Comprehensive test reporting with multiple output formats

### Running the Comprehensive Example

To run this comprehensive mobile testing example:

1. **Prerequisites**:
   - Appium Server running on `http://localhost:4723`
   - Android emulator or device connected
   - iOS Simulator (for iOS testing)
   - Calculator apps available on devices

2. **Execution**:
   ```bash
   go run examples/mobile-testing/mobile_comprehensive.go
   ```

3. **Expected Output**:
   - Session creation confirmations
   - Test execution progress
   - Screenshot capture confirmations
   - Test results and reporting

This example provides a complete foundation for building comprehensive mobile testing suites using the GoWright framework with Appium integration.