# UI Testing Examples

This section contains comprehensive UI testing examples for the Gowright testing framework. The examples repository includes 6 detailed UI testing scenarios covering everything from basic browser automation to advanced responsive design testing and dynamic content handling.

## 📁 UI Testing Examples Structure (6/6 - 100% Complete)

The UI testing examples are organized in the `examples/ui-testing/` directory:

### 🌐 Core UI Testing Examples

#### 1. **Basic Browser Automation** (`ui-testing/ui_basic.go`) ✅
Fundamental browser automation patterns with element interactions and navigation.

**Key Concepts:**
- Browser initialization and configuration
- Element location and interaction
- Page navigation and URL handling
- Basic assertions and validations
- Screenshot capture

#### 2. **Form Interactions** (`ui-testing/ui_forms.go`) ✅
Comprehensive form testing including input validation, submission, and error handling.

**Form Features:**
- Text input and validation
- Dropdown and select elements
- Checkbox and radio button handling
- Multi-step workflows
- File upload testing
- Form submission and validation
- Dynamic form elements
- Error message verification

#### 3. **Page Navigation** (`ui-testing/ui_navigation.go`) ✅ **NEW**
Advanced navigation patterns including browser history, URL parameters, and multi-tab handling.

**Navigation Features:**
- Basic page-to-page navigation
- Browser back and forward navigation
- URL parameter handling and validation
- Hash/fragment navigation
- Multi-tab navigation and window management
- Page refresh and reload testing
- Navigation with authentication flows

#### 4. **Dynamic Content** (`ui-testing/ui_dynamic_content.go`) ✅ **NEW**
Comprehensive AJAX and dynamic content testing with proper wait strategies and interaction handling.

**Dynamic Features:**
- AJAX loading with loading indicators
- Dynamic element creation and removal
- Content that appears after delays
- Infinite scroll simulation and testing
- Real-time data updates and refreshing
- Modal dialogs and overlay interactions
- JavaScript alerts, confirms, and prompts
- Drag and drop interactions
- Progressive loading and content updates

#### 5. **File Upload Testing** (`ui-testing/ui_file_uploads.go`) ✅ **NEW**
Comprehensive file upload testing suite covering all aspects of file handling in web applications.

**File Upload Features:**
- Single file upload with form submission
- Multiple file upload with validation
- File type validation and restrictions (accept attribute)
- File size validation with client-side checks
- Drag and drop upload functionality simulation
- Upload progress tracking with visual feedback
- Error handling and validation messages
- Temporary file creation and cleanup utilities
- Cross-browser file upload compatibility
- Large file handling (up to 1MB test files)

#### 6. **Responsive Design Testing** (`ui-testing/ui_responsive.go`) ✅ **NEW**
Comprehensive responsive design testing across different viewports and devices with detailed validation.

**Responsive Features:**
- Multiple viewport testing (mobile portrait/landscape, tablet, desktop, ultra-wide)
- Touch target size validation (44px minimum)
- Responsive navigation testing with hamburger menus
- Grid layout responsiveness validation
- Responsive image scaling and srcset testing
- Typography scaling and readability checks
- Horizontal scroll detection
- Cross-device compatibility testing
- Visual regression testing with screenshots

## 🚀 Quick Start

### Running Individual Examples

```bash
# Basic browser automation
go run examples/ui-testing/ui_basic.go

# Form interactions
go run examples/ui-testing/ui_forms.go

# Page navigation
go run examples/ui-testing/ui_navigation.go

# Dynamic content
go run examples/ui-testing/ui_dynamic_content.go

# File upload testing
go run examples/ui-testing/ui_file_uploads.go

# Responsive design testing
go run examples/ui-testing/ui_responsive.go

# Responsive design testing
go run examples/ui-testing/ui_responsive.go
```

### Running All UI Examples

```bash
# Run all UI testing examples
./examples/run_category.sh ui-testing

# Or run all examples
./examples/run_all_examples.sh
```

## 📋 Configuration Examples

### Basic Browser Configuration
```json
{
  "browserConfig": {
    "headless": false,
    "timeout": "30s",
    "windowSize": {
      "width": 1920,
      "height": 1080
    },
    "userAgent": "Gowright-Test-Browser"
  }
}
```

### Advanced Browser Configuration
```json
{
  "browserConfig": {
    "headless": false,
    "timeout": "30s",
    "windowSize": {
      "width": 1920,
      "height": 1080
    },
    "browsers": ["chrome", "firefox", "safari", "edge"],
    "chromeOptions": {
      "args": ["--disable-web-security", "--allow-running-insecure-content"],
      "prefs": {
        "profile.default_content_setting_values.notifications": 2
      }
    },
    "firefoxOptions": {
      "prefs": {
        "dom.webnotifications.enabled": false
      }
    },
    "screenshots": {
      "onFailure": true,
      "onSuccess": false,
      "directory": "./screenshots"
    },
    "performance": {
      "collectMetrics": true,
      "networkThrottling": "3G",
      "cpuThrottling": 4
    }
  }
}
```

## 🎯 Learning Path

### Beginner Path
1. **Start with Basic Automation**: `ui-testing/ui_basic.go`
2. **Learn Form Interactions**: `ui-testing/ui_forms.go`
3. **Practice Navigation**: `ui-testing/ui_navigation.go`

### Intermediate Path
1. **Dynamic Content**: `ui-testing/ui_dynamic_content.go`
2. **Advanced Navigation Patterns**: Study multi-tab and authentication flows in `ui_navigation.go`
3. **Complex Form Handling**: Advanced form scenarios in `ui_forms.go`

### Advanced Path
1. **Custom Test Patterns**: Combine multiple examples for complex workflows
2. **Performance Integration**: Add performance monitoring to existing tests
3. **Cross-Browser Compatibility**: Adapt examples for multiple browser testing

## 🧭 Navigation Testing Deep Dive

The `ui_navigation.go` example provides comprehensive navigation testing patterns that cover real-world scenarios:

### Navigation Test Scenarios

#### 1. Basic Page Navigation
Tests fundamental page-to-page navigation with element verification:
```go
// Navigate to login page and verify elements
basicNavigationTest.AddAction(gowright.NewNavigateAction("https://the-internet.herokuapp.com"))
basicNavigationTest.AddAction(gowright.NewClickAction("a[href='/login']"))
basicNavigationTest.AddAssertion(gowright.NewURLContainsAssertion("/login"))
basicNavigationTest.AddAssertion(gowright.NewElementPresentAssertion("form"))
```

#### 2. Browser History Management
Tests browser back/forward functionality:
```go
// Navigate forward, then test back/forward navigation
backForwardTest.AddAction(gowright.NewClickAction("a[href='/checkboxes']"))
backForwardTest.AddAction(gowright.NewBrowserBackAction())
backForwardTest.AddAction(gowright.NewBrowserForwardAction())
```

#### 3. URL Parameter Handling
Validates URL parameters and their presence in page content:
```go
// Test URL parameters
urlParamTest.AddAction(gowright.NewNavigateAction("https://httpbin.org/get?param1=value1&param2=value2"))
urlParamTest.AddAssertion(gowright.NewURLContainsAssertion("param1=value1"))
urlParamTest.AddAssertion(gowright.NewPageSourceContainsAssertion("param1"))
```

#### 4. Hash Fragment Navigation
Tests single-page application routing with hash fragments:
```go
// Test hash navigation
hashNavTest.AddAction(gowright.NewNavigateAction("https://example.com#section1"))
hashNavTest.AddAssertion(gowright.NewURLContainsAssertion("#section1"))
```

#### 5. Multi-Tab Navigation
Handles complex multi-tab scenarios with tab switching:
```go
// Open new tab, switch to it, close it, return to main tab
multiTabTest.AddAction(gowright.NewClickAction("a[href='/windows/new']"))
multiTabTest.AddAction(gowright.NewSwitchToNewTabAction())
multiTabTest.AddAction(gowright.NewCloseCurrentTabAction())
multiTabTest.AddAction(gowright.NewSwitchToMainTabAction())
```

#### 6. Page Refresh Testing
Tests page reload functionality and state persistence:
```go
// Test page refresh
refreshTest.AddAction(gowright.NewRefreshPageAction())
refreshTest.AddAssertion(gowright.NewPageTitleAssertion("Example Domain"))
```

#### 7. Authenticated Navigation
Tests navigation flows that require authentication:
```go
// Login and navigate to secure area
authNavTest.AddAction(gowright.NewTypeAction("#username", "tomsmith"))
authNavTest.AddAction(gowright.NewTypeAction("#password", "SuperSecretPassword!"))
authNavTest.AddAction(gowright.NewClickAction("button[type='submit']"))
authNavTest.AddAction(gowright.NewNavigateAction("https://the-internet.herokuapp.com/secure"))
```

### Navigation Testing Best Practices

1. **Wait Strategies**: Use appropriate waits for page loads and element visibility
2. **URL Validation**: Always verify URL changes after navigation actions
3. **Element Verification**: Confirm expected elements are present after navigation
4. **State Management**: Test that application state is maintained correctly
5. **Error Handling**: Include tests for navigation failures and error pages

## 📊 Example Code Snippets

### Basic UI Test
```go
func TestBasicUIOperations(t *testing.T) {
    framework := gowright.NewWithDefaults()
    defer framework.Close()
    
    uiTester := framework.GetUITester()
    
    // Navigate to page
    err := uiTester.NavigateTo("https://example.com")
    assert.NoError(t, err)
    
    // Find and click element
    element, err := uiTester.FindElement("button#submit")
    assert.NoError(t, err)
    
    err = element.Click()
    assert.NoError(t, err)
    
    // Verify page title
    title, err := uiTester.GetTitle()
    assert.NoError(t, err)
    assert.Contains(t, title, "Expected Title")
}
```

### Form Testing
```go
func TestFormInteractions(t *testing.T) {
    framework := gowright.NewWithDefaults()
    defer framework.Close()
    
    uiTester := framework.GetUITester()
    
    // Navigate to form page
    err := uiTester.NavigateTo("https://example.com/form")
    assert.NoError(t, err)
    
    // Fill form fields
    err = uiTester.FillField("input[name='username']", "testuser")
    assert.NoError(t, err)
    
    err = uiTester.FillField("input[name='password']", "testpass")
    assert.NoError(t, err)
    
    // Select dropdown option
    err = uiTester.SelectOption("select[name='country']", "US")
    assert.NoError(t, err)
    
    // Submit form
    err = uiTester.ClickElement("button[type='submit']")
    assert.NoError(t, err)
    
    // Verify success message
    successMsg, err := uiTester.GetElementText(".success-message")
    assert.NoError(t, err)
    assert.Contains(t, successMsg, "Form submitted successfully")
}
```

### Responsive Testing
```go
func TestResponsiveDesign(t *testing.T) {
    framework := gowright.NewWithDefaults()
    defer framework.Close()
    
    uiTester := framework.GetUITester()
    
    // Test different viewports
    viewports := []gowright.Viewport{
        {Width: 1920, Height: 1080}, // Desktop
        {Width: 768, Height: 1024},  // Tablet
        {Width: 375, Height: 667},   // Mobile
    }
    
    for _, viewport := range viewports {
        err := uiTester.SetViewport(viewport)
        assert.NoError(t, err)
        
        err = uiTester.NavigateTo("https://example.com")
        assert.NoError(t, err)
        
        // Verify responsive elements
        isVisible, err := uiTester.IsElementVisible(".mobile-menu")
        assert.NoError(t, err)
        
        if viewport.Width < 768 {
            assert.True(t, isVisible, "Mobile menu should be visible on small screens")
        } else {
            assert.False(t, isVisible, "Mobile menu should be hidden on large screens")
        }
    }
}
```

## 📁 File Upload Testing Deep Dive

The `ui_file_uploads.go` example provides a comprehensive file upload testing suite implemented as a structured test suite with proper initialization, cleanup, and reporting.

### File Upload Test Suite Structure

The file upload testing is implemented as a `FileUploadTestSuite` struct with the following components:
- Framework initialization with UI testing configuration
- Comprehensive test case management with reporting
- Temporary file creation and cleanup utilities
- Screenshot capture for visual verification

### File Upload Test Scenarios

#### 1. Single File Upload
Tests basic single file upload functionality with form submission and validation:
```go
func (s *FileUploadTestSuite) TestSingleFileUpload() {
    testCase := s.reporter.StartTest("Single File Upload", "Test uploading a single file")
    
    // Create test file
    testFile := s.createTestFile("test-document.txt", "This is a test document for upload testing.")
    
    // Navigate and upload
    err := s.uiTester.Navigate("https://httpbin.org/forms/post")
    fileInput, err := s.uiTester.FindElement("input[type='file']")
    err = fileInput.UploadFile(testFile)
    
    // Submit and verify
    submitBtn, err := s.uiTester.FindElement("input[type='submit']")
    err = submitBtn.Click()
    
    testCase.Pass("Single file upload successful")
}
```

#### 2. Multiple File Upload
Tests uploading multiple files simultaneously with iframe handling:
```go
func (s *FileUploadTestSuite) TestMultipleFileUpload() {
    // Create multiple test files
    files := []string{
        s.createTestFile("document1.txt", "First test document"),
        s.createTestFile("document2.txt", "Second test document"),
        s.createTestFile("image.jpg", "Fake image content"),
    }
    
    // Navigate to W3Schools multiple upload demo
    err := s.uiTester.Navigate("https://www.w3schools.com/tags/tryit.asp?filename=tryhtml5_input_multiple")
    
    // Switch to iframe and upload
    iframe, err := s.uiTester.FindElement("iframe#iframeResult")
    err = s.uiTester.SwitchToFrame(iframe)
    
    fileInput, err := s.uiTester.FindElement("input[type='file'][multiple]")
    err = fileInput.UploadFiles(files)
}
```

#### 3. File Type Validation
Tests file type restrictions using accept attributes and browser validation:
```go
func (s *FileUploadTestSuite) TestFileTypeValidation() {
    // Create files with different extensions
    validFile := s.createTestFile("document.pdf", "PDF content")
    invalidFile := s.createTestFile("script.exe", "Executable content")
    
    // Set accept attribute for PDF only
    fileInput, err := s.uiTester.FindElement("input[type='file']")
    err = s.uiTester.ExecuteScript("arguments[0].setAttribute('accept', '.pdf')", fileInput)
    
    // Test valid file upload
    err = fileInput.UploadFile(validFile)
    fileName, _ := fileInput.GetAttribute("value")
    if fileName != "" {
        fmt.Println("✅ Valid file type accepted")
    }
    
    // Test invalid file upload (browser should block)
    err = fileInput.UploadFile(invalidFile)
    if err != nil {
        testCase.Pass("File type validation working correctly")
    }
}
```

#### 4. File Size Validation
Tests file size restrictions with client-side validation:
```go
// Add client-side size validation
sizeValidationScript := `
    document.querySelector('input[type="file"]').addEventListener('change', function(e) {
        const file = e.target.files[0];
        if (file && file.size > 500000) { // 500KB limit
            alert('File too large! Maximum size is 500KB');
            e.target.value = '';
        }
    });
`

// Upload large file and check for validation alert
largeFile := s.createLargeTestFile("large-file.txt", 1024*1024) // 1MB
err = fileInput.UploadFile(largeFile)

// Handle validation alert
alertText, err := s.uiTester.GetAlertText()
if err == nil && alertText != "" {
    s.uiTester.AcceptAlert()
}
```

#### 5. Drag and Drop Upload
Tests drag-and-drop file upload functionality:
```go
// Create drag-drop area with JavaScript
dragDropScript := `
    const dropArea = document.createElement('div');
    dropArea.id = 'drop-area';
    dropArea.style.cssText = 'width: 300px; height: 200px; border: 2px dashed #ccc; text-align: center; padding: 20px;';
    dropArea.innerHTML = 'Drag files here';
    document.body.appendChild(dropArea);

    dropArea.addEventListener('drop', function(e) {
        e.preventDefault();
        this.style.backgroundColor = 'lightgreen';
        this.innerHTML = 'Files dropped: ' + e.dataTransfer.files.length;
    });
`

// Execute script and simulate drop
err = s.uiTester.ExecuteScript(dragDropScript)
dropArea, err := s.uiTester.FindElement("#drop-area")
```

#### 6. Upload Progress Tracking
Tests upload progress monitoring and feedback:
```go
// Add progress tracking JavaScript
progressScript := `
    const progressContainer = document.createElement('div');
    progressContainer.innerHTML = '<div id="progress-bar" style="width: 0%; height: 20px; background: green;"></div><div id="progress-text">0%</div>';
    document.body.appendChild(progressContainer);

    const form = document.querySelector('form');
    if (form) {
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            let progress = 0;
            const interval = setInterval(() => {
                progress += 10;
                document.getElementById('progress-bar').style.width = progress + '%';
                document.getElementById('progress-text').textContent = progress + '%';
                if (progress >= 100) {
                    clearInterval(interval);
                    document.getElementById('progress-text').textContent = 'Upload Complete!';
                }
            }, 200);
        });
    }
`

// Submit form and wait for progress completion
err = submitBtn.Click()
err = s.uiTester.WaitForText("Upload Complete!", 5*time.Second)
```

### File Upload Testing Best Practices

1. **File Management**: Create temporary test files and clean them up after tests
2. **Validation Testing**: Test both client-side and server-side validation
3. **Error Handling**: Include tests for upload failures and error messages
4. **Progress Feedback**: Verify upload progress indicators work correctly
5. **Cross-Browser Compatibility**: Test file uploads across different browsers
6. **Security Testing**: Validate file type and size restrictions are enforced

### Helper Functions

The file upload test suite includes comprehensive utility functions:

```go
// Create small test files with specific content
func (s *FileUploadTestSuite) createTestFile(filename, content string) string {
    tempDir := "temp_test_files"
    os.MkdirAll(tempDir, 0755)
    
    filePath := filepath.Join(tempDir, filename)
    file, err := os.Create(filePath)
    if err != nil {
        log.Printf("Warning: Could not create test file %s: %v", filename, err)
        return ""
    }
    defer file.Close()
    
    file.WriteString(content)
    return filePath
}

// Create large test files for size validation testing
func (s *FileUploadTestSuite) createLargeTestFile(filename string, sizeBytes int) string {
    tempDir := "temp_test_files"
    os.MkdirAll(tempDir, 0755)
    
    filePath := filepath.Join(tempDir, filename)
    file, err := os.Create(filePath)
    if err != nil {
        return ""
    }
    defer file.Close()
    
    // Write repeated content to reach desired size
    content := "This is test content for file size testing. "
    contentBytes := []byte(content)
    
    written := 0
    for written < sizeBytes {
        n, _ := file.Write(contentBytes)
        written += n
    }
    
    return filePath
}
```

## 📱 Responsive Design Testing Deep Dive

The `ui_responsive.go` example provides a comprehensive responsive design testing suite that validates web applications across multiple viewport sizes and devices.

### Responsive Test Suite Structure

The responsive testing is implemented as a `ResponsiveTestSuite` struct with:
- Multiple viewport size definitions (mobile, tablet, desktop, ultra-wide)
- Cross-site responsiveness testing
- Component-specific responsive validation
- Screenshot capture for visual regression testing
- Comprehensive reporting with pass/fail/warning states

### Viewport Configurations

The test suite defines 7 different viewport sizes for comprehensive testing:

```go
viewports := []ViewportSize{
    {Name: "Mobile Portrait", Width: 375, Height: 667, Device: "iPhone 8"},
    {Name: "Mobile Landscape", Width: 667, Height: 375, Device: "iPhone 8 Landscape"},
    {Name: "Tablet Portrait", Width: 768, Height: 1024, Device: "iPad"},
    {Name: "Tablet Landscape", Width: 1024, Height: 768, Device: "iPad Landscape"},
    {Name: "Desktop Small", Width: 1366, Height: 768, Device: "Laptop"},
    {Name: "Desktop Large", Width: 1920, Height: 1080, Device: "Desktop"},
    {Name: "Ultra Wide", Width: 2560, Height: 1440, Device: "Ultra Wide Monitor"},
}
```

### Responsive Test Scenarios

#### 1. Site-Wide Responsiveness Testing
Tests multiple websites across all viewport sizes:
```go
func (s *ResponsiveTestSuite) TestSiteResponsiveness(siteURL string, viewports []ViewportSize) {
    for _, viewport := range viewports {
        // Set viewport size
        err := s.uiTester.SetViewportSize(viewport.Width, viewport.Height)
        
        // Navigate and test
        err = s.uiTester.Navigate(siteURL)
        
        // Take screenshot for visual verification
        screenshotName := fmt.Sprintf("responsive_%s_%dx%d.png", viewport.Device, viewport.Width, viewport.Height)
        err = s.uiTester.TakeScreenshot(screenshotName)
        
        // Test responsive elements
        s.checkResponsiveElements(testCase, viewport)
    }
}
```

#### 2. Navigation Responsiveness
Tests responsive navigation patterns including hamburger menus:
```go
func (s *ResponsiveTestSuite) TestResponsiveNavigation(viewports []ViewportSize) {
    // Creates test HTML with responsive navigation
    testHTML := `
    <style>
        @media screen and (max-width: 600px) {
            .navbar a:not(:first-child) { display: none; }
            .navbar a.icon { float: right; display: block; }
        }
    </style>
    <div class="navbar" id="myNavbar">
        <a href="#home">Home</a>
        <a href="javascript:void(0);" class="icon" onclick="toggleNav()">☰</a>
    </div>`
    
    // Tests hamburger menu functionality on mobile
    // Tests full navigation visibility on desktop
}
```

#### 3. Touch Target Validation
Validates minimum touch target sizes for mobile usability:
```go
func (s *ResponsiveTestSuite) testMobileTouchTargets(testCase *reporting.TestCase) {
    clickableElements, err := s.uiTester.FindElements("a, button, input[type='button'], input[type='submit']")
    
    minTouchSize := 44 // 44px minimum recommended touch target size
    smallTargets := 0
    
    for _, element := range clickableElements {
        size, err := element.GetSize()
        if size.Width < minTouchSize || size.Height < minTouchSize {
            smallTargets++
        }
    }
    
    if smallTargets > 0 {
        testCase.AddStep(fmt.Sprintf("Found %d touch targets smaller than %dpx", smallTargets, minTouchSize), "warning")
    }
}
```

#### 4. Grid Layout Testing
Tests responsive grid systems and layout adaptation:
```go
func (s *ResponsiveTestSuite) TestResponsiveGrid(viewports []ViewportSize) {
    // Navigate to Bootstrap grid example
    err := s.uiTester.Navigate("https://getbootstrap.com/docs/5.0/layout/grid/")
    
    for _, viewport := range viewports {
        // Find grid columns
        columns, err := s.uiTester.FindElements(".col, [class*='col-']")
        
        if viewport.Width <= 576 {
            // Mobile: columns should stack (full width)
            // Check if columns are stacking properly
        } else {
            // Desktop: columns should be side by side
        }
    }
}
```

#### 5. Image Responsiveness Testing
Validates responsive images and srcset attributes:
```go
func (s *ResponsiveTestSuite) TestResponsiveImages(viewports []ViewportSize) {
    for _, viewport := range viewports {
        images, err := s.uiTester.FindElements("img")
        
        for _, img := range images {
            size, err := img.GetSize()
            
            // Check if image exceeds viewport
            if size.Width > viewport.Width {
                testCase.AddStep("Image may not be responsive", "warning")
            }
            
            // Check for responsive attributes
            srcset, _ := img.GetAttribute("srcset")
            maxWidth, _ := img.GetCSSValue("max-width")
            
            if srcset != "" || maxWidth == "100%" {
                testCase.AddStep("Image has responsive attributes", "pass")
            }
        }
    }
}
```

### Responsive Testing Best Practices

1. **Viewport Coverage**: Test across mobile, tablet, and desktop breakpoints
2. **Touch Targets**: Ensure minimum 44px touch target size for mobile
3. **Horizontal Scrolling**: Detect and flag horizontal scroll issues
4. **Navigation Patterns**: Test hamburger menus and responsive navigation
5. **Grid Systems**: Validate column stacking and layout adaptation
6. **Image Scaling**: Check responsive images and srcset implementation
7. **Typography**: Validate text scaling and readability across devices
8. **Visual Regression**: Capture screenshots for visual comparison

## 🔧 Prerequisites

### Required
- **Go 1.23.0+** with toolchain 1.24.5
- **Chrome/Chromium** browser installed
- **ChromeDriver** (automatically managed by go-rod)

### Optional
- **Firefox** for cross-browser testing
- **Safari** for macOS cross-browser testing
- **Edge** for Windows cross-browser testing
- **Docker** for containerized browser testing

## 📊 Performance Metrics

### Core Web Vitals
- **Largest Contentful Paint (LCP)**: Loading performance
- **First Input Delay (FID)**: Interactivity
- **Cumulative Layout Shift (CLS)**: Visual stability

### Custom Metrics
- **Page Load Time**: Complete page loading duration
- **Time to Interactive**: When page becomes fully interactive
- **Resource Loading**: Individual resource loading times
- **JavaScript Execution**: Script execution performance

## 🧪 Accessibility Testing

### WCAG Guidelines
- **Perceivable**: Content must be presentable to users
- **Operable**: Interface components must be operable
- **Understandable**: Information and UI operation must be understandable
- **Robust**: Content must be robust enough for various assistive technologies

### Automated Checks
- **Color contrast ratios**
- **Alternative text for images**
- **Keyboard navigation support**
- **ARIA attributes validation**
- **Focus management**
- **Semantic HTML structure**

## 📚 Related Examples

- [Advanced Patterns](advanced-patterns.md) - Page Object Model and advanced UI patterns
- [Integration Testing Examples](integration-testing.md) - End-to-end UI workflows
- [Performance Testing](advanced-patterns.md) - Advanced performance testing patterns
- [CI/CD Integration](cicd.md) - UI testing in CI/CD pipelines

## 🤝 Best Practices

### UI Test Design
- **Stable selectors**: Use reliable element selectors
- **Explicit waits**: Use proper wait strategies for dynamic content
- **Test isolation**: Ensure tests don't depend on each other
- **Data cleanup**: Clean up test data after execution

### Maintenance
- **Page Object Model**: Use POM for maintainable tests
- **Regular updates**: Keep tests updated with UI changes
- **Cross-browser validation**: Test across multiple browsers
- **Performance monitoring**: Track UI performance over time

---

## 🎯 Implementation Summary

These comprehensive UI testing examples provide complete coverage of modern web application testing scenarios:

### Core Testing Capabilities
- **Basic Automation** (`ui_basic.go`): 7 fundamental browser automation tests
- **Form Interactions** (`ui_forms.go`): 7 comprehensive form testing scenarios
- **Navigation Patterns** (`ui_navigation.go`): 7 advanced navigation and routing tests
- **Dynamic Content** (`ui_dynamic_content.go`): 8 AJAX and dynamic content tests
- **File Upload Suite** (`ui_file_uploads.go`): 6 comprehensive file handling tests
- **Responsive Design** (`ui_responsive.go`): Multi-viewport testing across 7 device sizes

### Advanced Features
- **Structured Test Suites**: Professional test suite architecture with proper initialization and cleanup
- **Comprehensive Reporting**: Detailed test reporting with pass/fail/warning states
- **Screenshot Capture**: Visual regression testing and documentation
- **Cross-Browser Support**: Chrome, Firefox, Safari, and Edge compatibility
- **Mobile Testing**: Touch target validation and mobile-specific interactions
- **Performance Monitoring**: Page load timing and resource monitoring
- **Accessibility Checks**: WCAG compliance validation

### Real-World Patterns
The 6 examples in the repository provide production-ready patterns for:
- E-commerce testing (forms, uploads, responsive design)
- SaaS application testing (navigation, dynamic content, user interactions)
- Content management systems (file uploads, responsive layouts)
- Progressive web applications (responsive design, mobile optimization)

These examples serve as both learning resources and production templates for building comprehensive UI test automation suites with the Gowright framework.