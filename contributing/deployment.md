# Deployment & CI/CD

Comprehensive guide for deploying and managing CI/CD workflows for the Gowright platform components.

## Overview

The Gowright platform uses automated GitHub Actions workflows for:

- **Continuous Integration**: Automated testing and validation
- **MCP Server Publishing**: Automated npm package publishing
- **Documentation Deployment**: Automated documentation site updates
- **Release Management**: Automated GitHub releases with proper versioning

## MCP Server CI/CD

### GitHub Actions Workflows

The MCP server includes two primary workflows located in `mcpserver/.github/workflows/`:

#### 1. Continuous Integration (`ci.yml`)

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches

**Actions:**
- Tests build process across Node.js versions 18 and 20
- Validates TypeScript compilation
- Checks package integrity with `npm pack --dry-run`
- Runs automated tests (when available)
- Validates the built package can execute

**Workflow Steps:**
```yaml
name: CI
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20]
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
      - name: Install dependencies
        run: npm ci
      - name: Build
        run: npm run build
      - name: Make executable
        run: chmod +x dist/index.js
      - name: Test execution
        run: node dist/index.js --help
      - name: Validate package
        run: npm pack --dry-run
```

#### 2. Publishing (`publish.yml`)

**Triggers:**
- **Automatic**: Git tags starting with `v` (e.g., `v1.0.1`)
- **Manual**: GitHub Actions UI with version bump selection

**Actions:**
- Builds and validates the package
- Publishes to npm registry
- Creates GitHub releases with installation instructions
- Includes MCP configuration examples in releases

**Workflow Features:**
- Version management with automatic package.json updates
- Git tag creation for releases
- Comprehensive release notes with installation instructions
- MCP configuration examples for users

### Setting Up Publishing

#### Prerequisites

1. **NPM Token Configuration**:
   ```bash
   # Create automation token at npm.com
   # Add as NPM_TOKEN repository secret in GitHub
   ```

2. **Repository Permissions**:
   - Ensure GitHub Actions has write permissions
   - Configure branch protection rules if needed

#### Publishing Methods

**Automatic Publishing (Recommended)**:
```bash
# Create and push version tag
git tag v1.0.1
git push origin v1.0.1

# Workflow automatically:
# 1. Builds the package
# 2. Publishes to npm
# 3. Creates GitHub release
```

**Manual Publishing**:
1. Navigate to GitHub Actions → "Publish MCP Server"
2. Click "Run workflow"
3. Select version bump type (patch/minor/major)
4. Workflow handles version bumping and publishing

#### Local Testing Before Publishing

Always validate locally before publishing using the comprehensive testing script:

```bash
cd mcpserver
./test-local.sh
```

This script runs the complete CI/CD pipeline locally, ensuring your changes are ready for production. It includes Node.js version validation, build compilation and executable creation, build validation (verifies executable file exists with proper permissions), testing, type checking, and package integrity verification.

For manual validation, you can run individual steps:

```bash
cd mcpserver
npm ci
npm run build
chmod +x dist/index.js
node dist/index.js --help
npm pack --dry-run
```

### Release Process

#### Version Management

The publishing workflow follows semantic versioning:

- **Patch** (1.0.1): Bug fixes and minor updates
- **Minor** (1.1.0): New features, backward compatible
- **Major** (2.0.0): Breaking changes

#### Release Content

Each GitHub release includes:

1. **Installation Instructions**:
   ```bash
   # Using uvx (recommended)
   uvx gowright-mcp-server@latest
   
   # Using npm
   npm install -g gowright-mcp-server
   ```

2. **MCP Configuration Examples**:
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
         "autoApprove": ["generate_test", "generate_config"]
       }
     }
   }
   ```

3. **Changelog and Features**: Detailed list of changes and new features

## Framework CI/CD

### Build System

The framework uses Make-based build automation:

```bash
# Development setup
make dev-setup          # Install tools and dependencies
make deps               # Install/update dependencies

# Code quality
make fmt                # Format code with gofmt
make lint               # Run golangci-lint
make security           # Run gosec security scan

# Testing
make test               # Run unit tests
make test-coverage      # Run tests with coverage report
make test-integration   # Run integration tests
make test-all          # Run all test types

# Building
make build             # Build binary
make build-all         # Build for multiple platforms
make docker-build      # Build Docker image

# CI/CD simulation
make ci                # Run full CI pipeline locally
```

### Docker Configuration

Multi-stage Docker builds for optimized images:

```dockerfile
# Build stage
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY . .
RUN make build

# Runtime stage
FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/gowright .
CMD ["./gowright"]
```

### GitHub Actions Integration

Framework CI/CD includes:

- **Multi-platform testing**: Linux, macOS, Windows
- **Database services**: PostgreSQL 13, MySQL 8.0 for testing
- **Security scanning**: gosec and Trivy vulnerability scanning
- **Coverage reporting**: Automated coverage report generation
- **Release automation**: Semantic versioning and GitHub releases

## Documentation Deployment

### Docsify with GitHub Pages

The documentation is automatically deployed using GitHub Pages:

```yaml
name: Deploy Documentation
on:
  push:
    branches: [main]
    paths: ['docs/**']

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./docs
```

### Local Documentation Development

```bash
cd docs
docsify serve .        # Serve with Docsify CLI
# or
python -m http.server 3000  # Alternative Python server

# Scripts
./docs/serve.sh        # Unix/Linux local server
./docs/serve.bat       # Windows local server
```

## Environment-Specific Deployments

### Development Environment

```json
{
  "mcpServers": {
    "gowright-dev": {
      "command": "uvx",
      "args": ["gowright-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "DEBUG",
        "GOWRIGHT_ENV": "development"
      }
    }
  }
}
```

### Production Environment

```json
{
  "mcpServers": {
    "gowright-prod": {
      "command": "uvx",
      "args": ["gowright-mcp-server@1.2.3"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR",
        "GOWRIGHT_ENV": "production",
        "NODE_OPTIONS": "--max-old-space-size=512"
      },
      "disabled": false
    }
  }
}
```

## Monitoring and Health Checks

### MCP Server Health Checks

```bash
# Check server status
curl -X POST http://localhost:3000/health

# Verify tool availability
curl -X POST http://localhost:3000/tools

# Check configuration
curl -X POST http://localhost:3000/config
```

### Framework Health Checks

```bash
# Verify installation
gowright --version

# Run health check
gowright health-check

# Validate configuration
gowright validate-config ./gowright-config.json
```

## Troubleshooting Deployments

### Common CI/CD Issues

#### 1. NPM Publishing Failures

**Problem**: Publishing to npm fails

**Solutions**:
```bash
# Check token permissions
npm whoami

# Verify package.json version
cat package.json | jq .version

# Test local publishing (dry run)
npm publish --dry-run
```

#### 2. GitHub Actions Failures

**Problem**: Workflow fails during execution

**Solutions**:
```bash
# Check workflow logs in GitHub Actions
# Verify secrets are properly configured
# Test locally before pushing

# Local CI simulation
make ci  # For framework
npm run build && npm test  # For MCP server
```

#### 3. Version Conflicts

**Problem**: Version already exists on npm

**Solutions**:
```bash
# Check existing versions
npm view gowright-mcp-server versions --json

# Bump version appropriately
npm version patch  # or minor/major

# Clean up failed tags if needed
git tag -d v1.0.1
git push origin :refs/tags/v1.0.1
```

#### 4. Build Failures

**Problem**: Build process fails in CI

**Solutions**:
```bash
# Framework build issues
make clean
go mod tidy
make build

# MCP server build issues
npm ci
npm run clean
npm run build
```

### Recovery Procedures

#### Failed Publishing Recovery

1. **Check the failed step** in GitHub Actions logs
2. **Fix the issue** locally and test
3. **For version bumps**, manually revert package.json changes if needed
4. **Re-run the workflow** or push a new tag

#### Rollback Procedures

```bash
# Rollback npm package (if needed)
npm unpublish gowright-mcp-server@1.0.1

# Remove GitHub release
# Use GitHub UI or gh CLI
gh release delete v1.0.1

# Remove git tag
git tag -d v1.0.1
git push origin :refs/tags/v1.0.1
```

## Best Practices

### Version Management

1. **Use semantic versioning** consistently
2. **Test thoroughly** before releasing
3. **Document breaking changes** clearly
4. **Maintain backward compatibility** when possible

### Security

1. **Rotate tokens** regularly
2. **Use least privilege** for automation tokens
3. **Scan for vulnerabilities** before releasing
4. **Keep dependencies updated**

### Monitoring

1. **Monitor deployment success** rates
2. **Track download/usage** metrics
3. **Set up alerts** for failed deployments
4. **Review logs** regularly

### Documentation

1. **Update documentation** with every release
2. **Include migration guides** for breaking changes
3. **Provide clear examples** for new features
4. **Maintain changelog** accuracy

---

This deployment guide ensures reliable, automated delivery of Gowright platform components while maintaining high quality and security standards.