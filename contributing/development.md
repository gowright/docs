# Development Setup

Guide for setting up a development environment for the Gowright testing framework and MCP server.

## Prerequisites

### Framework Development
- Go 1.23 or later
- Git
- Make (for build automation)
- Docker (optional, for containerized testing)

### MCP Server Development
- Node.js 18 or later
- npm or yarn
- TypeScript 5.0+
- Python with uv/uvx (for testing installation)

## Setup Steps

### Framework Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/gowright/framework.git
   cd framework
   ```

2. **Install dependencies**
   ```bash
   make deps
   go mod tidy
   ```

3. **Run tests**
   ```bash
   make test
   make test-integration
   ```

4. **Build the project**
   ```bash
   make build
   ```

### MCP Server Development

1. **Navigate to MCP server directory**
   ```bash
   cd mcpserver
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Build the server**
   ```bash
   npm run build
   ```

4. **Test locally**
   ```bash
   npm test
   node dist/index.js --help
   ```

## Development Workflow

### Framework Development

1. **Create feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make changes and test**
   ```bash
   make test
   make lint
   make security
   ```

3. **Validate and run examples**
   ```bash
   # Validate example structure and compilation
   ./examples/validate_examples.sh
   
   # Run all examples
   make examples
   ```

4. **Submit pull request**

### MCP Server Development

1. **Create feature branch**
   ```bash
   git checkout -b feature/mcp-feature-name
   ```

2. **Make changes and test**
   ```bash
   npm run build
   npm test
   npm run lint
   ```

3. **Test with uvx**
   ```bash
   npm pack
   uvx ./gowright-mcp-server-*.tgz --help
   ```

4. **Submit pull request**

## CI/CD and Publishing

### Automated Workflows

The project includes GitHub Actions workflows for:

- **Continuous Integration**: Runs tests on every push/PR
- **Automated Publishing**: Publishes MCP server to npm on version tags
- **Documentation Deployment**: Updates documentation site automatically

### Publishing MCP Server

#### Automatic Publishing (Recommended)
```bash
# Bump version and create tag
npm version patch  # or minor/major
git push origin main --tags
```

#### Manual Publishing
1. Go to GitHub Actions → "Publish MCP Server"
2. Click "Run workflow"
3. Select version bump type
4. The workflow will handle version bumping, publishing, and release creation

### Local Testing Before Publishing

Always test locally before publishing. The MCP server includes a comprehensive local testing script that replicates the CI/CD pipeline:

```bash
cd mcpserver
./test-local.sh
```

This script performs:
- Node.js version validation (requires Node.js 18+)
- Dependency installation and verification
- TypeScript type checking
- Code formatting validation (if Prettier is configured)
- Build compilation and executable creation
- Build validation (checks for executable file creation)
- Test execution
- Package integrity checks
- MCP server functionality testing
- Bundle size analysis
- Code quality checks (TODO/FIXME comments, console.log usage)

For manual testing, you can also run individual steps:

```bash
cd mcpserver
npm ci
npm run build
chmod +x dist/index.js

# Validate build output
if [ -f "dist/index.js" ] && [ -x "dist/index.js" ]; then
    echo "Build validation passed - executable created"
else
    echo "Build validation failed - executable not found or not executable"
    exit 1
fi

npm pack --dry-run
```

### Setting Up Publishing Secrets

For repository maintainers, ensure these secrets are configured:

1. **NPM_TOKEN**: npm automation token for publishing
   - Create at [npm.com](https://www.npmjs.com) → Account → Access Tokens
   - Add as repository secret in GitHub

## Code Quality Standards

### Example Validation

The project includes a comprehensive validation script for examples:

```bash
./examples/validate_examples.sh
```

This script validates:
- **Structure Requirements**: Build tags, package declarations, main functions
- **Import Validation**: Proper Gowright framework imports
- **Compilation Testing**: Syntax and dependency verification
- **Documentation**: README and index files
- **Script Permissions**: Executable permissions on shell scripts

**Example Requirements:**
- Must include `//go:build ignore` build tag
- Must declare `package main`
- Must include `func main()` function
- Must import Gowright framework properly
- Must compile without errors

### Go Code Standards
- Use `gofmt` for formatting
- Follow Go naming conventions
- Include comprehensive tests (>80% coverage)
- Add godoc comments for public APIs
- Run `golangci-lint` and `gosec` before committing
- Validate examples with `./examples/validate_examples.sh`

### TypeScript Code Standards
- Use TypeScript strict mode
- Follow consistent naming conventions
- Include JSDoc comments for public APIs
- Use Prettier for formatting
- Validate with ESLint

### Documentation Standards
- Update documentation for all new features
- Include code examples in documentation
- Use Mermaid diagrams for complex workflows
- Test all code examples before committing

## Troubleshooting Development Issues

### Common Framework Issues

1. **Build failures**
   ```bash
   make clean
   go mod tidy
   make build
   ```

2. **Test failures**
   ```bash
   make test-verbose
   go test -v ./...
   ```

3. **Example validation failures**
   ```bash
   # Run validation to identify issues
   ./examples/validate_examples.sh
   
   # Common fixes:
   # - Add build tag: //go:build ignore
   # - Ensure package main declaration
   # - Add main function
   # - Fix import paths
   # - Resolve compilation errors
   ```

4. **Dependency issues**
   ```bash
   go mod verify
   go mod download
   ```

### Common MCP Server Issues

1. **TypeScript compilation errors**
   ```bash
   npm run clean
   npm install
   npm run build
   ```

2. **Runtime errors**
   ```bash
   node --inspect dist/index.js
   ```

3. **Package issues**
   ```bash
   npm audit fix
   npm update
   ```

### Getting Help

- Check existing GitHub issues
- Review documentation at [gowright.github.io](https://gowright.github.io)
- Join community discussions
- Contact maintainers for complex issues