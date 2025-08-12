# Configuration Reference

Complete configuration reference for the Gowright testing framework.

## Configuration File Format

The Gowright framework uses JSON configuration files with support for environment variable overrides.

### Basic Configuration Structure

```json
{
  "logLevel": "info",
  "parallel": true,
  "maxRetries": 3,
  "timeout": "30s",
  "apiConfig": {
    "baseURL": "https://api.example.com",
    "timeout": "15s",
    "headers": {
      "User-Agent": "Gowright/1.0"
    }
  },
  "databaseConfig": {
    "connections": {
      "main": {
        "driver": "postgres",
        "dsn": "postgres://user:pass@localhost/db?sslmode=disable",
        "maxOpenConns": 10,
        "maxIdleConns": 5
      }
    }
  },
  "browserConfig": {
    "headless": true,
    "timeout": "30s",
    "windowSize": {
      "width": 1920,
      "height": 1080
    }
  },
  "pluginConfig": {
    "enabled": ["metrics", "notifications", "reporting"],
    "plugins": {
      "metrics": {
        "enabled": true,
        "outputPath": "./metrics"
      },
      "notifications": {
        "enabled": true,
        "webhookURL": "https://hooks.slack.com/services/...",
        "channels": ["#testing", "#alerts"]
      },
      "reporting": {
        "enabled": true,
        "format": "html",
        "outputDir": "./reports"
      }
    }
  },
  "microservicesConfig": {
    "services": {
      "user-service": {
        "baseURL": "http://user-service:8080",
        "database": "user_db",
        "healthEndpoint": "/health"
      },
      "order-service": {
        "baseURL": "http://order-service:8080", 
        "database": "order_db",
        "healthEndpoint": "/health"
      }
    },
    "orchestration": {
      "maxConcurrency": 5,
      "timeout": "60s",
      "retryPolicy": {
        "maxRetries": 3,
        "backoff": "exponential"
      }
    }
  }
}
```

### Environment-Specific Configuration

#### Development Configuration
```json
{
  "logLevel": "debug",
  "parallel": false,
  "browserConfig": {
    "headless": false,
    "timeout": "30s"
  },
  "apiConfig": {
    "baseURL": "http://localhost:8080",
    "timeout": "10s"
  },
  "databaseConfig": {
    "connections": {
      "dev": {
        "driver": "sqlite3",
        "dsn": "./dev-test.db"
      }
    }
  }
}
```

#### Testing Configuration
```json
{
  "logLevel": "info",
  "parallel": true,
  "browserConfig": {
    "headless": true,
    "timeout": "20s"
  },
  "apiConfig": {
    "baseURL": "http://test-api:8080",
    "timeout": "15s"
  },
  "databaseConfig": {
    "connections": {
      "test": {
        "driver": "postgres",
        "dsn": "postgres://test:test@test-db:5432/testdb?sslmode=disable"
      }
    }
  }
}
```

#### Production Configuration
```json
{
  "logLevel": "error",
  "parallel": true,
  "browserConfig": {
    "headless": true,
    "timeout": "60s"
  },
  "apiConfig": {
    "baseURL": "https://api.example.com",
    "timeout": "45s"
  }
}
```

## Configuration Sections

### Core Configuration

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `logLevel` | string | "info" | Logging level (debug, info, warn, error) |
| `parallel` | boolean | false | Enable parallel test execution |
| `maxRetries` | integer | 3 | Maximum number of test retries |
| `timeout` | string | "30s" | Global timeout for operations |

### API Configuration

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `baseURL` | string | "" | Base URL for API requests |
| `timeout` | string | "15s" | Timeout for API requests |
| `headers` | object | {} | Default headers for all requests |
| `retryPolicy` | object | {} | Retry configuration for failed requests |

### Database Configuration

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `connections` | object | {} | Database connection configurations |
| `connections.{name}.driver` | string | "" | Database driver (postgres, mysql, sqlite3) |
| `connections.{name}.dsn` | string | "" | Database connection string |
| `connections.{name}.maxOpenConns` | integer | 10 | Maximum open connections |
| `connections.{name}.maxIdleConns` | integer | 5 | Maximum idle connections |

### Browser Configuration

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `headless` | boolean | true | Run browser in headless mode |
| `timeout` | string | "30s" | Browser operation timeout |
| `windowSize.width` | integer | 1920 | Browser window width |
| `windowSize.height` | integer | 1080 | Browser window height |
| `userAgent` | string | "" | Custom user agent string |

### Plugin Configuration

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `enabled` | array | [] | List of enabled plugin names |
| `plugins.{name}.enabled` | boolean | true | Enable/disable specific plugin |
| `plugins.{name}.settings` | object | {} | Plugin-specific settings |

#### Metrics Plugin Configuration
```json
{
  "plugins": {
    "metrics": {
      "enabled": true,
      "outputPath": "./metrics",
      "collectInterval": "5s",
      "metrics": ["response_time", "memory_usage", "test_count"]
    }
  }
}
```

#### Notification Plugin Configuration
```json
{
  "plugins": {
    "notifications": {
      "enabled": true,
      "webhookURL": "https://hooks.slack.com/services/...",
      "channels": ["#testing"],
      "onFailure": true,
      "onSuccess": false,
      "template": "Test {{.Status}}: {{.TestName}}"
    }
  }
}
```

#### Reporting Plugin Configuration
```json
{
  "plugins": {
    "reporting": {
      "enabled": true,
      "format": "html",
      "outputDir": "./reports",
      "template": "custom-template.html",
      "includeScreenshots": true,
      "includeLogs": true
    }
  }
}
```

### Microservices Configuration

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `services` | object | {} | Service-specific configurations |
| `services.{name}.baseURL` | string | "" | Service base URL |
| `services.{name}.database` | string | "" | Associated database connection |
| `services.{name}.healthEndpoint` | string | "/health" | Health check endpoint |
| `orchestration.maxConcurrency` | integer | 5 | Maximum concurrent service tests |
| `orchestration.timeout` | string | "60s" | Orchestration timeout |

#### Service-Specific Configuration
```json
{
  "microservicesConfig": {
    "services": {
      "user-service": {
        "baseURL": "http://user-service:8080",
        "database": "user_db",
        "healthEndpoint": "/health",
        "timeout": "30s",
        "retries": 3
      },
      "order-service": {
        "baseURL": "http://order-service:8080",
        "database": "order_db", 
        "healthEndpoint": "/actuator/health",
        "timeout": "45s",
        "retries": 2
      }
    }
  }
}
```

## Environment Variables

The following environment variables can override configuration values:

### Core Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `GOWRIGHT_ENV` | Environment name | `development`, `testing`, `production` |
| `GOWRIGHT_LOG_LEVEL` | Logging level | `debug`, `info`, `warn`, `error` |
| `GOWRIGHT_PARALLEL` | Enable parallel execution | `true`, `false` |
| `GOWRIGHT_MAX_RETRIES` | Maximum test retries | `3` |
| `GOWRIGHT_TIMEOUT` | Global timeout | `30s` |

### API Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `GOWRIGHT_API_BASE_URL` | API base URL | `https://api.example.com` |
| `GOWRIGHT_API_TIMEOUT` | API request timeout | `15s` |
| `GOWRIGHT_API_TOKEN` | API authentication token | `bearer-token-here` |

### Database Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `GOWRIGHT_DB_DRIVER` | Database driver | `postgres`, `mysql`, `sqlite3` |
| `GOWRIGHT_DB_DSN` | Database connection string | `postgres://user:pass@host/db` |
| `GOWRIGHT_DB_MAX_OPEN_CONNS` | Maximum open connections | `10` |
| `GOWRIGHT_DB_MAX_IDLE_CONNS` | Maximum idle connections | `5` |

### Browser Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `GOWRIGHT_BROWSER_HEADLESS` | Headless mode | `true`, `false` |
| `GOWRIGHT_BROWSER_TIMEOUT` | Browser timeout | `30s` |
| `GOWRIGHT_BROWSER_WIDTH` | Window width | `1920` |
| `GOWRIGHT_BROWSER_HEIGHT` | Window height | `1080` |

### Plugin Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `GOWRIGHT_PLUGINS_ENABLED` | Enabled plugins | `metrics,notifications,reporting` |
| `GOWRIGHT_PLUGIN_METRICS_PATH` | Metrics output path | `./metrics` |
| `GOWRIGHT_PLUGIN_SLACK_WEBHOOK` | Slack webhook URL | `https://hooks.slack.com/...` |
| `GOWRIGHT_PLUGIN_REPORT_FORMAT` | Report format | `html`, `json`, `xml` |

### Microservices Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `GOWRIGHT_SERVICES_CONCURRENCY` | Max service concurrency | `5` |
| `GOWRIGHT_SERVICE_TIMEOUT` | Service operation timeout | `60s` |
| `GOWRIGHT_USER_SERVICE_URL` | User service URL | `http://user-service:8080` |
| `GOWRIGHT_ORDER_SERVICE_URL` | Order service URL | `http://order-service:8080` |

## Configuration Loading Priority

Configuration values are loaded in the following priority order (highest to lowest):

1. **Environment Variables** - Runtime environment variable overrides
2. **Command Line Arguments** - CLI flags and arguments
3. **Configuration File** - JSON configuration file
4. **Default Values** - Built-in framework defaults

## Configuration Validation

The framework validates configuration on startup and will report errors for:

- Invalid JSON syntax in configuration files
- Missing required configuration values
- Invalid data types or formats
- Unreachable URLs or invalid connection strings
- Plugin configuration errors

## Dynamic Configuration

Some configuration values can be updated at runtime:

```go
// Update log level at runtime
framework.SetLogLevel("debug")

// Update API base URL
framework.GetAPITester().UpdateBaseURL("https://new-api.example.com")

// Enable/disable plugins
framework.EnablePlugin("notifications")
framework.DisablePlugin("metrics")
```

## Configuration Examples

### Complete Example Configuration

```json
{
  "logLevel": "info",
  "parallel": true,
  "maxRetries": 3,
  "timeout": "30s",
  
  "apiConfig": {
    "baseURL": "https://api.example.com",
    "timeout": "15s",
    "headers": {
      "User-Agent": "Gowright/1.0",
      "Accept": "application/json"
    },
    "retryPolicy": {
      "maxRetries": 3,
      "backoff": "exponential",
      "initialDelay": "1s"
    }
  },
  
  "databaseConfig": {
    "connections": {
      "primary": {
        "driver": "postgres",
        "dsn": "postgres://user:pass@localhost/primary?sslmode=disable",
        "maxOpenConns": 10,
        "maxIdleConns": 5,
        "connMaxLifetime": "1h"
      },
      "secondary": {
        "driver": "sqlite3",
        "dsn": ":memory:",
        "maxOpenConns": 1,
        "maxIdleConns": 1
      }
    }
  },
  
  "browserConfig": {
    "headless": true,
    "timeout": "30s",
    "windowSize": {
      "width": 1920,
      "height": 1080
    },
    "userAgent": "Gowright Browser Agent",
    "downloadPath": "./downloads"
  },
  
  "pluginConfig": {
    "enabled": ["metrics", "notifications", "reporting", "business"],
    "plugins": {
      "metrics": {
        "enabled": true,
        "outputPath": "./metrics",
        "collectInterval": "5s"
      },
      "notifications": {
        "enabled": true,
        "webhookURL": "https://hooks.slack.com/services/...",
        "channels": ["#testing"],
        "onFailure": true,
        "onSuccess": false
      },
      "reporting": {
        "enabled": true,
        "format": "html",
        "outputDir": "./reports",
        "includeScreenshots": true
      },
      "business": {
        "enabled": true,
        "rulesFile": "./business-rules.json"
      }
    }
  },
  
  "microservicesConfig": {
    "services": {
      "user-service": {
        "baseURL": "http://user-service:8080",
        "database": "user_db",
        "healthEndpoint": "/health",
        "timeout": "30s"
      },
      "order-service": {
        "baseURL": "http://order-service:8080",
        "database": "order_db",
        "healthEndpoint": "/health",
        "timeout": "45s"
      },
      "payment-service": {
        "baseURL": "http://payment-service:8080",
        "database": "payment_db",
        "healthEndpoint": "/health",
        "timeout": "60s"
      }
    },
    "orchestration": {
      "maxConcurrency": 3,
      "timeout": "120s",
      "retryPolicy": {
        "maxRetries": 2,
        "backoff": "linear",
        "initialDelay": "2s"
      }
    }
  }
}
```

This configuration reference provides comprehensive documentation for all available configuration options in the Gowright framework, including the new plugin system and microservices testing capabilities.