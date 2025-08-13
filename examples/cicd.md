# CI/CD Integration Examples

This section contains comprehensive CI/CD integration examples for the Gowright testing framework. These examples demonstrate how to integrate Gowright tests into various CI/CD pipelines and automation workflows.

## 📁 CI/CD Integration Examples

### 🔄 GitHub Actions Integration (`cicd/cicd_github_actions.go`)
Complete GitHub Actions workflow integration with matrix builds and artifact management.

**Key Concepts Covered:**
- GitHub Actions workflow configuration
- Matrix builds for multiple environments
- Test artifact collection and storage
- Slack/Teams notifications
- Pull request integration

**Example Usage:**
```bash
go run examples/cicd/cicd_github_actions.go
```

**Features:**
- Multi-platform testing (Linux, macOS, Windows)
- Database service integration
- Test report publishing
- Failure notifications

### 🏗️ Jenkins Integration (`cicd/cicd_jenkins.go`)
Jenkins pipeline integration with declarative and scripted pipelines.

**Key Concepts Covered:**
- Jenkinsfile configuration
- Pipeline stages and parallel execution
- Test result publishing
- Build artifact management
- Email and Slack notifications

**Example Usage:**
```bash
go run examples/cicd/cicd_jenkins.go
```

**Pipeline Features:**
- Multi-stage builds
- Parallel test execution
- Quality gates
- Deployment automation

### 🐳 Docker Integration (`cicd/cicd_docker.go`)
Containerized testing with Docker and Docker Compose.

**Key Concepts Covered:**
- Multi-stage Docker builds
- Docker Compose test environments
- Container orchestration
- Service dependencies
- Volume management for test data

**Example Usage:**
```bash
go run examples/cicd/cicd_docker.go
```

**Container Features:**
- Isolated test environments
- Service dependency management
- Scalable test execution
- Cross-platform compatibility

## 🔄 GitHub Actions Configuration

### Basic Workflow
```yaml
name: Gowright Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: testdb
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Go
      uses: actions/setup-go@v4
      with:
        go-version: '1.23'
    
    - name: Install dependencies
      run: go mod download
    
    - name: Run tests
      run: |
        export DATABASE_URL="postgres://postgres:postgres@localhost:5432/testdb?sslmode=disable"
        # Run all examples with enhanced reporting
        ./examples/run_all_examples.sh
        # Run specific CI/CD example
        go run examples/cicd/cicd_github_actions.go
    
    - name: Upload test reports
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: test-reports
        path: test-reports/
    
    - name: Notify Slack
      if: failure()
      uses: 8398a7/action-slack@v3
      with:
        status: failure
        webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Matrix Build Strategy
```yaml
strategy:
  matrix:
    os: [ubuntu-latest, macos-latest, windows-latest]
    go-version: ['1.22', '1.23']
    test-type: [unit, integration, e2e]
    
runs-on: ${{ matrix.os }}

steps:
- name: Run ${{ matrix.test-type }} tests
  run: |
    case "${{ matrix.test-type }}" in
      "unit")
        go test ./...
        ;;
      "integration")
        go run examples/integration-testing/integration_basic.go
        ;;
      "e2e")
        go run examples/cicd/cicd_github_actions.go
        ;;
    esac
```

### Advanced Workflow with Quality Gates
```yaml
jobs:
  quality-gate:
    runs-on: ubuntu-latest
    steps:
    - name: Run quality checks
      run: |
        # Code coverage check
        go test -coverprofile=coverage.out ./...
        coverage=$(go tool cover -func=coverage.out | grep total | awk '{print $3}' | sed 's/%//')
        if (( $(echo "$coverage < 80" | bc -l) )); then
          echo "Coverage $coverage% is below 80% threshold"
          exit 1
        fi
        
        # Security scan
        gosec ./...
        
        # Lint check
        golangci-lint run
    
    - name: SonarCloud Scan
      uses: SonarSource/sonarcloud-github-action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

## 🏗️ Jenkins Pipeline Configuration

### Declarative Pipeline
```groovy
pipeline {
    agent any
    
    environment {
        GO_VERSION = '1.23'
        DATABASE_URL = 'postgres://postgres:postgres@localhost:5432/testdb?sslmode=disable'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Setup') {
            steps {
                sh '''
                    # Install Go
                    wget -O go.tar.gz https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz
                    tar -C /usr/local -xzf go.tar.gz
                    export PATH=$PATH:/usr/local/go/bin
                    
                    # Install dependencies
                    go mod download
                '''
            }
        }
        
        stage('Quality Gates') {
            parallel {
                stage('Lint') {
                    steps {
                        sh 'golangci-lint run'
                    }
                }
                stage('Security Scan') {
                    steps {
                        sh 'gosec ./...'
                    }
                }
                stage('Unit Tests') {
                    steps {
                        sh 'go test -v -coverprofile=coverage.out ./...'
                    }
                }
            }
        }
        
        stage('Integration Tests') {
            steps {
                sh '''
                    # Start services
                    docker-compose up -d postgres redis
                    
                    # Wait for services
                    sleep 30
                    
                    # Run integration tests
                    go run examples/cicd/cicd_jenkins.go
                '''
            }
        }
        
        stage('E2E Tests') {
            steps {
                sh '''
                    # Start application
                    docker-compose up -d app
                    
                    # Run E2E tests
                    go run examples/integration-testing/integration_ecommerce.go
                '''
            }
        }
    }
    
    post {
        always {
            // Publish test results
            publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'test-reports',
                reportFiles: 'report.html',
                reportName: 'Gowright Test Report'
            ])
            
            // Archive artifacts
            archiveArtifacts artifacts: 'test-reports/**/*', fingerprint: true
            
            // Cleanup
            sh 'docker-compose down'
        }
        
        failure {
            // Send notifications
            emailext (
                subject: "Build Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: "Build failed. Check console output at ${env.BUILD_URL}",
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
            
            slackSend (
                color: 'danger',
                message: "Build failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
            )
        }
        
        success {
            slackSend (
                color: 'good',
                message: "Build successful: ${env.JOB_NAME} - ${env.BUILD_NUMBER}"
            )
        }
    }
}
```

### Scripted Pipeline with Advanced Features
```groovy
node {
    def testResults = [:]
    def buildInfo = [:]
    
    try {
        stage('Preparation') {
            checkout scm
            buildInfo.startTime = new Date()
            buildInfo.buildNumber = env.BUILD_NUMBER
            buildInfo.gitCommit = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
        }
        
        stage('Build') {
            sh '''
                export PATH=$PATH:/usr/local/go/bin
                go build -o gowright-test ./cmd/gowright
            '''
        }
        
        stage('Parallel Testing') {
            parallel(
                "Unit Tests": {
                    testResults.unit = sh(
                        returnStatus: true,
                        script: 'go test -v -json ./... > unit-test-results.json'
                    )
                },
                "Integration Tests": {
                    testResults.integration = sh(
                        returnStatus: true,
                        script: 'go run examples/cicd/cicd_jenkins.go'
                    )
                },
                "Performance Tests": {
                    testResults.performance = sh(
                        returnStatus: true,
                        script: 'go test -bench=. -benchmem ./...'
                    )
                }
            )
        }
        
        stage('Quality Analysis') {
            // SonarQube analysis
            withSonarQubeEnv('SonarQube') {
                sh '''
                    sonar-scanner \
                        -Dsonar.projectKey=gowright \
                        -Dsonar.sources=. \
                        -Dsonar.go.coverage.reportPaths=coverage.out
                '''
            }
            
            // Wait for quality gate
            timeout(time: 10, unit: 'MINUTES') {
                def qg = waitForQualityGate()
                if (qg.status != 'OK') {
                    error "Pipeline aborted due to quality gate failure: ${qg.status}"
                }
            }
        }
        
        stage('Deploy to Staging') {
            when {
                branch 'develop'
            }
            steps {
                sh '''
                    # Deploy to staging environment
                    kubectl apply -f k8s/staging/
                    kubectl rollout status deployment/gowright-app -n staging
                '''
            }
        }
        
    } catch (Exception e) {
        currentBuild.result = 'FAILURE'
        throw e
    } finally {
        // Generate comprehensive report
        buildInfo.endTime = new Date()
        buildInfo.duration = buildInfo.endTime.time - buildInfo.startTime.time
        buildInfo.testResults = testResults
        
        writeJSON file: 'build-info.json', json: buildInfo
        
        // Publish results
        publishTestResults testResultsPattern: '*-test-results.json'
        publishHTML([
            allowMissing: false,
            alwaysLinkToLastBuild: true,
            keepAll: true,
            reportDir: 'test-reports',
            reportFiles: 'report.html',
            reportName: 'Test Report'
        ])
    }
}
```

## 🐳 Docker Integration

### Multi-Stage Dockerfile
```dockerfile
# Build stage
FROM golang:1.23-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o gowright-test ./cmd/gowright

# Test stage
FROM builder AS tester

# Install test dependencies
RUN apk add --no-cache \
    chromium \
    chromium-chromedriver \
    postgresql-client \
    curl

# Set Chrome path for testing
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CHROME_PATH=/usr/lib/chromium/

# Copy test files
COPY examples/ ./examples/
COPY test-data/ ./test-data/

# Run tests
RUN go test -v ./...
RUN go run examples/cicd/cicd_docker.go

# Production stage
FROM alpine:latest AS production

RUN apk --no-cache add ca-certificates
WORKDIR /root/

COPY --from=builder /app/gowright-test .
COPY --from=tester /app/test-reports ./test-reports/

CMD ["./gowright-test"]
```

### Docker Compose for Testing
```yaml
version: '3.8'

services:
  gowright-test:
    build:
      context: .
      target: tester
    depends_on:
      - postgres
      - redis
      - selenium
    environment:
      - DATABASE_URL=postgres://postgres:postgres@postgres:5432/testdb?sslmode=disable
      - REDIS_URL=redis://redis:6379
      - SELENIUM_URL=http://selenium:4444/wd/hub
    volumes:
      - ./test-reports:/app/test-reports
      - ./test-data:/app/test-data
    networks:
      - test-network

  postgres:
    image: postgres:13-alpine
    environment:
      - POSTGRES_DB=testdb
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./test-data/sql:/docker-entrypoint-initdb.d
    networks:
      - test-network

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    networks:
      - test-network

  selenium:
    image: selenium/standalone-chrome:latest
    ports:
      - "4444:4444"
    environment:
      - SE_OPTS="--log-level INFO"
    volumes:
      - /dev/shm:/dev/shm
    networks:
      - test-network

  mailhog:
    image: mailhog/mailhog:latest
    ports:
      - "1025:1025"
      - "8025:8025"
    networks:
      - test-network

volumes:
  postgres_data:

networks:
  test-network:
    driver: bridge
```

### Kubernetes Testing
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: gowright-tests
spec:
  template:
    spec:
      containers:
      - name: gowright-test
        image: gowright/framework:latest
        command: ["go", "run", "examples/cicd/cicd_docker.go"]
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: url
        - name: REDIS_URL
          value: "redis://redis-service:6379"
        volumeMounts:
        - name: test-reports
          mountPath: /app/test-reports
        - name: test-data
          mountPath: /app/test-data
      volumes:
      - name: test-reports
        persistentVolumeClaim:
          claimName: test-reports-pvc
      - name: test-data
        configMap:
          name: test-data-config
      restartPolicy: Never
  backoffLimit: 3
```

## 🚀 Advanced CI/CD Patterns

### Blue-Green Deployment Testing
```yaml
stages:
  - name: Deploy Blue
    script: |
      kubectl apply -f k8s/blue/
      kubectl wait --for=condition=ready pod -l app=gowright-blue
  
  - name: Test Blue Environment
    script: |
      export TEST_URL=https://blue.gowright.com
      go run examples/integration-testing/integration_ecommerce.go
  
  - name: Switch Traffic
    script: |
      kubectl patch service gowright-service -p '{"spec":{"selector":{"version":"blue"}}}'
  
  - name: Test Production
    script: |
      export TEST_URL=https://gowright.com
      go run examples/api-testing/api_basic.go
```

### Canary Deployment Testing
```yaml
stages:
  - name: Deploy Canary
    script: |
      kubectl apply -f k8s/canary/
      # Route 10% traffic to canary
      kubectl apply -f k8s/traffic-split-10.yaml
  
  - name: Monitor Canary
    script: |
      # Run monitoring tests for 10 minutes
      timeout 600 go run examples/monitoring/canary_monitoring.go
  
  - name: Promote or Rollback
    script: |
      if [ "$CANARY_SUCCESS" = "true" ]; then
        kubectl apply -f k8s/traffic-split-100.yaml
      else
        kubectl delete -f k8s/canary/
      fi
```

## 📊 Metrics and Monitoring

### CI/CD Metrics Collection
```go
// Collect CI/CD metrics
type CICDMetrics struct {
    BuildDuration    time.Duration
    TestDuration     time.Duration
    DeployDuration   time.Duration
    TestSuccessRate  float64
    BuildSuccessRate float64
}

func collectMetrics() *CICDMetrics {
    return &CICDMetrics{
        BuildDuration:    getBuildDuration(),
        TestDuration:     getTestDuration(),
        DeployDuration:   getDeployDuration(),
        TestSuccessRate:  calculateTestSuccessRate(),
        BuildSuccessRate: calculateBuildSuccessRate(),
    }
}
```

### Performance Monitoring
```yaml
- name: Performance Monitoring
  script: |
    # Run performance tests
    go test -bench=. -benchmem ./...
    
    # Check performance thresholds
    if [ $(cat perf-results.json | jq '.avg_response_time') -gt 500 ]; then
      echo "Performance degradation detected"
      exit 1
    fi
```

## 🔧 Configuration Management

### Environment-Specific Configuration
```yaml
# .github/workflows/test.yml
env:
  GOWRIGHT_CONFIG: |
    {
      "environment": "${{ github.ref_name }}",
      "logLevel": "info",
      "apiConfig": {
        "baseURL": "${{ secrets.API_BASE_URL }}",
        "timeout": "30s"
      },
      "databaseConfig": {
        "connections": {
          "main": {
            "dsn": "${{ secrets.DATABASE_URL }}"
          }
        }
      }
    }
```

### Secret Management
```yaml
steps:
- name: Configure secrets
  run: |
    echo "${{ secrets.GOWRIGHT_CONFIG }}" > gowright-config.json
    echo "${{ secrets.API_KEYS }}" > api-keys.json
    
- name: Run tests with secrets
  run: |
    export API_KEY=$(cat api-keys.json | jq -r '.api_key')
    go run examples/cicd/cicd_github_actions.go
```

## 🧪 Testing CI/CD Configurations

### Local CI/CD Testing
```bash
# Test GitHub Actions locally with act
act -j test --secret-file .secrets

# Test Jenkins pipeline locally
jenkins-cli build gowright-test -p BRANCH_NAME=feature/test

# Test Docker build
docker build --target tester .
docker-compose -f docker-compose.test.yml up --abort-on-container-exit

# Test enhanced example runner in CI/CD context
./examples/run_all_examples.sh > ci_test_results.log 2>&1
if [ $? -ne 0 ]; then
    echo "CI/CD example validation failed"
    cat ci_test_results.log
    exit 1
fi
```

### CI/CD Configuration Validation
```go
func TestCICDConfiguration(t *testing.T) {
    // Validate GitHub Actions workflow
    workflow, err := loadGitHubWorkflow(".github/workflows/test.yml")
    assert.NoError(t, err)
    assert.Contains(t, workflow.Jobs, "test")
    
    // Validate Jenkinsfile
    pipeline, err := loadJenkinsfile("Jenkinsfile")
    assert.NoError(t, err)
    assert.Contains(t, pipeline.Stages, "Test")
    
    // Validate Docker Compose
    compose, err := loadDockerCompose("docker-compose.test.yml")
    assert.NoError(t, err)
    assert.Contains(t, compose.Services, "gowright-test")
}
```

## 📚 Best Practices

### Pipeline Design
- **Fail fast**: Run quick tests first
- **Parallel execution**: Run independent tests in parallel
- **Resource optimization**: Use appropriate resource limits
- **Artifact management**: Store and version test artifacts

### Security
- **Secret management**: Use secure secret storage
- **Image scanning**: Scan container images for vulnerabilities
- **Access control**: Implement proper access controls
- **Audit logging**: Log all CI/CD activities

### Monitoring
- **Pipeline metrics**: Track build and test metrics
- **Alerting**: Set up alerts for failures
- **Dashboards**: Create visibility dashboards
- **Trend analysis**: Analyze trends over time

## 📞 Troubleshooting

### Common Issues
- **Flaky tests**: Implement retry mechanisms and better waits
- **Resource constraints**: Optimize resource usage and limits
- **Network issues**: Add network resilience and timeouts
- **Environment differences**: Standardize environments

### Debug Mode
```yaml
- name: Debug CI/CD
  if: failure()
  run: |
    echo "=== Environment ==="
    env | sort
    echo "=== Disk Space ==="
    df -h
    echo "=== Memory ==="
    free -h
    echo "=== Processes ==="
    ps aux
    echo "=== Logs ==="
    cat test-reports/debug.log
```

## 📚 Related Documentation

- [Advanced Features - Parallel Execution](../advanced/parallel-execution.md) - Parallel testing strategies
- [Configuration Reference](../reference/configuration.md) - Complete configuration options
- [Best Practices](../reference/best-practices.md) - Testing best practices

---

These CI/CD integration examples provide comprehensive coverage of integrating Gowright tests into modern CI/CD pipelines. Choose the integration approach that best fits your infrastructure and deployment strategy.